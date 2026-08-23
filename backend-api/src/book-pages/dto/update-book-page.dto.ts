import { PartialType } from '@nestjs/swagger';

import { CreateBookPageDto } from './create-book-page.dto';

export class UpdateBookPageDto extends PartialType(CreateBookPageDto) {}
