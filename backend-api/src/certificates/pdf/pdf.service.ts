import { Injectable } from '@nestjs/common';
import PDFDocument = require('pdfkit');
import * as fs from 'fs';
import * as path from 'path';

import { CertificateTemplate } from '../template/certificate.template';

@Injectable()
export class PdfService {
  async generateCertificatePdf(template: CertificateTemplate): Promise<string> {
    const year = new Date().getFullYear();
    const month = new Date().toLocaleString('en-US', { month: 'long' });

    const outputDir = path.join(
      process.cwd(),
      'uploads',
      'certificates',
      String(year),
      month,
    );

    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    const fileName = `${template.certificateNumber}.pdf`;
    const filePath = path.join(outputDir, fileName);

    const doc = new PDFDocument({
      size: 'A4',
      layout: 'landscape',
      margin: 0,
    });

    const stream = fs.createWriteStream(filePath);
    doc.pipe(stream);

    const width = doc.page.width;
    const height = doc.page.height;

    // Background
    doc.rect(0, 0, width, height).fill('#f8f3e6');

    // Outer border
    doc
      .lineWidth(8)
      .strokeColor('#0b3d2e')
      .rect(25, 25, width - 50, height - 50)
      .stroke();

    // Inner gold border
    doc
      .lineWidth(3)
      .strokeColor('#c9a227')
      .rect(45, 45, width - 90, height - 90)
      .stroke();

    // Header
    doc
      .fillColor('#0b3d2e')
      .fontSize(34)
      .font('Times-Bold')
      .text('NdaMinkoaba', 0, 65, { align: 'center' });

    doc
      .fontSize(13)
      .fillColor('#8a6f18')
      .text('Learn • Preserve • Transmit', 0, 105, { align: 'center' });

    doc
      .fontSize(30)
      .fillColor('#0b3d2e')
      .font('Times-Bold')
      .text('CERTIFICATE OF COMPLETION', 0, 145, { align: 'center' });

    doc
      .fontSize(15)
      .fillColor('#333333')
      .font('Times-Roman')
      .text('This certifies that', 0, 205, { align: 'center' });

    // Learner name
    doc
      .fontSize(42)
      .fillColor('#b28b16')
      .font('Times-BoldItalic')
      .text(template.learnerName.toUpperCase(), 0, 235, {
        align: 'center',
      });

    doc
      .fontSize(15)
      .fillColor('#333333')
      .font('Times-Roman')
      .text(
        'has successfully demonstrated foundational proficiency through the completion of',
        0,
        300,
        { align: 'center' },
      );

    // Course
    doc
      .fontSize(26)
      .fillColor('#0b3d2e')
      .font('Times-Bold')
      .text(template.courseName.toUpperCase(), 0, 335, { align: 'center' });

    // Level badge
    doc
      .roundedRect(width / 2 - 80, 380, 160, 35, 8)
      .fillAndStroke('#0b3d2e', '#c9a227');

    doc
      .fontSize(14)
      .fillColor('#ffffff')
      .font('Helvetica-Bold')
      .text(template.level.toUpperCase(), width / 2 - 80, 391, {
        width: 160,
        align: 'center',
      });

    // Details
    doc
      .fontSize(12)
      .fillColor('#333333')
      .font('Helvetica')
      .text(`Completion Date: ${template.completionDate}`, 90, 465);

    doc.text(`Certificate No: ${template.certificateNumber}`, 90, 490);

    doc.text(`Issued by: ${template.organization}`, 90, 515);

    // QR Code
    if (template.qrCode) {
      const qrBase64 = template.qrCode.replace(/^data:image\/png;base64,/, '');
      const qrBuffer = Buffer.from(qrBase64, 'base64');
      doc.image(qrBuffer, width - 180, height - 185, {
        width: 95,
        height: 95,
      });

      doc
        .fontSize(9)
        .fillColor('#333333')
        .text('Scan to verify', width - 185, height - 85, {
          width: 105,
          align: 'center',
        });
    }

    // Signatures
    doc
      .moveTo(240, height - 105)
      .lineTo(390, height - 105)
      .strokeColor('#333333')
      .lineWidth(1)
      .stroke();

    doc
      .fontSize(11)
      .fillColor('#333333')
      .text(template.instructorName, 240, height - 95, {
        width: 150,
        align: 'center',
      });

    doc
      .fontSize(9)
      .text('Language Instructor', 240, height - 78, {
        width: 150,
        align: 'center',
      });

    doc
      .moveTo(width - 390, height - 105)
      .lineTo(width - 240, height - 105)
      .stroke();

    doc
      .fontSize(11)
      .text(template.directorName, width - 390, height - 95, {
        width: 150,
        align: 'center',
      });

    doc
      .fontSize(9)
      .text('Academic Director', width - 390, height - 78, {
        width: 150,
        align: 'center',
      });

    // Footer
    doc
      .fontSize(9)
      .fillColor('#666666')
      .text(
        'This certificate is digitally verifiable through the NdaMinkoaba verification system.',
        0,
        height - 45,
        { align: 'center' },
      );

    doc.end();

    await new Promise<void>((resolve) => {
      stream.on('finish', () => resolve());
    });

    return `/uploads/certificates/${year}/${month}/${fileName}`;
  }
}