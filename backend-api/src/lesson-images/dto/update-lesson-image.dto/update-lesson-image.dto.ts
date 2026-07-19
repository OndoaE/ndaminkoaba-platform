import { PartialType } from '@nestjs/swagger';
import { CreateLessonImageDto } from '../create-lesson-image.dto/create-lesson-image.dto';

export class UpdateLessonImageDto extends PartialType(CreateLessonImageDto) {}
