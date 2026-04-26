import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { TreatmentsService } from './treatments.service';
import { CreateTreatmentDto } from './dto/create-treatment.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { TreatmentStatus } from './treatment.entity';

@Controller('treatments')
@UseGuards(JwtAuthGuard)
export class TreatmentsController {
  constructor(private readonly service: TreatmentsService) {}

  @Post()
  create(@CurrentUser('id') uid: string, @Body() dto: CreateTreatmentDto) {
    return this.service.create(uid, dto);
  }

  @Get()
  findAll(
    @CurrentUser('id') uid: string,
    @Query() p: PaginationDto,
    @Query('status') status?: TreatmentStatus,
    @Query('fieldId') fieldId?: string,
  ) {
    return this.service.findAll(uid, p, status, fieldId);
  }

  @Get(':id')
  findOne(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOne(id, uid);
  }

  @Patch(':id')
  update(@CurrentUser('id') uid: string, @Param('id') id: string, @Body() dto: CreateTreatmentDto) {
    return this.service.update(id, uid, dto);
  }

  @Delete(':id')
  remove(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.remove(id, uid);
  }
}