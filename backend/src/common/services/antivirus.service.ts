import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import NodeClam from 'clamscan';

@Injectable()
export class AntivirusService {
  private readonly logger = new Logger(AntivirusService.name);
  private clamscan: any;
  private enabled: boolean;

  constructor(private config: ConfigService) {
    this.enabled = this.config.get('CLAMAV_ENABLED', 'false') === 'true';
  }

  async onModuleInit() {
    if (!this.enabled) {
      this.logger.warn('ClamAV معطل — تخطي فحص الفيروسات');
      return;
    }
    try {
      this.clamscan = await new NodeClam().init({
        clamdscan: {
          host: this.config.get('CLAMAV_HOST', 'localhost'),
          port: parseInt(this.config.get('CLAMAV_PORT', '3310'), 10),
          timeout: 30000,
        },
        preference: 'clamdscan',
      });
      const version = await this.clamscan.getVersion();
      this.logger.log(`ClamAV متصل — الإصدار: ${version}`);
    } catch (err) {
      this.logger.error('فشل الاتصال بـ ClamAV', err);
      if (this.config.get('NODE_ENV') === 'production') {
        throw err;
      }
      this.enabled = false;
    }
  }

  async scanBuffer(buffer: Buffer): Promise<boolean> {
    if (!this.enabled) return true;
    try {
      const result = await this.clamscan.scanBuffer(buffer);
      if (result.isInfected) {
        throw new Error(`فيروس مكتشف: ${result.viruses?.join(', ') || 'unknown'}`);
      }
      return true;
    } catch (err: any) {
      if (err.message?.includes('فيروس مكتشف')) throw err;
      this.logger.error(`خطأ في فحص الفيروسات: ${err.message}`);
      if (this.config.get('NODE_ENV') === 'production') {
        throw new Error('تعذر فحص الملف — تم رفض الرفع');
      }
      return true;
    }
  }
}
