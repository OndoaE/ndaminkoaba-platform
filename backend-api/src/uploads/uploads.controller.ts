import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiBody, ApiConsumes, ApiTags } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { diskStorage } from 'multer';
import { randomUUID } from 'crypto';

import { JwtAuthGuard } from '../auth/guards/jwt-auth/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles/roles.guard';
import { Roles } from '../auth/decorators/roles/roles.decorator';

import {
  assertFileSignature,
  audioExtension,
  documentExtension,
  imageExtension,
} from './upload-validation';

const FILE_BODY = {
  schema: {
    type: 'object',
    properties: {
      file: {
        type: 'string',
        format: 'binary',
      },
    },
  },
} as const;

@ApiTags('Uploads')
@ApiBearerAuth('access-token')
@Controller('uploads')
@UseGuards(JwtAuthGuard)
export class UploadsController {
  /// Any signed-in user may upload an image (learners set a profile photo).
  @Post('image')
  @ApiConsumes('multipart/form-data')
  @ApiBody(FILE_BODY)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/images',
        filename: (_req, file, callback) => {
          callback(
            null,
            `${randomUUID()}${imageExtension(file.mimetype) ?? '.bin'}`,
          );
        },
      }),
      fileFilter: (_req, file, callback) => {
        if (!imageExtension(file.mimetype)) {
          return callback(
            new BadRequestException(
              'Only JPEG, PNG or WebP images are allowed',
            ),
            false,
          );
        }

        callback(null, true);
      },
      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  uploadImage(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }
    assertFileSignature(file.path, 'image');

    return {
      message: 'Image uploaded successfully',
      originalName: file.originalname,
      filename: file.filename,
      mimetype: file.mimetype,
      size: file.size,
      url: `/uploads/images/${file.filename}`,
    };
  }

  /// Books (up to 50 MB) are staff-only: this is the endpoint that can fill
  /// the storage volume, and learners never publish books.
  @Post('document')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.TEACHER)
  @ApiConsumes('multipart/form-data')
  @ApiBody(FILE_BODY)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/books',
        filename: (_req, file, callback) => {
          const extension =
            documentExtension(file.originalname, file.mimetype) ?? '.bin';
          callback(null, `${randomUUID()}${extension}`);
        },
      }),
      fileFilter: (_req, file, callback) => {
        // Extension AND mimetype must both be plausible — either one alone is
        // client-controlled.
        if (!documentExtension(file.originalname, file.mimetype)) {
          return callback(
            new BadRequestException('Only PDF or EPUB files are allowed'),
            false,
          );
        }

        callback(null, true);
      },
      limits: {
        fileSize: 50 * 1024 * 1024,
      },
    }),
  )
  uploadDocument(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }
    assertFileSignature(
      file.path,
      file.filename.endsWith('.epub') ? 'epub' : 'pdf',
    );

    return {
      message: 'Document uploaded successfully',
      originalName: file.originalname,
      filename: file.filename,
      mimetype: file.mimetype,
      size: file.size,
      url: `/uploads/books/${file.filename}`,
    };
  }

  /// Any signed-in user may upload audio (voice messages, pronunciation
  /// attempts); admins also use it for lesson and Bible narration.
  @Post('audio')
  @ApiConsumes('multipart/form-data')
  @ApiBody(FILE_BODY)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads/audio',
        filename: (_req, file, callback) => {
          callback(
            null,
            `${randomUUID()}${audioExtension(file.mimetype) ?? '.bin'}`,
          );
        },
      }),
      fileFilter: (_req, file, callback) => {
        if (!audioExtension(file.mimetype)) {
          return callback(
            new BadRequestException('Unsupported audio format'),
            false,
          );
        }

        callback(null, true);
      },
      limits: {
        fileSize: 10 * 1024 * 1024,
      },
    }),
  )
  uploadAudio(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('No file uploaded');
    }

    return {
      message: 'Audio uploaded successfully',
      originalName: file.originalname,
      filename: file.filename,
      mimetype: file.mimetype,
      size: file.size,
      url: `/uploads/audio/${file.filename}`,
    };
  }
}
