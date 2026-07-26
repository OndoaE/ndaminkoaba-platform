import { BadRequestException, Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { OAuth2Client } from 'google-auth-library';
import * as bcrypt from 'bcrypt';
import type { User } from '@prisma/client';

import { UsersService } from '../users/users.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { GoogleLoginDto } from './dto/google-login.dto';

@Injectable()
export class AuthService {
  private readonly googleClient = new OAuth2Client();

  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existingUser = await this.usersService.findByEmail(dto.email);

    if (existingUser) {
      throw new BadRequestException('Email already exists');
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);

    const user = await this.usersService.createUser({
      fullName: dto.fullName,
      email: dto.email,
      passwordHash,
    });

    const { passwordHash: _, ...safeUser } = user;

    return {
      message: 'User registered successfully',
      user: safeUser,
    };
  }

  async login(dto: LoginDto) {
    const user = await this.usersService.findByEmail(dto.email);

    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    if (!user.passwordHash) {
      throw new UnauthorizedException(
        'This account uses Google sign-in. Please continue with that instead.',
      );
    }

    const passwordValid = await bcrypt.compare(dto.password, user.passwordHash);

    if (!passwordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    return this.issueSession(user);
  }

  async loginWithGoogle(dto: GoogleLoginDto) {
    const audience = (process.env.GOOGLE_CLIENT_ID || '')
      .split(',')
      .map((id) => id.trim())
      .filter(Boolean);

    if (audience.length === 0) {
      throw new UnauthorizedException('Google sign-in is not configured yet.');
    }

    let payload: { sub: string; email?: string; name?: string } | undefined;

    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken: dto.idToken,
        audience,
      });
      payload = ticket.getPayload();
    } catch {
      throw new UnauthorizedException('Invalid Google sign-in token.');
    }

    if (!payload?.sub || !payload.email) {
      throw new UnauthorizedException('Invalid Google sign-in token.');
    }

    const user = await this.usersService.findOrCreateOAuthUser({
      provider: 'google',
      providerId: payload.sub,
      email: payload.email,
      fullName: payload.name ?? payload.email,
    });

    return this.issueSession(user);
  }

  private async issueSession(user: User) {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = await this.jwtService.signAsync(payload);

    // `lastLogin` starts out null and is only ever set here, so "never
    // logged in before" is exactly "this is their first successful login" —
    // used by the client to show a one-time welcome screen.
    const isFirstLogin = user.lastLogin === null;
    await this.usersService.recordLogin(user.id);

    const { passwordHash: _, ...safeUser } = user;

    return {
      message: 'Login successful',
      accessToken,
      isFirstLogin,
      user: safeUser,
    };
  }
}