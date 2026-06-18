import { Injectable, NotFoundException, BadRequestException, ForbiddenException, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import { PaymentsGateway } from './payments.gateway';
import crypto from 'crypto';

const CMI_TEST_URL = 'https://test.cmi.co.ma';
const PLAN_PRICES = { PRO: 99, PREMIUM: 199 };
const SENSITIVE_FIELDS = ['pan', 'cardNumber', 'card_number', 'cvv', 'cvv2', 'cardCvv', 'cardSecurityCode', 'expiry', 'expireMonth', 'expireYear', 'cardHolderName'];

const CMI_ERROR_MAP: Record<string, string> = {
  'Fonds insuffisants': 'رصيد غير كافٍ',
  'funds insufficient': 'رصيد غير كافٍ',
  'Transaction refusée': 'العملية مرفوضة',
  'transaction declined': 'العملية مرفوضة',
  'Temps dépassé': 'انتهت مهلة العملية',
  'timeout': 'انتهت مهلة العملية',
  'Carte invalide': 'بطاقة غير صالحة',
  'invalid card': 'بطاقة غير صالحة',
  'Montant invalide': 'المبلغ غير صالح',
  'invalid amount': 'المبلغ غير صالح',
};

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private prisma: PrismaService,
    private config: ConfigService,
    private subscriptions: SubscriptionsService,
    private paymentsGateway: PaymentsGateway,
  ) {}

  private verifyHmac(payload: Record<string, any>, receivedHmac: string): boolean {
    const secret = this.config.get('CMI_SECRET_KEY');
    if (!secret) {
      this.logger.warn('CMI_SECRET_KEY غير مضبوط — تخطي التحقق من HMAC');
      return true;
    }
    const sorted = Object.keys(payload)
      .filter((k) => k !== 'hash' && k !== 'HMAC' && k !== 'signature')
      .sort()
      .map((k) => `${k}=${payload[k]}`)
      .join('&');
    const computed = crypto.createHmac('sha256', secret).update(sorted).digest('hex');
    return crypto.timingSafeEqual(Buffer.from(computed), Buffer.from(receivedHmac));
  }

  private sanitizeMetadata(raw: any): Record<string, any> {
    if (!raw || typeof raw !== 'object') return { raw: String(raw) };
    const clean: Record<string, any> = {};
    for (const [key, value] of Object.entries(raw)) {
      if (SENSITIVE_FIELDS.includes(key.toLowerCase())) continue;
      if (typeof value === 'object' && value !== null) {
        clean[key] = this.sanitizeMetadata(value);
      } else {
        clean[key] = value;
      }
    }
    return clean;
  }

  private translateCmiError(raw: string | undefined): string | undefined {
    if (!raw) return undefined;
    for (const [fr, ar] of Object.entries(CMI_ERROR_MAP)) {
      if (raw.toLowerCase().includes(fr.toLowerCase())) return ar;
    }
    return undefined;
  }

  async initPayment(artisanId: string, dto: { plan: string; successUrl: string; failureUrl: string }, ip?: string, userAgent?: string) {
    const price = PLAN_PRICES[dto.plan as keyof typeof PLAN_PRICES];
    if (!price) throw new BadRequestException('باقة غير صالحة');

    const existingPending = await this.prisma.payment.findFirst({
      where: { artisanId, status: 'PENDING' },
      orderBy: { createdAt: 'desc' },
    });

    if (existingPending) {
      await this.prisma.payment.update({
        where: { id: existingPending.id },
        data: { status: 'FAILED' },
      });
      await this.prisma.auditLog.create({
        data: { userId: artisanId, action: 'payment.cancelled_retry', metadata: { previousPaymentId: existingPending.id, reason: 'إعادة المحاولة — تم إلغاء المحاولة السابقة' } },
      });
    }

    const payment = await this.prisma.payment.create({
      data: { artisanId, amount: price, method: 'CMI', status: 'PENDING', ip, userAgent },
    });

    const storeKey = this.config.get('CMI_STORE_KEY', 'test_key');
    const storeId = this.config.get('CMI_STORE_ID', 'test_store');
    const baseUrl = this.config.get('CMI_BASE_URL', CMI_TEST_URL);

    const formData = {
      storeKey,
      storeId,
      amount: price.toFixed(2),
      currency: '504',
      oid: payment.id,
      okUrl: dto.successUrl,
      failUrl: dto.failureUrl,
      callbackUrl: `${this.config.get('API_BASE_URL', 'http://localhost:3000')}/api/v1/payments/webhook`,
      lang: 'ar',
      email: this.config.get('CMI_MERCHANT_EMAIL', 'merchant@elmokef.ma'),
    };

    await this.prisma.auditLog.create({
      data: { userId: artisanId, action: 'payment.init', metadata: { paymentId: payment.id, amount: price, plan: dto.plan, previousCancelled: !!existingPending } },
    });

    return {
      paymentId: payment.id,
      amount: price,
      previousCancelled: !!existingPending,
      previousCancelledMessage: existingPending ? 'تم إلغاء المحاولة السابقة' : undefined,
      formUrl: `${baseUrl}/fim/est3Dgate`,
      formData,
    };
  }

  async handleWebhook(dto: { transactionId: string; status: string; artisanId: string; amount: number; rawResponse?: string; hash?: string }, userAgent?: string) {
    if (dto.hash) {
      const isValid = this.verifyHmac(dto as any, dto.hash);
      if (!isValid) {
        await this.prisma.auditLog.create({
          data: { userId: dto.artisanId, action: 'payment.hmac_failed', metadata: { transactionId: dto.transactionId, userAgent } },
        });
        throw new ForbiddenException('HMAC غير صالح');
      }
    }

    const existing = await this.prisma.payment.findFirst({
      where: { transactionId: dto.transactionId },
    });
    if (existing) {
      this.logger.warn(`Idempotency hit — payment ${existing.id} already processed`);
      return { received: true, paymentId: existing.id, idempotent: true };
    }

    let payment = await this.prisma.payment.findFirst({
      where: { artisanId: dto.artisanId, status: 'PENDING' },
      orderBy: { createdAt: 'desc' },
    });

    const status = dto.status === 'SUCCESS' ? 'COMPLETED' : 'FAILED';
    const safeMetadata = dto.rawResponse ? this.sanitizeMetadata(JSON.parse(dto.rawResponse)) : undefined;
    const arabicError = this.translateCmiError(dto.rawResponse);

    if (payment) {
      payment = await this.prisma.payment.update({
        where: { id: payment.id },
        data: { status, transactionId: dto.transactionId, metadata: safeMetadata, userAgent: userAgent || payment.userAgent },
      });
    } else {
      payment = await this.prisma.payment.create({
        data: {
          artisanId: dto.artisanId,
          amount: dto.amount,
          transactionId: dto.transactionId,
          status,
          method: 'CMI',
          metadata: safeMetadata,
          userAgent,
        },
      });
    }

    if (status === 'COMPLETED') {
      await this.subscriptions.subscribe(dto.artisanId, { plan: 'PRO', paymentId: payment.id });
      this.paymentsGateway.notifyPaymentConfirmed(payment.id);
    } else {
      this.paymentsGateway.notifyPaymentFailed(payment.id, arabicError || 'فشلت عملية الدفع');
    }

    await this.prisma.auditLog.create({
      data: { userId: dto.artisanId, action: `payment.${status.toLowerCase()}`, metadata: { paymentId: payment.id, transactionId: dto.transactionId, amount: dto.amount, userAgent, errorArabic: arabicError } },
    });

    return { received: true, paymentId: payment.id, errorArabic: arabicError };
  }

  async getStatus(paymentId: string, userId?: string, userRole?: string) {
    const payment = await this.prisma.payment.findUnique({ where: { id: paymentId } });
    if (!payment) throw new NotFoundException('الدفعة غير موجودة');
    if (userId && userRole !== 'ADMIN' && payment.artisanId !== userId) {
      throw new ForbiddenException('ليست لديك صلاحية الاطلاع على هذه الدفعة');
    }
    return payment;
  }
}
