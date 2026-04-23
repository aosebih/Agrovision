import { Controller, Get, Post, Patch, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { IrrigationService } from './irrigation.service';
import { CreateZoneDto } from './dto/create-zone.dto';
import { CreateEventDto } from './dto/create-event.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@Controller('irrigation')
@UseGuards(JwtAuthGuard)
export class IrrigationController {
  constructor(private readonly service: IrrigationService) {}

  @Post('zones')
  createZone(@CurrentUser('id') uid: string, @Body() dto: CreateZoneDto) {
    return this.service.createZone(uid, dto);
  }

  @Get('zones')
  findZones(@CurrentUser('id') uid: string, @Query() p: PaginationDto, @Query('fieldId') fieldId?: string) {
    return this.service.findAllZones(uid, p, fieldId);
  }

  @Get('zones/:id')
  findZone(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOneZone(id, uid);
  }

  @Patch('zones/:id')
  updateZone(@CurrentUser('id') uid: string, @Param('id') id: string, @Body() dto: CreateZoneDto) {
    return this.service.updateZone(id, uid, dto);
  }

  @Post('zones/:id/activate')
  activate(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.activateZone(id, uid);
  }

  @Post('zones/:id/stop')
  stop(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.stopZone(id, uid);
  }

  @Post('stop-all')
  stopAll(@CurrentUser('id') uid: string) {
    return this.service.stopAll(uid);
  }

  @Post('events')
  createEvent(@CurrentUser('id') uid: string, @Body() dto: CreateEventDto) {
    return this.service.createEvent(uid, dto);
  }

  @Get('events')
  findEvents(@CurrentUser('id') uid: string, @Query() p: PaginationDto, @Query('zoneId') zoneId?: string) {
    return this.service.findEvents(uid, p, zoneId);
  }
}