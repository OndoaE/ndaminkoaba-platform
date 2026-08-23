import { IsUUID } from 'class-validator';

export class CreateBookBookmarkDto {
  @IsUUID()
  userId: string;

  @IsUUID()
  bookId: string;
}
