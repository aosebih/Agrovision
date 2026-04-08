import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { InventoryItem, ItemCategory } from './inventory-item.entity';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class InventoryService {
  constructor(@InjectRepository(InventoryItem) private repo: Repository<InventoryItem>) {}

  async create(userId: string, dto: CreateInventoryItemDto) {
    return this.repo.save(this.repo.create({ ...dto, userId }));
  }

  async findAll(userId: string, p: PaginationDto, category?: ItemCategory) {
    const where: any = { userId };
    if (category) where.category = category;
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

  async update(id: string, userId: string, dto: Partial<CreateInventoryItemDto>) {
    const item = await this.findOne(id, userId);
    Object.assign(item, dto);
    return this.repo.save(item);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id, userId);
    await this.repo.softDelete(id);
  }

  async adjustStock(id: string, userId: string, delta: number) {
    const item = await this.findOne(id, userId);
    item.quantity = Number(item.quantity) + delta;
    if (item.quantity < 0) item.quantity = 0;
    return this.repo.save(item);
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