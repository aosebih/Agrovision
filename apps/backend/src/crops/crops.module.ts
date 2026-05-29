import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Crop } from './crop.entity';
import { CropsService } from './crops.service';
import { CropsController } from './crops.controller';
import { AlertsModule } from '../alerts/alerts.module';
import { WeatherModule } from '../weather/weather.module';
import { IrrigationEvent } from '../irrigation/irrigation-event.entity';
import { Treatment } from '../treatments/treatment.entity';
import { FertilizerApplication } from '../fertilizers/fertilizer-application.entity';
import { Alert } from '../alerts/alert.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([Crop, IrrigationEvent, Treatment, FertilizerApplication, Alert]),
    AlertsModule,
    WeatherModule,
  ],
  controllers: [CropsController],
  providers: [CropsService],
  exports: [CropsService],
})
export class CropsModule {}