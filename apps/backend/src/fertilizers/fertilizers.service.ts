import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Fertilizer } from './fertilizer.entity';
import { FertilizerApplication } from './fertilizer-application.entity';
import { CreateFertilizerDto } from './dto/create-fertilizer.dto';
import { CreateApplicationDto } from './dto/create-application.dto';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class FertilizersService {
  constructor(
    @InjectRepository(Fertilizer) private fertRepo: Repository<Fertilizer>,
    @InjectRepository(FertilizerApplication) private appRepo: Repository<FertilizerApplication>,
  ) {}

  async createFertilizer(userId: string, dto: CreateFertilizerDto) {
    return this.fertRepo.save(this.fertRepo.create({ ...dto, userId }));
  }

  async findAllFertilizers(userId: string, pagination: PaginationDto) {
    const [data, total] = await this.fertRepo.findAndCount({
      where: { userId }, skip: pagination.skip, take: pagination.limit,
    });
    return new PaginatedResult(data, total, pagination.page, pagination.limit);
  }

  async findOneFertilizer(id: string, userId: string) {
    const f = await this.fertRepo.findOne({ where: { id, userId } });
    if (!f) throw new NotFoundException('Fertilizer not found');
    return f;
  }

  async updateFertilizer(id: string, userId: string, dto: Partial<CreateFertilizerDto>) {
    const f = await this.findOneFertilizer(id, userId);
    Object.assign(f, dto);
    return this.fertRepo.save(f);
  }

  async removeFertilizer(id: string, userId: string) {
    await this.findOneFertilizer(id, userId);
    await this.fertRepo.softDelete(id);
  }

  async createApplication(userId: string, dto: CreateApplicationDto) {
    return this.appRepo.save(this.appRepo.create({ ...dto, userId }));
  }

  async findApplications(userId: string, pagination: PaginationDto, fieldId?: string, fertilizerId?: string) {
    const where: any = { userId };
    if (fieldId) where.fieldId = fieldId;
    if (fertilizerId) where.fertilizerId = fertilizerId;
    const [data, total] = await this.appRepo.findAndCount({
      where, skip: pagination.skip, take: pagination.limit,
      relations: ['fertilizer', 'field'], order: { appliedAt: 'DESC' },
    });
    return new PaginatedResult(data, total, pagination.page, pagination.limit);
  }
}