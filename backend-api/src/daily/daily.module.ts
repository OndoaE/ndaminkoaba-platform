import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { DailyController } from './daily.controller';
import { DailyService } from './daily.service';

@Module({
  imports: [PrismaModule],
  controllers: [DailyController],
  providers: [DailyService],
})
export class DailyModule {}
