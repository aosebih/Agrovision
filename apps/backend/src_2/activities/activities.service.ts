import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Activity, ActivityType } from './activity.entity';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class ActivitiesService {
  constructor(@InjectRepository(Activity) private repo: Repository<Activity>) {}

  async create(userId: string, dto: any) {
    return this.repo.save(this.repo.create({ ...dto, userId }));
  }

  async findAll(userId: string, p: PaginationDto, type?: ActivityType, fieldId?: string, cropId?: string) {
    const where: any = { userId };
    if (type) where.type = type;
    if (fieldId) where.fieldId = fieldId;
    if (cropId) where.cropId = cropId;
    const [data, total] = await this.repo.findAndCount({
      where,
      skip: p.skip,
      take: p.limit,
      order: { performedAt: 'DESC' },
    });
    return new PaginatedResult(data, total, p.page, p.limit);
  }

  async findOne(id: string, userId: string) {
    const activity = await this.repo.findOne({ where: { id, userId } });
    if (!activity) throw new NotFoundException('Activity not found');
    return activity;
  }

  async update(id: string, userId: string, dto: any) {
    const activity = await this.findOne(id, userId);
    Object.assign(activity, dto);
    return this.repo.save(activity);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id, userId);
    await this.repo.softDelete(id);
  }
}