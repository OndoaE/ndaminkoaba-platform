import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';
import { CreateCertificateDto } from './dto/create-certificate.dto/create-certificate.dto';
import { QueryCertificateDto } from './dto/query-certificate.dto/query-certificate.dto';
import { PdfService } from './pdf/pdf.service';
import { QrService } from './qr/qr.service';

@Injectable()
export class CertificatesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly pdfService: PdfService,
    private readonly qrService: QrService,
  ) {}

  private generateCertificateCode() {
    const year = new Date().getFullYear();
    const random = Math.floor(100000 + Math.random() * 900000);
    return `NDM-${year}-${random}`;
  }

  async create(dto: CreateCertificateDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) throw new BadRequestException('Invalid userId.');

    const course = await this.prisma.course.findUnique({
      where: { id: dto.courseId },
      include: { modules: { include: { lessons: true } } },
    });

    if (!course) throw new BadRequestException('Invalid courseId.');

    const existingCertificate = await this.prisma.certificate.findFirst({
      where: { userId: dto.userId, courseId: dto.courseId },
    });

    if (existingCertificate) {
      throw new ConflictException('Certificate already issued for this course.');
    }

    const lessonIds = course.modules.flatMap((module) =>
      module.lessons.map((lesson) => lesson.id),
    );

    if (lessonIds.length === 0) {
      throw new BadRequestException('This course has no lessons.');
    }

    const completedLessons = await this.prisma.progress.count({
      where: {
        userId: dto.userId,
        lessonId: { in: lessonIds },
        completed: true,
      },
    });

    if (completedLessons < lessonIds.length) {
      throw new BadRequestException(
        `Course not completed. Completed ${completedLessons}/${lessonIds.length} lessons.`,
      );
    }

    const quizzes = await this.prisma.quiz.findMany({
      where: { lessonId: { in: lessonIds } },
      select: { id: true },
    });

    if (quizzes.length > 0) {
      const passedQuizAttempts = await this.prisma.quizAttempt.findMany({
        where: {
          userId: dto.userId,
          quizId: { in: quizzes.map((quiz) => quiz.id) },
          passed: true,
        },
        distinct: ['quizId'],
      });

      if (passedQuizAttempts.length < quizzes.length) {
        throw new BadRequestException(
          `Required quizzes not passed. Passed ${passedQuizAttempts.length}/${quizzes.length} quizzes.`,
        );
      }
    }

    return this.prisma.certificate.create({
      data: {
        userId: dto.userId,
        courseId: dto.courseId,
        certificateCode: this.generateCertificateCode(),
      },
      include: {
        user: {
          select: { id: true, fullName: true, email: true, role: true },
        },
        course: true,
      },
    });
  }

  async generatePdf(id: string) {
    const certificate = await this.prisma.certificate.findUnique({
      where: { id },
      include: {
        user: true,
        course: true,
      },
    });

    if (!certificate) {
      throw new NotFoundException('Certificate not found.');
    }

    const qrCode = await this.qrService.generateQRCode(
      certificate.certificateCode,
    );

    const pdfUrl = await this.pdfService.generateCertificatePdf({
      learnerName: certificate.user.fullName,
      courseName: certificate.course.title,
      level: certificate.course.level,
      completionDate: certificate.issuedAt.toLocaleDateString(),
      certificateNumber: certificate.certificateCode,
      qrCode,
      instructorName: 'Language Instructor',
      directorName: 'Academic Director',
      organization: 'NdaMinkoaba',
      slogan: 'Learn • Preserve • Transmit',
      logoPath: '',
      backgroundPath: '',
      sealPath: '',
      instructorSignaturePath: '',
      directorSignaturePath: '',
    });

    return this.prisma.certificate.update({
      where: { id },
      data: { pdfUrl },
      include: {
        user: {
          select: { id: true, fullName: true, email: true, role: true },
        },
        course: true,
      },
    });
  }
async verifyCertificate(certificateCode: string) {
  const certificate = await this.prisma.certificate.findUnique({
    where: { certificateCode },
    include: {
      user: {
        select: {
          fullName: true,
          email: true,
        },
      },
      course: {
        include: {
          language: true,
        },
      },
    },
  });

  if (!certificate) {
    throw new NotFoundException('Certificate not found or invalid.');
  }

  return {
    valid: true,
    certificateCode: certificate.certificateCode,
    learnerName: certificate.user.fullName,
    courseName: certificate.course.title,
    level: certificate.course.level,
    language: certificate.course.language.name,
    issuedAt: certificate.issuedAt,
    pdfUrl: certificate.pdfUrl,
    issuer: 'NdaMinkoaba',
  };
}
  async findAll(query: QueryCertificateDto) {
    const { page = 1, limit = 10, userId, courseId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.CertificateWhereInput = {};
    if (userId) where.userId = userId;
    if (courseId) where.courseId = courseId;

    const [certificates, total] = await Promise.all([
      this.prisma.certificate.findMany({
        where,
        skip,
        take: limit,
        orderBy: { issuedAt: 'desc' },
        include: {
          user: {
            select: { id: true, fullName: true, email: true, role: true },
          },
          course: true,
        },
      }),
      this.prisma.certificate.count({ where }),
    ]);

    return {
      items: certificates,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const certificate = await this.prisma.certificate.findUnique({
      where: { id },
      include: {
        user: {
          select: { id: true, fullName: true, email: true, role: true },
        },
        course: true,
      },
    });

    if (!certificate) throw new NotFoundException('Certificate not found.');

    return certificate;
  }

  private assertOwnerOrStaff(
    certificate: { userId: string },
    currentUser: ICurrentUser,
  ) {
    const isOwner = certificate.userId === currentUser.userId;
    const isStaff =
      currentUser.role === UserRole.ADMIN ||
      currentUser.role === UserRole.TEACHER;

    if (!isOwner && !isStaff) {
      throw new ForbiddenException(
        'You do not have access to this certificate.',
      );
    }
  }

  async findOneForUser(id: string, currentUser: ICurrentUser) {
    const certificate = await this.findOne(id);
    this.assertOwnerOrStaff(certificate, currentUser);
    return certificate;
  }

  async generatePdfForUser(id: string, currentUser: ICurrentUser) {
    const certificate = await this.findOne(id);
    this.assertOwnerOrStaff(certificate, currentUser);
    return this.generatePdf(id);
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.certificate.delete({ where: { id } });
  }
}