import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { initializeApp, getApps, cert, App } from 'firebase-admin/app';
import { getMessaging, Messaging } from 'firebase-admin/messaging';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class FcmService implements OnModuleInit {
  private readonly logger = new Logger(FcmService.name);
  private messaging: Messaging;

  constructor(private config: ConfigService) {}

  onModuleInit() {
    const credPath = this.config.get('GOOGLE_APPLICATION_CREDENTIALS_FIREBASE', 'secrets/firebase-admin-sdk.json');
    const fullPath = path.resolve(credPath);

    if (getApps().length === 0) {
      if (fs.existsSync(fullPath)) {
        const serviceAccount = JSON.parse(fs.readFileSync(fullPath, 'utf-8'));
        const app: App = initializeApp({ credential: cert(serviceAccount) });
        this.messaging = getMessaging(app);
        this.logger.log('Firebase Admin initialized from service account file');
      } else {
        this.logger.warn(`لم يتم العثور على ${fullPath} — FCM غير نشط`);
        return;
      }
    } else {
      this.messaging = getMessaging();
    }
  }

  async sendToDevice(token: string, payload: { title: string; body: string; data?: Record<string, string> }) {
    if (!this.messaging) {
      this.logger.warn('FCM غير مهيأ — تخطي الإرسال');
      return { success: false, reason: 'FCM_NOT_CONFIGURED' };
    }
    try {
      const result = await this.messaging.send({
        token,
        notification: { title: payload.title, body: payload.body },
        data: payload.data,
      });
      this.logger.log(`FCM sent to device: ${result}`);
      return { success: true, messageId: result };
    } catch (err: any) {
      this.logger.error(`FCM send failed: ${err.message}`);
      return { success: false, error: err.message };
    }
  }

  async sendToMultipleDevices(tokens: string[], payload: { title: string; body: string; data?: Record<string, string> }) {
    if (!this.messaging) {
      this.logger.warn('FCM غير مهيأ — تخطي الإرسال الجماعي');
      return { success: false, reason: 'FCM_NOT_CONFIGURED' };
    }
    const results = await Promise.allSettled(
      tokens.map((token) => this.sendToDevice(token, payload)),
    );
    const succeeded = results.filter((r) => r.status === 'fulfilled' && r.value.success).length;
    const failed = results.filter((r) => r.status === 'rejected' || !r.value.success).length;
    return { succeeded, failed, total: tokens.length };
  }
}
