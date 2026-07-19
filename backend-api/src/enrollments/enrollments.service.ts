import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { EnrollmentStatus, Prisma, UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';
import { CreateEnrollmentDto } from './dto/create-enrollment.dto/create-enrollment.dto';
import { QueryEnrollmentDto } from './dto/query-enrollment.dto/query-enrollment.dto';
import { UpdateEnrollmentDto } from './dto/update-enrollment.dto/update-enrollment.dto';

@Injectable()
export class EnrollmentsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateEnrollmentDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) {
      throw new BadRequestException('Invalid userId.');
    }

    const course = await this.prisma.course.findUnique({
      where: { id: dto.courseId },
    });

    if (!course) {
      throw new BadRequestException('Invalid courseId.');
    }

    const exists = await this.prisma.enrollment.findUnique({
      where: {
        userId_courseId: {
          userId: dto.userId,
          courseId: dto.courseId,
        },
      },
    });

    if (exists) {
      throw new ConflictException('User is already enrolled in this course.');
    }

    return this.prisma.enrollment.create({
      data: {
        userId: dto.userId,
        courseId: dto.courseId,
        status: EnrollmentStatus.ACTIVE,
        progress: 0,
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        course: {
          include: {
            language: true,
          },
        },
      },
    });
  }

  async findAll(query: QueryEnrollmentDto) {
    const { page = 1, limit = 10, userId, courseId } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.EnrollmentWhereInput = {};

    if (userId) where.userId = userId;
    if (courseId) where.courseId = courseId;

    const [enrollments, total] = await Promise.all([
      this.prisma.enrollment.findMany({
        where,
        skip,
        take: limit,
        orderBy: { startedAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
          course: {
            include: {
              language: true,
              modules: {
                include: {
                  lessons: true,
                },
              },
            },
          },
        },
      }),
      this.prisma.enrollment.count({ where }),
    ]);

    return {
      items: enrollments,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const enrollment = await this.prisma.enrollment.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        course: {
          include: {
            language: true,
            modules: {
              include: {
                lessons: true,
              },
            },
          },
        },
      },
    });

    if (!enrollment) {
      throw new NotFoundException('Enrollment not found.');
    }

    return enrollment;
  }

  async update(id: string, dto: UpdateEnrollmentDto) {
    await this.findOne(id);

    return this.prisma.enrollment.update({
      where: { id },
      data: {
        status: dto.status,
        progress: dto.progress,
        completedAt:
          dto.status === EnrollmentStatus.COMPLETED ? new Date() : null,
      },
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
        course: true,
      },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.enrollment.delete({
      where: { id },
    });
  }

  async findOneForUser(id: string, currentUser: ICurrentUser) {
    const enrollment = await this.findOne(id);

    const isOwner = enrollment.userId === currentUser.userId;
    const isStaff =
      currentUser.role === UserRole.ADMIN ||
      currentUser.role === UserRole.TEACHER;

    if (!isOwner && !isStaff) {
      throw new ForbiddenException('You do not have access to this record.');
    }

    return enrollment;
  }
}