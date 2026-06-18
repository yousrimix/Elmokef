import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import crypto from 'crypto';

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 12;
const TAG_LENGTH = 16;

export interface EncryptedData {
  encrypted: Buffer;
  iv: string;
  authTag: string;
}

export function encryptBuffer(plaintext: Buffer, key: Buffer): EncryptedData {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
  const encrypted = Buffer.concat([cipher.update(plaintext), cipher.final()]);
  const authTag = cipher.getAuthTag();
  return {
    encrypted,
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex'),
  };
}

export function decryptBuffer(data: { encrypted: Buffer; iv: string; authTag: string }, key: Buffer): Buffer {
  const decipher = crypto.createDecipheriv(ALGORITHM, key, Buffer.from(data.iv, 'hex'));
  decipher.setAuthTag(Buffer.from(data.authTag, 'hex'));
  return Buffer.concat([decipher.update(data.encrypted), decipher.final()]);
}

export function encryptAndPack(plaintext: Buffer, key: Buffer): Buffer {
  const { encrypted, iv, authTag } = encryptBuffer(plaintext, key);
  return Buffer.concat([Buffer.from(iv, 'hex'), Buffer.from(authTag, 'hex'), encrypted]);
}

export function unpackAndDecrypt(packed: Buffer, key: Buffer): Buffer {
  const iv = packed.subarray(0, IV_LENGTH).toString('hex');
  const authTag = packed.subarray(IV_LENGTH, IV_LENGTH + TAG_LENGTH).toString('hex');
  const encrypted = packed.subarray(IV_LENGTH + TAG_LENGTH);
  return decryptBuffer({ encrypted, iv, authTag }, key);
}

@Injectable()
export class EncryptionService {
  private key: Buffer;

  constructor(private config: ConfigService) {
    const hex = this.config.get<string>('DOCUMENTS_ENCRYPTION_KEY');
    if (!hex || hex.length !== 64) {
      throw new Error('DOCUMENTS_ENCRYPTION_KEY must be a 32-byte hex string (64 hex chars)');
    }
    this.key = Buffer.from(hex, 'hex');
  }

  encrypt(plaintext: Buffer): EncryptedData {
    return encryptBuffer(plaintext, this.key);
  }

  decrypt(data: { encrypted: Buffer; iv: string; authTag: string }): Buffer {
    return decryptBuffer(data, this.key);
  }

  encryptFile(buffer: Buffer): Buffer {
    return encryptAndPack(buffer, this.key);
  }

  decryptFile(packed: Buffer): Buffer {
    return unpackAndDecrypt(packed, this.key);
  }
}
