import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Res,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { Response } from 'express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ActivitiesService } from './activities.service';
import { CreateActivityDto } from './dto/create-activity.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { ActivityType } from './activity.entity';

@Controller('activities')
@UseGuards(JwtAuthGuard)
export class ActivitiesController {
  constructor(private readonly service: ActivitiesService) {}

  @Post()
  create(@CurrentUser('id') uid: string, @Body() dto: CreateActivityDto) {
    return this.service.create(uid, dto);
  }

  @Get()
  findAll(
    @CurrentUser('id') uid: string,
    @Query() p: PaginationDto,
    @Query('type') type?: ActivityType,
    @Query('fieldId') fieldId?: string,
    @Query('cropId') cropId?: string,
  ) {
    return this.service.findAll(uid, p, type, fieldId, cropId);
  }

  // ── NEW: export all activities as CSV ────────────────────────────────────
  @Get('export/csv')
  async exportCsv(@CurrentUser('id') uid: string, @Res() res: Response) {
    const rows = await this.service.exportAll(uid);
    const header = 'التاريخ,النوع,الوصف,الحقل,المحصول\n';
    const body = rows
      .map((r) =>
        [
          r.performedAt?.toISOString().split('T')[0] ?? '',
          r.type ?? '',
          (r.description ?? '').replace(/,/g, '،'),
          '',
          '',
        ].join(','),
      )
      .join('\n');
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader(
      'Content-Disposition',
      'attachment; filename="activities.csv"',
    );
    res.send('\uFEFF' + header + body); // BOM for Excel Arabic support
  }

  @Get(':id')
  findOne(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOne(id, uid);
  }

  @Patch(':id')
  update(
    @CurrentUser('id') uid: string,
    @Param('id') id: string,
    @Body() dto: CreateActivityDto,
  ) {
    return this.service.update(id, uid, dto);
  }

  @Delete(':id')
  remove(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.remove(id, uid);
  }
}
