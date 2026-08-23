import { PartialType } from '@nestjs/swagger';
import { CreateSyllabaryEntryDto } from './create-syllabary-entry.dto';

export class UpdateSyllabaryEntryDto extends PartialType(CreateSyllabaryEntryDto) {}
