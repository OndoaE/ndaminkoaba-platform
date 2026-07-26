import { Injectable } from '@nestjs/common';
import PDFDocument = require('pdfkit');
import * as fs from 'fs';
import * as path from 'path';

import { CertificateTemplate } from '../template/certificate.template';

const GOLD = '#C9A227';
const GOLD_DEEP = '#8A6F18';

interface LevelTheme {
  /** Deep accent used for borders, headings, badge fill. */
  accent: string;
  /** Light background wash (top of gradient). */
  tint: string;
  /** Slightly deeper wash (bottom of gradient). */
  tintDeep: string;
  stars: number;
}

// Beginner=green/1 star, Intermediate=red/2 stars, Advanced=yellow/3 stars —
// stars are always drawn in gold regardless of theme (see drawStar).
const LEVEL_THEMES: Record<string, LevelTheme> = {
  BEGINNER: { accent: '#145A32', tint: '#F1F8F3', tintDeep: '#DCEEE1', stars: 1 },
  INTERMEDIATE: { accent: '#7A1F2B', tint: '#FBEFF0', tintDeep: '#F3D9DC', stars: 2 },
  ADVANCED: { accent: '#9C7A0A', tint: '#FDF6E0', tintDeep: '#F6E7B4', stars: 3 },
};

