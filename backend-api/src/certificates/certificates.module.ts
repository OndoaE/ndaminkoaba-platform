import { Module } from '@nestjs/common';

import { PrismaModule } from '../prisma/prisma.module';

import { CertificatesController } from './certificates.controller';
import { CertificatesService } from './certificates.service';

import { PdfService } from './pdf/pdf.service';
import { QrService } from './qr/qr.service';

@Module({
  imports: [PrismaModule],
  controllers: [CertificatesController],
  providers: [
    CertificatesService,
    PdfService,
    QrService,
  ],
  exports: [
    CertificatesService,
    PdfService,
    QrService,
  ],
})
export class CertificatesModule {}