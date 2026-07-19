import { IsEnum, IsInt, Max, Min } from 'class-validator';
import { EnrollmentStatus } from '@prisma/client';

export class UpdateEnrollmentDto {
  @IsEnum(EnrollmentStatus)
  status: EnrollmentStatus;

  @IsInt()
  @Min(0)
  @Max(100)
  progress: number;
}