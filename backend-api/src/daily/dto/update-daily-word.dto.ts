import { PartialType } from '@nestjs/swagger';
import { CreateDailyWordDto } from './create-daily-word.dto';

export class UpdateDailyWordDto extends PartialType(CreateDailyWordDto) {}
