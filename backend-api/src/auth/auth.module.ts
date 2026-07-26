import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import type { SignOptions } from 'jsonwebtoken';

import { UsersModule } from '../users/users.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy/jwt.strategy';

if (!process.env.JWT_SECRET) {
  // Never fall back to a hardcoded secret — that would let anyone forge
  // valid tokens the moment this env var is misconfigured or unset.
  throw new Error('JWT_SECRET environment variable is not set.');
}

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: {
        expiresIn: (process.env.JWT_EXPIRES_IN || '7d') as SignOptions['expiresIn'],
      },
    }),
  ],
  controllers: [AuthController],
  providers: [
    AuthService,
    JwtStrategy,
  ],
  exports: [
    JwtModule,
    PassportModule,
  ],
})
export class AuthModule {}