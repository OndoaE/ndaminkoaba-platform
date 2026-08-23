import { IsInt, IsUUID, Min } from 'class-validator';

export class CreateBookProgressDto {
  @IsUUID()
  userId: string;

  @IsUUID()
  bookId: string;

  @IsInt()
  @Min(1)
  lastPageNumber: number;
}
