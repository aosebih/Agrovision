import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Schedule } from './schedule.entity';
import { SchedulesService } from './schedules.service';
import { SchedulesController } from './schedules.controller';
import { ScheduleExecutorService } from './schedule-executor.service';
import { IrrigationModule } from '../irrigation/irrigation.module';
import { AlertsModule } from '../alerts/alerts.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Schedule]),
    IrrigationModule,
    AlertsModule,
  ],
  controllers: [SchedulesController],
  providers: [SchedulesService, ScheduleExecutorService],
  exports: [SchedulesService],
})
export class SchedulesModule {}
