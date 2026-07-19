import {
  Body,
  Controller,
  Delete,
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

import { CertificatesService } from './certificates.service';
import { CreateCertificateDto } from './dto/create-certificate.dto/create-certificate.dto';
import { QueryCertificateDto } from './dto/query-certificate.dto/query-certificate.dto';

@Controller('certificates')
export class CertificatesController {
  constructor(private readonly certificatesService: CertificatesService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER, UserRole.LEARNER)
  create(
    @CurrentUser() currentUser: ICurrentUser,
    @Body() dto: CreateCertificateDto,
  ) {
    // Learners can only ever issue a certificate for themselves; admins/teachers
    // may issue on behalf of any learner (e.g. manual override).
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : dto.userId;

    return this.certificatesService.create({ ...dto, userId });
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  findAll(
    @CurrentUser() currentUser: ICurrentUser,
    @Query() query: QueryCertificateDto,
  ) {
    const userId =
      currentUser.role === UserRole.LEARNER ? currentUser.userId : query.userId;

    return this.certificatesService.findAll({ ...query, userId });
  }

  @Get('verify/:certificateCode')
  verify(@Param('certificateCode') certificateCode: string) {
    return this.certificatesService.verifyCertificate(certificateCode);
  }

  @Get(':id')
  @UseGuards(JwtAuthGuard)
  findOne(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.certificatesService.findOneForUser(id, currentUser);
  }

  @Post(':id/generate-pdf')
  @UseGuards(JwtAuthGuard)
  generatePdf(@CurrentUser() currentUser: ICurrentUser, @Param('id') id: string) {
    return this.certificatesService.generatePdfForUser(id, currentUser);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  remove(@Param('id') id: string) {
    return this.certificatesService.remove(id);
  }
}
