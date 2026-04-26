import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AnalyticsService } from './analytics.service';

@Controller('analytics')
@UseGuards(JwtAuthGuard)
export class AnalyticsController {
  constructor(private readonly service: AnalyticsService) {}

  @Get('dashboard')
  dashboard(@CurrentUser('id') uid: string) {
    return this.service.getDashboardSummary(uid);
  }

  @Get('irrigation')
  irrigation(
    @CurrentUser('id') uid: string,
    @Query('from') from = new Date(Date.now() - 30 * 86400000).toISOString(),
    @Query('to') to = new Date().toISOString(),
  ) {
    return this.service.getIrrigationStats(uid, new Date(from), new Date(to));
  }

  @Get('fertilizers')
  fertilizers(
    @CurrentUser('id') uid: string,
    @Query('from') from = new Date(Date.now() - 30 * 86400000).toISOString(),
    @Query('to') to = new Date().toISOString(),
  ) {
    return this.service.getFertilizerUsage(uid, new Date(from), new Date(to));
  }

  @Get('crop-health')
  cropHealth(@CurrentUser('id') uid: string, @Query('fieldId') fieldId?: string) {
    return this.service.getCropHealthTrend(uid, fieldId);
  }

  @Get('alerts')
  alertSummary(@CurrentUser('id') uid: string) {
    return this.service.getAlertSummary(uid);
  }

  @Get('treatments')
  treatments(
    @CurrentUser('id') uid: string,
    @Query('from') from = new Date(Date.now() - 30 * 86400000).toISOString(),
    @Query('to') to = new Date().toISOString(),
  ) {
    return this.service.getTreatmentSummary(uid, new Date(from), new Date(to));
  }
}