import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

import { PrismaService } from '../../../prisma/prisma.service';

function requireJwtSecret(): string {
  if (!process.env.JWT_SECRET) {
    // Never fall back to a hardcoded secret — that would let anyone forge
    // valid tokens the moment this env var is misconfigured or unset.
    throw new Error('JWT_SECRET environment variable is not set.');
  }
  return process.env.JWT_SECRET;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: requireJwtSecret(),
    });
  }

  /// The token proves who the caller is; the database decides whether that
  /// account may still act, and with which role. Trusting the claims inside
  /// the token alone would let a deactivated, deleted or demoted user keep
  /// their old access until the token expires.
  async validate(payload: { sub: string }) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: { id: true, email: true, role: true, isActive: true },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException('This account is no longer active.');
    }

    return { userId: user.id, email: user.email, role: user.role };
  }
}
