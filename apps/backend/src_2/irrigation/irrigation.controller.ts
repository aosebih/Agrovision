import { Controller, Get, Post, Put, Body, Param, Query, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { IrrigationService } from './irrigation.service';
import { CreateZoneDto } from './dto/create-zone.dto';
import { CreateEventDto } from './dto/create-event.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@Controller('irrigation')
@UseGuards(JwtAuthGuard)
export class IrrigationController {
  constructor(private readonly irrigationService: IrrigationService) {}

  @Post('zones')
  createZone(@Req() req: any, @Body() dto: CreateZoneDto) {
    return this.irrigationService.createZone(req.user.id, dto);
  }

  @Get('zones')
  findAllZones(@Req() req: any, @Query() pagination: PaginationDto, @Query('fieldId') fieldId?: string) {
    return this.irrigationService.findAllZones(req.user.id, pagination, fieldId);
  }

  @Get('zones/:id')
  findOneZone(@Req() req: any, @Param('id') id: string) {
    return this.irrigationService.findOneZone(id, req.user.id);
  }

  @Put('zones/:id')
  updateZone(@Req() req: any, @Param('id') id: string, @Body() dto: Partial<CreateZoneDto>) {
    return this.irrigationService.updateZone(id, req.user.id, dto);
  }

  @Post('zones/:id/activate')
  activateZone(@Req() req: any, @Param('id') id: string) {
    return this.irrigationService.activateZone(id, req.user.id);
  }

  @Post('zones/:id/stop')
  stopZone(@Req() req: any, @Param('id') id: string) {
    return this.irrigationService.stopZone(id, req.user.id);
  }

  @Post('stop-all')
  stopAll(@Req() req: any) {
    return this.irrigationService.stopAll(req.user.id);
  }

  @Post('events')
  createEvent(@Req() req: any, @Body() dto: CreateEventDto) {
    return this.irrigationService.createEvent(req.user.id, dto);
  }

  @Get('events')
  findEvents(@Req() req: any, @Query() pagination: PaginationDto, @Query('zoneId') zoneId?: string) {
    return this.irrigationService.findEvents(req.user.id, pagination, zoneId);
  }
}
