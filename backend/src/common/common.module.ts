import { Global, Module } from '@nestjs/common';
import { EncryptionService } from './services/encryption.service';
import { AntivirusService } from './services/antivirus.service';

@Global()
@Module({
  providers: [EncryptionService, AntivirusService],
  exports: [EncryptionService, AntivirusService],
})
export class CommonModule {}
