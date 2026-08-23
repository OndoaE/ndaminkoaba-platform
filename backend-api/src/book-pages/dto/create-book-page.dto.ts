import { IsInt, IsOptional, IsString, IsUUID, Min, MinLength } from 'class-validator';

export class CreateBookPageDto {
  @IsUUID()
  bookId: string;

  @IsInt()
  @Min(1)
  orderNumber: number;

  @IsString()
  @MinLength(1)
  ewondoText: string;

  @IsOptional()
  @IsString()
  illustrationUrl?: string;

  @IsOptional()
  @IsString()
  frenchText?: string;

  @IsOptional()
  @IsString()
  audioUrl?: string;
}
