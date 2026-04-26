import { Controller, Get, Post, Patch, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CropsService } from './crops.service';
import { CreateCropDto } from './dto/create-crop.dto';
import { UpdateCropDto } from './dto/update-crop.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@Controller('crops')
@UseGuards(JwtAuthGuard)
export class CropsController {
  constructor(private readonly cropsService: CropsService) {}

  @Post()
  create(@CurrentUser('id') userId: string, @Body() dto: CreateCropDto) {
    return this.cropsService.create(userId, dto);
  }

  @Get()
  findAll(
    @CurrentUser('id') userId: string,
    @Query() pagination: PaginationDto,
    @Query('fieldId') fieldId?: string,
  ) {
    return this.cropsService.findAll(userId, pagination, fieldId);
  }

  @Get(':id')
  findOne(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.cropsService.findOne(id, userId);
  }

  @Patch(':id')
  update(@CurrentUser('id') userId: string, @Param('id') id: string, @Body() dto: UpdateCropDto) {
    return this.cropsService.update(id, userId, dto);
  }

  @Delete(':id')
  remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.cropsService.remove(id, userId);
  }
}