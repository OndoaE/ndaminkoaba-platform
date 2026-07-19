import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Prisma, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { UpdateUserDto } from './dto/update-user.dto/update-user.dto';
import { AdminUpdateUserDto } from './dto/admin-update-user.dto/admin-update-user.dto';
import { AdminCreateUserDto } from './dto/admin-create-user.dto/admin-create-user.dto';
import { QueryUserDto } from './dto/query-user.dto/query-user.dto';
import { normalizeEmail } from '../common/utils/helpers';

type OAuthProvider = 'google' | 'facebook';

const SAFE_USER_SELECT = {
  id: true,
  fullName: true,
  email: true,
  role: true,
  isActive: true,
  createdAt: true,
  updatedAt: true,
} as const;

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email: normalizeEmail(email) },
    });
  }

  async findSafeById(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: SAFE_USER_SELECT,
    });

    if (!user) {
      throw new NotFoundException('User not found.');
    }

    return user;
  }

  async createUser(data: {
    fullName: string;
    email: string;
    passwordHash: string;
    role?: UserRole;
  }) {
    return this.prisma.user.create({
      data: {
        fullName: data.fullName,
        email: normalizeEmail(data.email),
        passwordHash: data.passwordHash,
        role: data.role ?? UserRole.LEARNER,
      },
    });
  }

  /**
   * Shared by `POST /auth/google` and `POST /auth/facebook`. Looks up by the
   * provider's own id first (fast path for repeat OAuth logins), then falls
   * back to email so a learner who already has a password account doesn't
   * end up with a second, disconnected account just because they tried the
   * OAuth button once — the provider id gets linked onto their existing
   * account instead. Only creates a brand-new user if neither matches.
   */
  async findOrCreateOAuthUser(params: {
    provider: OAuthProvider;
    providerId: string;
    email: string;
    fullName: string;
  }) {
    const email = normalizeEmail(params.email);
    const providerData: { googleId: string } | { facebookId: string } =
      params.provider === 'google'
        ? { googleId: params.providerId }
        : { facebookId: params.providerId };

    const existingByProvider = await this.prisma.user.findUnique({
      where:
        params.provider === 'google'
          ? { googleId: params.providerId }
          : { facebookId: params.providerId },
    });

    if (existingByProvider) {
      return existingByProvider;
    }

    const existingByEmail = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingByEmail) {
      return this.prisma.user.update({
        where: { id: existingByEmail.id },
        data: providerData,
      });
    }

    return this.prisma.user.create({
      data: {
        fullName: params.fullName,
        email,
        role: UserRole.LEARNER,
        ...providerData,
      },
    });
  }

  async recordLogin(id: string) {
    return this.prisma.user.update({
      where: { id },
      data: { lastLogin: new Date() },
    });
  }

  async updateSelf(id: string, dto: UpdateUserDto) {
    const data: { fullName?: string; passwordHash?: string } = {};

    if (dto.fullName) {
      data.fullName = dto.fullName;
    }

    if (dto.password) {
      data.passwordHash = await bcrypt.hash(dto.password, 10);
    }

    await this.findSafeById(id);

    return this.prisma.user.update({
      where: { id },
      data,
      select: SAFE_USER_SELECT,
    });
  }

  async findAll(query: QueryUserDto) {
    const { page = 1, limit = 20, role, search } = query;
    const skip = (page - 1) * limit;

    const where: Prisma.UserWhereInput = {};
    if (role) where.role = role;
    if (search) {
      where.OR = [
        { fullName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [items, total] = await Promise.all([
      this.prisma.user.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: SAFE_USER_SELECT,
      }),
      this.prisma.user.count({ where }),
    ]);

    return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async adminCreate(dto: AdminCreateUserDto) {
    const existing = await this.findByEmail(dto.email);

    if (existing) {
      throw new BadRequestException('Email already exists.');
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);

    return this.prisma.user.create({
      data: {
        fullName: dto.fullName,
        email: normalizeEmail(dto.email),
        passwordHash,
        role: dto.role ?? UserRole.LEARNER,
      },
      select: SAFE_USER_SELECT,
    });
  }

  async adminUpdate(id: string, dto: AdminUpdateUserDto) {
    await this.findSafeById(id);

    return this.prisma.user.update({
      where: { id },
      data: {
        fullName: dto.fullName,
        role: dto.role,
        isActive: dto.isActive,
      },
      select: SAFE_USER_SELECT,
    });
  }
}