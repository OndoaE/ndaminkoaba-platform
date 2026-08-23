import { ArrayNotEmpty, IsArray, IsUUID } from 'class-validator';

export class ReorderBookPagesDto {
  @IsUUID()
  bookId: string;

  // Page ids in their new display order — orderNumber becomes index+1.
  @IsArray()
  @ArrayNotEmpty()
  @IsUUID('4', { each: true })
  orderedIds: string[];
}
