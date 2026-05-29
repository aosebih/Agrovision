import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual } from 'typeorm';
import { Schedule, ScheduleType } from './schedule.entity';
import { IrrigationService } from '../irrigation/irrigation.service';
import { AlertsService } from '../alerts/alerts.service';

@Injectable()
export class ScheduleExecutorService {
  private readonly logger = new Logger(ScheduleExecutorService.name);

  constructor(
    @InjectRepository(Schedule) private repo: Repository<Schedule>,
    private irrigationService: IrrigationService,
    private alertsService: AlertsService,
  ) {}

  @Cron(CronExpression.EVERY_MINUTE)
  async executeDueSchedules() {
    const now = new Date();
    const due = await this.repo.find({
      where: { isActive: true, startTime: LessThanOrEqual(now) },
    });

    for (const schedule of due) {
      try {
        await this._execute(schedule);
        if (schedule.recurrence === 'none') {
          schedule.isActive = false;
          await this.repo.save(schedule);
        }
      } catch (err) {
        this.logger.error(
          `Failed to execute schedule ${schedule.id}: ${err.message}`,
        );
      }
    }
  }

  private async _execute(schedule: Schedule) {
    this.logger.log(`Executing: ${schedule.title} (${schedule.type})`);
    if (schedule.type === ScheduleType.IRRIGATION && schedule.zoneId) {
      await this.irrigationService.activateZone(
        schedule.zoneId,
        schedule.userId,
      );
      await this.alertsService.create(schedule.userId, {
        title: 'بدء الري التلقائي',
        message: `تم تشغيل الري تلقائياً وفق جدول "${schedule.title}"`,
        type: 'irrigation',
        severity: 'info',
      });
      return;
    }
    const labels: Record<string, string> = {
      fertilization: 'تسميد',
      treatment: 'معالجة',
      inspection: 'فحص',
      harvest: 'حصاد',
      other: 'مهمة',
    };
    await this.alertsService.create(schedule.userId, {
      title: `حان وقت ${labels[schedule.type] ?? 'المهمة'}`,
      message: schedule.description
        ? `${schedule.title}: ${schedule.description}`
        : `تذكير: ${schedule.title}`,
      type: 'system',
      severity: 'info',
    });
  }
}
