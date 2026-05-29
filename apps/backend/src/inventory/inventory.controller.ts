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
import { InventoryService } from './inventory.service';
import { CreateInventoryItemDto } from './dto/create-inventory-item.dto';
import { PaginationDto } from '../common/dto/pagination.dto';
import { ItemCategory } from './inventory-item.entity';

@Controller('inventory')
@UseGuards(JwtAuthGuard)
export class InventoryController {
  constructor(private readonly service: InventoryService) {}

  @Post()
  create(@CurrentUser('id') uid: string, @Body() dto: CreateInventoryItemDto) {
    return this.service.create(uid, dto);
  }

  // ── NEW: accepts optional ?search=xxx ────────────────────────────────────
  @Get()
  findAll(
    @CurrentUser('id') uid: string,
    @Query() p: PaginationDto,
    @Query('category') cat?: ItemCategory,
    @Query('search') search?: string,
  ) {
    return this.service.findAll(uid, p, cat, search);
  }

  @Get('low-stock')
  lowStock(@CurrentUser('id') uid: string) {
    return this.service.getLowStock(uid);
  }

  @Get(':id')
  findOne(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOne(id, uid);
  }

  @Patch(':id')
  update(
    @CurrentUser('id') uid: string,
    @Param('id') id: string,
    @Body() dto: CreateInventoryItemDto,
  ) {
    return this.service.update(id, uid, dto);
  }

  @Patch(':id/adjust')
  adjust(
    @CurrentUser('id') uid: string,
    @Param('id') id: string,
    @Body('delta') delta: number,
  ) {
    return this.service.adjustStock(id, uid, delta);
  }

  @Delete(':id')
  remove(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.remove(id, uid);
  }
}
