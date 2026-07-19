import { PartialType } from '@nestjs/swagger';
import { CreateQuestionDto } from '../create-question.dto/create-question.dto';

export class UpdateQuestionDto extends PartialType(CreateQuestionDto) {}