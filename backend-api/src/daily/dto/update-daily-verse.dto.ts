import { PartialType } from '@nestjs/swagger';
import { CreateDailyVerseDto } from './create-daily-verse.dto';

export class UpdateDailyVerseDto extends PartialType(CreateDailyVerseDto) {}
