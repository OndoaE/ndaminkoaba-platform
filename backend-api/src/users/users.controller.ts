import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { Audited } from '../audit-log/decorators/audited.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';

import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto/update-user.dto';
import { AdminUpdateUserDto } from './dto/admin-update-user.dto/admin-update-user.dto';
import { AdminCreateUserDto } from './dto/admin-create-user.dto/admin-create-user.dto';
import { QueryUserDto } from './dto/query-user.dto/query-user.dto';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getMe(@CurrentUser() currentUser: { userId: string }) {
    return this.usersService.findSafeById(currentUser.userId);
  }

  @Patch('me')
  updateMe(
    @CurrentUser() currentUser: { userId: string },
    @Body() dto: UpdateUserDto,
  ) {
    return this.usersService.updateSelf(currentUser.userId, dto);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  findAll(@Query() query: QueryUserDto) {
    return this.usersService.findAll(query);
  }

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @Audited('User')
  adminCreate(@Body() dto: AdminCreateUserDto) {
    return this.usersService.adminCreate(dto);
  }

  @Get(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  findOne(@Param('id') id: string) {
    return this.usersService.findSafeById(id);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @Audited('User')
  adminUpdate(@Param('id') id: string, @Body() dto: AdminUpdateUserDto) {
    return this.usersService.adminUpdate(id, dto);
  }
}
