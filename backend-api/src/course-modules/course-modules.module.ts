import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { CourseModulesController } from './course-modules.controller';
import { CourseModulesService } from './course-modules.service';

@Module({
  imports: [PrismaModule],
  controllers: [CourseModulesController],
  providers: [CourseModulesService],
})
export class CourseModulesModule {}