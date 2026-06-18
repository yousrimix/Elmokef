import { Module } from '@nestjs/common';
import { ArtisansController } from './artisans.controller';
import { ArtisansService } from './artisans.service';
import { DocumentsController } from './documents.controller';
import { AdminDocumentsController } from './admin-documents.controller';
import { DocumentsService } from './documents.service';
import { RankingModule } from '../ranking/ranking.module';
import { UploadModule } from '../upload/upload.module';

@Module({
  imports: [RankingModule, UploadModule],
  controllers: [ArtisansController, DocumentsController, AdminDocumentsController],
  providers: [ArtisansService, DocumentsService],
})
export class ArtisansModule {}
