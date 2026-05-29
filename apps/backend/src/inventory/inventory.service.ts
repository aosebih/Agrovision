import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { InventoryItem, ItemCategory } from './inventory-item.entity';
import { CreateInventoryItemDto } from './dto/create-inventory-item.dto';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';
import { AlertsService } from '../alerts/alerts.service';

@Injectable()
export class InventoryService {
  constructor(
    @InjectRepository(InventoryItem) private repo: Repository<InventoryItem>,
    private readonly alertsService: AlertsService,
  ) {}

  async create(userId: string, dto: CreateInventoryItemDto) {
    return this.repo.save(this.repo.create({ ...dto, userId }));
  }

  // ── NEW: optional name search via ?search= ────────────────────────────────
  async findAll(
    userId: string,
    p: PaginationDto,
    category?: ItemCategory,
    search?: string,
  ) {
    const where: any = { userId };
    if (category) where.category = category;
    if (search) where.name = ILike(`%${search}%`);
    const [data, total] = await this.repo.findAndCount({
      where,
      skip: p.skip,
      take: p.limit,
      order: { name: 'ASC' },
    });
    return new PaginatedResult(data, total, p.page, p.limit);
  }

  async findOne(id: string, userId: string) {
    const item = await this.repo.findOne({ where: { id, userId } });
    if (!item) throw new NotFoundException('Inventory item not found');
    return item;
  }

  async update(
    id: string,
    userId: string,
    dto: Partial<CreateInventoryItemDto>,
  ) {
    const item = await this.findOne(id, userId);
    Object.assign(item, dto);
    return this.repo.save(item);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id, userId);
    await this.repo.softDelete(id);
  }

  // ── adjustStock — auto-triggers low-stock alert ───────────────────────────
  async adjustStock(id: string, userId: string, delta: number) {
    const item = await this.findOne(id, userId);
    item.quantity = Number(item.quantity) + delta;
    if (item.quantity < 0) item.quantity = 0;
    const saved = await this.repo.save(item);

    if (saved.minStockLevel != null && saved.quantity <= saved.minStockLevel) {
      await this.alertsService.create(userId, {
        title: 'مخزون منخفض',
        message: `${saved.name}: الكمية المتبقية (${saved.quantity} ${saved.unit ?? ''}) وصلت إلى الحد الأدنى`,
        type: 'inventory',
        severity: saved.quantity === 0 ? 'critical' : 'warning',
      });
    }
    return saved;
  }

  async getLowStock(userId: string) {
    return this.repo
      .createQueryBuilder('item')
      .where('item.user_id = :userId', { userId })
      .andWhere('item.min_stock_level IS NOT NULL')
      .andWhere('item.quantity <= item.min_stock_level')
      .getMany();
  }
}
