import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { ChoicesController } from './choices.controller';
import { ChoicesService } from './choices.service';

@Module({
  imports: [PrismaModule],
  controllers: [ChoicesController],
  providers: [ChoicesService],
})
export class ChoicesModule {}