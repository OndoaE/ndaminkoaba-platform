import { Injectable } from '@nestjs/common';
import * as QRCode from 'qrcode';

@Injectable()
export class QrService {
  async generateQRCode(certificateCode: string): Promise<string> {
    const baseUrl =
      process.env.CERTIFICATE_VERIFY_URL ||
      'http://localhost:3000/api/certificates/verify';

    const verificationUrl = `${baseUrl}/${certificateCode}`;

    return QRCode.toDataURL(verificationUrl);
  }
}