function themeFor(level: string): LevelTheme {
  return LEVEL_THEMES[(level ?? '').toUpperCase()] ?? LEVEL_THEMES.BEGINNER;
}

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
    const theme = themeFor(template.level);

    // Background wash — subtle top-to-bottom gradient in the level's color.
    const backgroundGradient = doc.linearGradient(0, 0, 0, height);
    backgroundGradient.stop(0, theme.tint).stop(1, theme.tintDeep);
    doc.rect(0, 0, width, height).fill(backgroundGradient as unknown as string);

    // Triple frame: gold hairline, thick accent border, gold inner border.
    doc
      .lineWidth(1.2)
      .strokeColor(GOLD)
      .roundedRect(15, 15, width - 30, height - 30, 14)
      .stroke();

    doc
      .lineWidth(9)
      .strokeColor(theme.accent)
      .roundedRect(28, 28, width - 56, height - 56, 10)
      .stroke();

    doc
      .lineWidth(2.5)
      .strokeColor(GOLD)
      .roundedRect(48, 48, width - 96, height - 96, 6)
      .stroke();

    // Corner ornaments, just inside the frame.
    const ornamentInset = 70;
    this.drawCornerOrnament(doc, ornamentInset, ornamentInset, 14, GOLD, theme.accent);
    this.drawCornerOrnament(doc, width - ornamentInset, ornamentInset, 14, GOLD, theme.accent);
    this.drawCornerOrnament(doc, ornamentInset, height - ornamentInset, 14, GOLD, theme.accent);
    this.drawCornerOrnament(doc, width - ornamentInset, height - ornamentInset, 14, GOLD, theme.accent);

    // Brand header — always the deep brand green, independent of level theme.
    doc
      .fillColor('#0b3d2e')
      .fontSize(34)
      .font('Times-Bold')
      .text('NdaMinkoaba', 0, 62, { align: 'center' });

    doc
      .fontSize(13)
      .fillColor(GOLD_DEEP)
      .font('Times-Italic')
      .text('Learn • Preserve • Transmit', 0, 102, { align: 'center' });

    doc
      .fontSize(30)
      .fillColor(theme.accent)
      .font('Times-Bold')
      .text('CERTIFICATE OF COMPLETION', 0, 142, { align: 'center' });

    this.drawDividerOrnament(doc, width / 2, 182, GOLD);

    doc
      .fontSize(15)
      .fillColor('#333333')
      .font('Times-Roman')
      .text('This certifies that', 0, 200, { align: 'center' });

    // Learner name
    doc
      .fontSize(42)
      .fillColor('#b28b16')
      .font('Times-BoldItalic')
      .text(template.learnerName.toUpperCase(), 0, 230, {
        align: 'center',
      });

    doc
      .fontSize(15)
      .fillColor('#333333')
      .font('Times-Roman')
      .text(
        'has successfully demonstrated proficiency through the completion of',
        0,
        296,
        { align: 'center' },
      );

    // Course
    doc
      .fontSize(26)
      .fillColor(theme.accent)
      .font('Times-Bold')
      .text(template.courseName.toUpperCase(), 0, 331, { align: 'center' });

    // Level badge + gold star rating, side by side and centered.
    const badgeWidth = 150;
    const badgeHeight = 36;
    const starsPillWidth = 130;
    const gap = 10;
    const groupWidth = badgeWidth + gap + starsPillWidth;
    const groupX = width / 2 - groupWidth / 2;
    const badgeY = 382;

    doc
      .roundedRect(groupX, badgeY, badgeWidth, badgeHeight, 8)
      .fillAndStroke(theme.accent, GOLD);

    doc
      .fontSize(14)
      .fillColor('#ffffff')
      .font('Helvetica-Bold')
      .text(template.level.toUpperCase(), groupX, badgeY + 11, {
        width: badgeWidth,
        align: 'center',
      });

    const starsPillX = groupX + badgeWidth + gap;
    doc
      .roundedRect(starsPillX, badgeY, starsPillWidth, badgeHeight, 8)
      .fillAndStroke('#fffdf5', GOLD);

    const starRadius = 9;
    const starSpacing = 30;
    const starSpan = (theme.stars - 1) * starSpacing;
    const firstStarX = starsPillX + starsPillWidth / 2 - starSpan / 2;
    const starY = badgeY + badgeHeight / 2;
    for (let i = 0; i < theme.stars; i++) {
      this.drawStar(doc, firstStarX + i * starSpacing, starY, starRadius, GOLD);
    }

    // Details
    doc
      .fontSize(12)
      .fillColor('#333333')
      .font('Helvetica')
      .text(`Completion Date: ${template.completionDate}`, 90, 465);

    doc.text(`Certificate No: ${template.certificateNumber}`, 90, 490);

    doc.text(`Issued by: ${template.organization}`, 90, 515);

    // Ceremonial seal, centered between the two signature blocks.
    this.drawSeal(doc, width / 2, height - 148, theme.accent);

    // QR Code
    if (template.qrCode) {
      const qrBase64 = template.qrCode.replace(/^data:image\/png;base64,/, '');
      const qrBuffer = Buffer.from(qrBase64, 'base64');

      doc
        .lineWidth(1.5)
        .strokeColor(theme.accent)
        .roundedRect(width - 186, height - 191, 107, 107, 6)
        .stroke();

      doc.image(qrBuffer, width - 180, height - 185, {
        width: 95,
        height: 95,
      });

      doc
        .fontSize(9)
        .fillColor(theme.accent)
        .font('Helvetica-Bold')
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
      .font('Helvetica')
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

  /** Classic 5-point star, always filled gold regardless of the certificate theme. */
  private drawStar(
    doc: PDFKit.PDFDocument,
    cx: number,
    cy: number,
    radius: number,
    color: string,
  ) {
    const points = 5;
    const innerRadius = radius * 0.42;
    const step = Math.PI / points;
    let rotation = -Math.PI / 2;

    doc.moveTo(cx + radius * Math.cos(rotation), cy + radius * Math.sin(rotation));
    for (let i = 0; i < points; i++) {
      rotation += step;
      doc.lineTo(
        cx + innerRadius * Math.cos(rotation),
        cy + innerRadius * Math.sin(rotation),
      );
      rotation += step;
      doc.lineTo(cx + radius * Math.cos(rotation), cy + radius * Math.sin(rotation));
    }
    doc.closePath().fill(color);
  }

  /** Small nested-diamond flourish used at each of the four frame corners. */
  private drawCornerOrnament(
    doc: PDFKit.PDFDocument,
    cx: number,
    cy: number,
    size: number,
    outerColor: string,
    innerColor: string,
  ) {
    doc
      .moveTo(cx, cy - size)
      .lineTo(cx + size, cy)
      .lineTo(cx, cy + size)
      .lineTo(cx - size, cy)
      .closePath()
      .fill(outerColor);

    const inner = size * 0.5;
    doc
      .moveTo(cx, cy - inner)
      .lineTo(cx + inner, cy)
      .lineTo(cx, cy + inner)
      .lineTo(cx - inner, cy)
      .closePath()
      .fill(innerColor);
  }

  /** Thin gold rule with a small centered diamond, under the main title. */
  private drawDividerOrnament(
    doc: PDFKit.PDFDocument,
    cx: number,
    y: number,
    color: string,
  ) {
    const halfWidth = 140;
    doc
      .moveTo(cx - halfWidth, y)
      .lineTo(cx - 10, y)
      .strokeColor(color)
      .lineWidth(1)
      .stroke();
    doc
      .moveTo(cx + 10, y)
      .lineTo(cx + halfWidth, y)
      .stroke();

    doc
      .moveTo(cx, y - 5)
      .lineTo(cx + 5, y)
      .lineTo(cx, y + 5)
      .lineTo(cx - 5, y)
      .closePath()
      .fill(color);
  }

  /** Ceremonial wax-seal motif: accent ring, gold ring, single gold star. */
  private drawSeal(
    doc: PDFKit.PDFDocument,
    cx: number,
    cy: number,
    accent: string,
  ) {
    doc.circle(cx, cy, 26).fill(accent);
    doc.circle(cx, cy, 26).lineWidth(2).strokeColor(GOLD).stroke();
    doc.circle(cx, cy, 19).lineWidth(1).strokeColor(GOLD).stroke();
    this.drawStar(doc, cx, cy, 11, GOLD);

    doc
      .fontSize(7)
      .fillColor(accent)
      .font('Helvetica-Bold')
      .text('CERTIFIED', cx - 40, cy + 32, { width: 80, align: 'center' });
  }
}
