import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Schedule, ScheduleType } from './schedule.entity';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class SchedulesService {
  constructor(@InjectRepository(Schedule) private repo: Repository<Schedule>) {}

  async create(userId: string, dto: any) {
    return this.repo.save(this.repo.create({ ...dto, userId }));
  }

  async findAll(userId: string, p: PaginationDto, type?: ScheduleType) {
    const where: any = { userId };
    if (type) where.type = type;
    const [data, total] = await this.repo.findAndCount({
      where,
      skip: p.skip,
      take: p.limit,
      order: { startTime: 'ASC' },
    });
    return new PaginatedResult(data, total, p.page, p.limit);
  }

  async findUpcoming(userId: string, days = 7) {
    const now = new Date();
    const future = new Date(now.getTime() + days * 86400000);
    return this.repo.find({
      where: { userId, isActive: true, startTime: Between(now, future) },
      order: { startTime: 'ASC' },
    });
  }

  async findOne(id: string, userId: string) {
    const schedule = await this.repo.findOne({ where: { id, userId } });
    if (!schedule) throw new NotFoundException('Schedule not found');
    return schedule;
  }

  async update(id: string, userId: string, dto: any) {
    const schedule = await this.findOne(id, userId);
    Object.assign(schedule, dto);
    return this.repo.save(schedule);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id, userId);
    await this.repo.softDelete(id);
  }
}
