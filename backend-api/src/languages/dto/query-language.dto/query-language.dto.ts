import { Type } from 'class-transformer';
import { IsBoolean, IsOptional, IsString } from 'class-validator';
import { PaginationDto } from '../../../common/dto/pagination.dto';

export class QueryLanguageDto extends PaginationDto {
  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isActive?: boolean;

  // Adds courseCount/learnerCount/avgProgress to each row (extra queries per
  // language) — opt-in so the learner-facing language picker, which calls
  // this same endpoint far more often, doesn't pay for stats it never uses.
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  includeStats?: boolean;
}