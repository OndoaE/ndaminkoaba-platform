import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { UserRole } from '@prisma/client';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { ICurrentUser } from '../common/interfaces/current-user.interface';

import { NnangaService } from './nnanga.service';
import { CreateNnangaChatDto } from './dto/create-nnanga-chat.dto/create-nnanga-chat.dto';
import { QueryNnangaChatDto } from './dto/query-nnanga-chat.dto/query-nnanga-chat.dto';

@Controller('nnanga')
@UseGuards(JwtAuthGuard)
export class NnangaController {
  constructor(private readonly nnangaService: NnangaService) {}

  @Post('chat')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  chat(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateNnangaChatDto,
  ) {
    // Always chat as the authenticated user — never trust a client-supplied userId.
    return this.nnangaService.chat({ ...dto, userId: currentUser.userId });
  }

  @Get('conversations')
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryNnangaChatDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;

    return this.nnangaService.findAll({ ...query, userId });
  }

  @Get('conversations/:id')
  findOne(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.nnangaService.findOneForUser(id, currentUser);
  }
}
