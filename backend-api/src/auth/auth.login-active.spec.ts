import { UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';

import { AuthService } from './auth.service';

describe('AuthService login of deactivated accounts', () => {
  const baseUser = {
    id: 'u1',
    email: 'u@x.com',
    fullName: 'U',
    role: 'LEARNER',
    lastLogin: null,
  };

  function build(isActive: boolean) {
    const passwordHash = bcrypt.hashSync('Correct-Horse-9!', 4);
    const usersService = {
      findByEmail: jest
        .fn()
        .mockResolvedValue({ ...baseUser, passwordHash, isActive }),
      recordLogin: jest.fn(),
    };
    const jwtService = { signAsync: jest.fn().mockResolvedValue('token') };
    return {
      service: new AuthService(usersService as never, jwtService as never),
      usersService,
      jwtService,
    };
  }

  it('rejects a deactivated user with the correct password and issues no token', async () => {
    const { service, jwtService, usersService } = build(false);

    await expect(
      service.login({ email: 'u@x.com', password: 'Correct-Horse-9!' }),
    ).rejects.toBeInstanceOf(UnauthorizedException);
    expect(jwtService.signAsync).not.toHaveBeenCalled();
    expect(usersService.recordLogin).not.toHaveBeenCalled();
  });

  it('still logs in an active user', async () => {
    const { service } = build(true);
    const result = await service.login({
      email: 'u@x.com',
      password: 'Correct-Horse-9!',
    });
    expect(result.accessToken).toBe('token');
  });
});
