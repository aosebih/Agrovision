import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Treatment, TreatmentStatus } from './treatment.entity';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class TreatmentsService {
  constructor(
    @InjectRepository(Treatment) private repo: Repository<Treatment>,
  ) {}

  async create(userId: string, dto: any) {
    return this.repo.save(this.repo.create({ ...dto, userId }));
  }

  async findAll(
    userId: string,
    p: PaginationDto,
    status?: TreatmentStatus,
    fieldId?: string,
  ) {
    const where: any = { userId };
    if (status) where.status = status;
    if (fieldId) where.fieldId = fieldId;
    const [data, total] = await this.repo.findAndCount({
      where,
      skip: p.skip,
      take: p.limit,
      relations: ['field', 'crop'],
      order: { createdAt: 'DESC' },
    });
    return new PaginatedResult(data, total, p.page, p.limit);
  }

  async findOne(id: string, userId: string) {
    const treatment = await this.repo.findOne({
      where: { id, userId },
      relations: ['field', 'crop'],
    });
    if (!treatment) throw new NotFoundException('Treatment not found');
    return treatment;
  }

  async update(id: string, userId: string, dto: any) {
    const treatment = await this.findOne(id, userId);
    Object.assign(treatment, dto);
    return this.repo.save(treatment);
  }

  async remove(id: string, userId: string) {
    await this.findOne(id, userId);
    await this.repo.softDelete(id);
  }
}
