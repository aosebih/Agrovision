import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IrrigationZone } from './irrigation-zone.entity';
import { IrrigationEvent } from './irrigation-event.entity';
import { IrrigationService } from './irrigation.service';
import { IrrigationController } from './irrigation.controller';

@Module({
  imports: [TypeOrmModule.forFeature([IrrigationZone, IrrigationEvent])],
  controllers: [IrrigationController],
  providers: [IrrigationService],
  exports: [IrrigationService],
})
export class IrrigationModule {}