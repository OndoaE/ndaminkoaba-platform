import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';

import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { GoogleLoginDto } from './dto/google-login.dto';
import { FacebookLoginDto } from './dto/facebook-login.dto';
import { JwtAuthGuard } from './guards/jwt-auth/jwt-auth.guard';
import { UserRole } from '@prisma/client';
import { Roles } from './decorators/roles/roles.decorator';
import { RolesGuard } from './guards/roles/roles.guard';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('test')
  test() {
    return {
      message: 'NdaMinkoaba Auth API is running',
    };
  }

  @Post('register')
  register(@Body() dto: RegisterDto) {
    return this.authService.register(dto);
  }

  @Post('login')
  login(@Body() dto: LoginDto) {
    return this.authService.login(dto);
  }

  @Post('google')
  loginWithGoogle(@Body() dto: GoogleLoginDto) {
    return this.authService.loginWithGoogle(dto);
  }

  @Post('facebook')
  loginWithFacebook(@Body() dto: FacebookLoginDto) {
    return this.authService.loginWithFacebook(dto);
  }

  @Get('profile')
  @UseGuards(JwtAuthGuard)
  profile(@Req() req) {
    return {
      message: 'Authenticated user profile',
      user: req.user,
    };
  }
  @Get('admin-test')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
adminTest() {
  return {
    message: 'Admin access granted',
  };
}
}