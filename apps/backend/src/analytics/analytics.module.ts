import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Crop } from '../crops/crop.entity';
import { IrrigationEvent } from '../irrigation/irrigation-event.entity';
import { FertilizerApplication } from '../fertilizers/fertilizer-application.entity';
import { Alert } from '../alerts/alert.entity';
import { Treatment } from '../treatments/treatment.entity';
import { InventoryItem } from '../inventory/inventory-item.entity';
import { AnalyticsService } from './analytics.service';
import { AnalyticsController } from './analytics.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Crop, IrrigationEvent, FertilizerApplication, Alert, Treatment, InventoryItem])],
  controllers: [AnalyticsController],
  providers: [AnalyticsService],
})
export class AnalyticsModule {}