import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { FieldsService } from './fields.service';
import { CreateFieldDto } from './dto/create-field.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@Controller('fields')
@UseGuards(JwtAuthGuard)
export class FieldsController {
  constructor(private readonly fieldsService: FieldsService) {}

  @Post()
  create(@CurrentUser('id') userId: string, @Body() dto: CreateFieldDto) {
    return this.fieldsService.create(userId, dto);
  }

  @Get()
  findAll(
    @CurrentUser('id') userId: string,
    @Query() pagination: PaginationDto,
  ) {
    return this.fieldsService.findAll(userId, pagination);
  }

  @Get(':id')
  findOne(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.fieldsService.findOne(id, userId);
  }

  @Patch(':id')
  update(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: CreateFieldDto,
  ) {
    return this.fieldsService.update(id, userId, dto);
  }

  @Delete(':id')
  remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.fieldsService.remove(id, userId);
  }

  // ── Photo sub-resource ────────────────────────────────────────────────────
  @Post(':id/photos')
  addPhoto(
    @CurrentUser('id') uid: string,
    @Param('id') fieldId: string,
    @Body() dto: { url: string; caption?: string },
  ) {
    return this.fieldsService.addPhoto(fieldId, uid, dto.url, dto.caption);
  }

  @Get(':id/photos')
  getPhotos(@CurrentUser('id') uid: string, @Param('id') fieldId: string) {
    return this.fieldsService.getPhotos(fieldId, uid);
  }

  @Delete('photos/:photoId')
  deletePhoto(
    @CurrentUser('id') uid: string,
    @Param('photoId') photoId: string,
  ) {
    return this.fieldsService.deletePhoto(photoId, uid);
  }
}
