import { UnauthorizedException } from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtStrategy } from './jwt.strategy';

describe('JwtStrategy.validate', () => {
  const previousSecret = process.env.JWT_SECRET;
  let findUnique: jest.Mock;
  let strategy: JwtStrategy;

  beforeAll(() => {
    process.env.JWT_SECRET = 'test-secret';
  });
  afterAll(() => {
    process.env.JWT_SECRET = previousSecret;
  });

  beforeEach(() => {
    findUnique = jest.fn();
    strategy = new JwtStrategy({ user: { findUnique } } as never);
  });

  it('accepts an active user and uses the role from the database, not the token', async () => {
    findUnique.mockResolvedValue({
      id: 'u1',
      email: 'u@x.com',
      role: UserRole.LEARNER,
      isActive: true,
    });

    // A stale token still claiming ADMIN must not confer ADMIN.
    const result = await strategy.validate({
      sub: 'u1',
      role: 'ADMIN',
    } as never);

    expect(result).toEqual({
      userId: 'u1',
      email: 'u@x.com',
      role: UserRole.LEARNER,
    });
  });

  it('rejects a deactivated user even though their token is still valid', async () => {
    findUnique.mockResolvedValue({
      id: 'u1',
      email: 'u@x.com',
      role: UserRole.LEARNER,
      isActive: false,
    });
    await expect(strategy.validate({ sub: 'u1' })).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('rejects a token whose user has been deleted', async () => {
    findUnique.mockResolvedValue(null);
    await expect(strategy.validate({ sub: 'gone' })).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });
});
