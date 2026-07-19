import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, UserRole } from '@prisma/client';

import { PrismaService } from '../prisma/prisma.service';
import { ICurrentUser } from '../common/interfaces/current-user.interface';
import { CreateNotificationDto } from './dto/create-notification.dto/create-notification.dto';
import { QueryNotificationDto } from './dto/query-notification.dto/query-notification.dto';
import { BroadcastNotificationDto } from './dto/broadcast-notification.dto/broadcast-notification.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateNotificationDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: dto.userId },
    });

    if (!user) {
      throw new BadRequestException('Invalid userId.');
    }

    return this.prisma.notification.create({
      data: dto,
      include: {
        user: {
          select: {
            id: true,
            fullName: true,
            email: true,
            role: true,
          },
        },
      },
    });
  }

  async broadcast(dto: BroadcastNotificationDto) {
    const learners = await this.prisma.user.findMany({
      where: { role: UserRole.LEARNER, isActive: true },
      select: { id: true },
    });

    if (learners.length === 0) {
      return { recipients: 0 };
    }

    await this.prisma.notification.createMany({
      data: learners.map((learner) => ({
        userId: learner.id,
        title: dto.title,
        message: dto.message,
      })),
    });

    return { recipients: learners.length };
  }

  async findAll(query: QueryNotificationDto) {
    const { page = 1, limit = 10, userId, isRead } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.NotificationWhereInput = {};

    if (userId) where.userId = userId;

    if (isRead !== undefined) {
      where.isRead = isRead === 'true';
    }

    const [notifications, total] = await Promise.all([
      this.prisma.notification.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          user: {
            select: {
              id: true,
              fullName: true,
              email: true,
              role: true,
            },
          },
        },
      }),
      this.prisma.notification.count({ where }),
    ]);

    return {
      items: notifications,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: string) {
    const notification = await this.prisma.notification.findUnique({
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
      },
    });

    if (!notification) {
      throw new NotFoundException('Notification not found.');
    }

    return notification;
  }

  async markAsRead(id: string) {
    await this.findOne(id);

    return this.prisma.notification.update({
      where: { id },
      data: { isRead: true },
    });
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.notification.delete({
      where: { id },
    });
  }

  private assertOwnerOrStaff(
    record: { userId: string },
    currentUser: ICurrentUser,
  ) {
    const isOwner = record.userId === currentUser.userId;
    const isStaff =
      currentUser.role === UserRole.ADMIN ||
      currentUser.role === UserRole.TEACHER;

    if (!isOwner && !isStaff) {
      throw new ForbiddenException('You do not have access to this record.');
    }
  }

  async findOneForUser(id: string, currentUser: ICurrentUser) {
    const notification = await this.findOne(id);
    this.assertOwnerOrStaff(notification, currentUser);
    return notification;
  }

  async markAsReadForUser(id: string, currentUser: ICurrentUser) {
    const notification = await this.findOne(id);
    this.assertOwnerOrStaff(notification, currentUser);
    return this.markAsRead(id);
  }
}