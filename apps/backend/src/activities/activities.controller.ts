import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
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

  @Get(':id')
  findOne(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOne(id, uid);
  }

  @Patch(':id')
  update(@CurrentUser('id') uid: string, @Param('id') id: string, @Body() dto: CreateActivityDto) {
    return this.service.update(id, uid, dto);
  }

  @Delete(':id')
  remove(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.remove(id, uid);
  }
}