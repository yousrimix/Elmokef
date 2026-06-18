import { Injectable, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import sharp from 'sharp';
import path from 'path';
import fs from 'fs/promises';
import { v4 as uuid } from 'uuid';
import { EncryptionService } from '../../common/services/encryption.service';
import { AntivirusService } from '../../common/services/antivirus.service';

const ALLOWED_MIME = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
const MAX_SIZE = 5 * 1024 * 1024;

export interface UploadResult {
  url: string;
  thumbnailUrl: string | null;
  encrypted: boolean;
}

@Injectable()
export class UploadService {
  private baseDir: string;

  constructor(
    private config: ConfigService,
    private encryption: EncryptionService,
    private antivirus: AntivirusService,
  ) {
    this.baseDir = path.join(process.cwd(), 'uploads');
  }

  async save(file: Express.Multer.File, subDir: string = 'general'): Promise<UploadResult> {
    if (!ALLOWED_MIME.includes(file.mimetype)) {
      throw new BadRequestException('نوع الملف غير مسموح. الأنواع المدعومة: jpeg, png, webp, gif');
    }
    if (file.size > MAX_SIZE) {
      throw new BadRequestException('حجم الملف يتجاوز 5 ميجابايت');
    }

    await this.antivirus.scanBuffer(file.buffer);

    const ext = file.mimetype === 'image/jpeg' ? 'jpg' : file.mimetype === 'image/png' ? 'png' : file.mimetype === 'image/gif' ? 'gif' : 'webp';
    const id = uuid();
    const isDocument = subDir === 'documents';
    const fileName = isDocument ? `${id}.enc` : `${id}.${ext}`;
    const destDir = path.join(this.baseDir, subDir);

    await fs.mkdir(destDir, { recursive: true });

    if (isDocument) {
      const encrypted = this.encryption.encryptFile(file.buffer);
      await fs.writeFile(path.join(destDir, fileName), encrypted);
      const baseUrl = this.config.get('UPLOAD_BASE_URL', '/uploads');
      return { url: `${baseUrl}/${subDir}/${fileName}`, thumbnailUrl: null, encrypted: true };
    }

    const thumbName = `${id}_thumb.webp`;
    const thumbDir = path.join(this.baseDir, subDir, 'thumb');
    await fs.mkdir(thumbDir, { recursive: true });

    const fullPath = path.join(destDir, fileName);
    const thumbPath = path.join(thumbDir, thumbName);

    await sharp(file.buffer).resize(1920, 1920, { fit: 'inside', withoutEnlargement: true }).toFile(fullPath);
    await sharp(file.buffer).resize(150, 150, { fit: 'cover' }).webp({ quality: 70 }).toFile(thumbPath);

    const baseUrl = this.config.get('UPLOAD_BASE_URL', '/uploads');
    return {
      url: `${baseUrl}/${subDir}/${fileName}`,
      thumbnailUrl: `${baseUrl}/${subDir}/thumb/${thumbName}`,
      encrypted: false,
    };
  }

  async readEncrypted(url: string): Promise<Buffer> {
    const filePath = path.join(process.cwd(), url.replace(/^\//, ''));
    const packed = await fs.readFile(filePath);
    return this.encryption.decryptFile(packed);
  }

  async deleteByUrl(url: string): Promise<void> {
    const filePath = path.join(process.cwd(), url.replace(/^\//, ''));
    const parsed = path.parse(filePath);
    const thumbPath = path.join(parsed.dir, 'thumb', `${parsed.name}_thumb.webp`);
    try { await fs.unlink(filePath); } catch {}
    try { await fs.unlink(thumbPath); } catch {}
  }
}
