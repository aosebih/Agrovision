import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InventoryItem } from './inventory-item.entity';
import { InventoryService } from './inventory.service';
import { InventoryController } from './inventory.controller';
import { AlertsModule } from '../alerts/alerts.module';

@Module({
  imports: [TypeOrmModule.forFeature([InventoryItem]), AlertsModule],
  controllers: [InventoryController],
  providers: [InventoryService],
  exports: [InventoryService],
})
export class InventoryModule {}
