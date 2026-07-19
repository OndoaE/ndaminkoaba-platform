import { PartialType } from '@nestjs/swagger';
import { CreateKnowledgeTextDto } from '../create-knowledge-text.dto/create-knowledge-text.dto';

export class UpdateKnowledgeTextDto extends PartialType(CreateKnowledgeTextDto) {}
