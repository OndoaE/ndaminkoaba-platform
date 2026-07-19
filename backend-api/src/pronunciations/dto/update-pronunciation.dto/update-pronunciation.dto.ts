import { PartialType } from '@nestjs/swagger';
import { CreatePronunciationDto } from '../create-pronunciation.dto/create-pronunciation.dto';

export class UpdatePronunciationDto extends PartialType(CreatePronunciationDto) {}