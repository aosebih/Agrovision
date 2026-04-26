import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { AlertsService } from './alerts.service';
import { CreateAlertDto } from './dto/create-alert.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { AlertType, AlertSeverity } from './alert.entity';

@Controller('alerts')
@UseGuards(JwtAuthGuard)
export class AlertsController {
  constructor(private readonly service: AlertsService) {}

  @Post()
  create(@CurrentUser('id') uid: string, @Body() dto: CreateAlertDto) {
    return this.service.create(uid, dto);
  }

  @Get()
  findAll(
    @CurrentUser('id') uid: string,
    @Query() p: PaginationDto,
    @Query('type') type?: AlertType,
    @Query('severity') severity?: AlertSeverity,
    @Query('unreadOnly') unreadOnly?: string,
  ) {
    return this.service.findAll(uid, p, type, severity, unreadOnly === 'true');
  }

  @Get('unread-count')
  unreadCount(@CurrentUser('id') uid: string) {
    return this.service.getUnreadCount(uid);
  }

  @Patch('mark-all-read')
  markAllRead(@CurrentUser('id') uid: string) {
    return this.service.markAllRead(uid);
  }

  @Get(':id')
  findOne(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOne(id, uid);
  }

  @Patch(':id/read')
  markRead(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.markRead(id, uid);
  }

  @Patch(':id/acknowledge')
  acknowledge(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.acknowledge(id, uid);
  }
}