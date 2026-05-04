import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Crop } from '../crops/crop.entity';
import { IrrigationEvent } from '../irrigation/irrigation-event.entity';
import { FertilizerApplication } from '../fertilizers/fertilizer-application.entity';
import { Alert } from '../alerts/alert.entity';
import { Treatment } from '../treatments/treatment.entity';
import { InventoryItem } from '../inventory/inventory-item.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(Crop) private cropRepo: Repository<Crop>,
    @InjectRepository(IrrigationEvent) private irrRepo: Repository<IrrigationEvent>,
    @InjectRepository(FertilizerApplication) private fertAppRepo: Repository<FertilizerApplication>,
    @InjectRepository(Alert) private alertRepo: Repository<Alert>,
    @InjectRepository(Treatment) private treatRepo: Repository<Treatment>,
    @InjectRepository(InventoryItem) private invRepo: Repository<InventoryItem>,
  ) {}

  async getDashboardSummary(userId: string) {
    const [totalCrops, totalIrrEvents, unreadAlerts, lowStockItems] = await Promise.all([
      this.cropRepo.count({ where: { userId } }),
      this.irrRepo.count({ where: { userId } }),
      this.alertRepo.count({ where: { userId, isRead: false } }),
      this.invRepo
        .createQueryBuilder('i')
        .where('i.user_id = :userId', { userId })
        .andWhere('i."minStockLevel" IS NOT NULL')
        .andWhere('i.quantity <= i."minStockLevel"')
        .getCount(),
    ]);

    const cropHealthAvg = await this.cropRepo
      .createQueryBuilder('c')
      .select('AVG(c."healthScore")', 'avg')
      .where('c.user_id = :userId', { userId })
      .getRawOne();

    return {
      totalCrops,
      totalIrrigationEvents: totalIrrEvents,
      unreadAlerts,
      lowStockItems,
      averageCropHealth: Number(cropHealthAvg?.avg || 0).toFixed(1),
    };
  }

  async getIrrigationStats(userId: string, from: Date, to: Date) {
    const events = await this.irrRepo.find({
      where: { userId, startedAt: Between(from, to) },
      relations: ['zone'],
    });

    const totalWater = events.reduce((sum, e) => sum + Number(e.waterUsedLiters || 0), 0);
    const totalDuration = events.reduce((sum, e) => sum + Number(e.durationMinutes || 0), 0);

    return {
      totalEvents: events.length,
      totalWaterLiters: totalWater,
      totalDurationMinutes: totalDuration,
      averageWaterPerEvent: events.length ? (totalWater / events.length).toFixed(2) : 0,
    };
  }

  async getFertilizerUsage(userId: string, from: Date, to: Date) {
    const apps = await this.fertAppRepo.find({
      where: { userId, appliedAt: Between(from, to) },
      relations: ['fertilizer', 'field'],
    });

    const byFertilizer = apps.reduce((acc, a) => {
      const name = a.fertilizer?.name || 'Unknown';
      if (!acc[name]) acc[name] = { total: 0, unit: a.unit };
      acc[name].total += Number(a.quantity);
      return acc;
    }, {} as Record<string, any>);

    return { totalApplications: apps.length, byFertilizer };
  }

  async getCropHealthTrend(userId: string, fieldId?: string) {
    const where: any = { userId };
    if (fieldId) where.fieldId = fieldId;
    const crops = await this.cropRepo.find({ 
      where, 
      select: ['id', 'name', 'healthScore', 'growthStage', 'status'] 
    });
    return crops;
  }

  async getAlertSummary(userId: string) {
    const result = await this.alertRepo
      .createQueryBuilder('a')
      .select('a.type', 'type')
      .addSelect('a.severity', 'severity')
      .addSelect('COUNT(*)', 'count')
      .where('a.user_id = :userId', { userId })
      .groupBy('a.type')
      .addGroupBy('a.severity')
      .getRawMany();
    return result;
  }

  async getTreatmentSummary(userId: string, from: Date, to: Date) {
    const treatments = await this.treatRepo.find({
      where: { userId },
      relations: ['field'],
    });

    const byType = treatments.reduce((acc, t) => {
      if (!acc[t.type]) acc[t.type] = 0;
      acc[t.type]++;
      return acc;
    }, {} as Record<string, number>);

    return { total: treatments.length, byType };
  }
}