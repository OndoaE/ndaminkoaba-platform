import { IsUUID } from 'class-validator';

export class CreateCertificateDto {
  @IsUUID()
  userId: string;

  @IsUUID()
  courseId: string;
}