import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ContentWorkflowController } from './content-workflow.controller';
import { ContentWorkflowService } from './content-workflow.service';

@Module({
  imports: [PrismaModule],
  controllers: [ContentWorkflowController],
  providers: [ContentWorkflowService],
})
export class ContentWorkflowModule {}
