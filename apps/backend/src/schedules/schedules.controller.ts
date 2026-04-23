import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { SchedulesService } from './schedules.service';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { ScheduleType } from './schedule.entity';

@Controller('schedules')
@UseGuards(JwtAuthGuard)
export class SchedulesController {
  constructor(private readonly service: SchedulesService) {}

  @Post()
  create(@CurrentUser('id') uid: string, @Body() dto: CreateScheduleDto) {
    return this.service.create(uid, dto);
  }

  @Get()
  findAll(@CurrentUser('id') uid: string, @Query() p: PaginationDto, @Query('type') type?: ScheduleType) {
    return this.service.findAll(uid, p, type);
  }

  @Get('upcoming')
  upcoming(@CurrentUser('id') uid: string, @Query('days') days?: number) {
    return this.service.findUpcoming(uid, days);
  }

  @Get(':id')
  findOne(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOne(id, uid);
  }

  @Patch(':id')
  update(@CurrentUser('id') uid: string, @Param('id') id: string, @Body() dto: CreateScheduleDto) {
    return this.service.update(id, uid, dto);
  }

  @Delete(':id')
  remove(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.remove(id, uid);
  }
}