import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Crop } from './crop.entity';
import { CreateCropDto } from './dto/create-crop.dto';
import { UpdateCropDto } from './dto/update-crop.dto';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

const DEFAULT_FIELD_ID = '7b6b4f0f-f245-4e00-80cb-b03c8e30d6f2'; //remove after adding field ui

@Injectable()
export class CropsService {
  constructor(@InjectRepository(Crop) private readonly cropRepo: Repository<Crop>) {}

  async create(userId: string, dto: CreateCropDto): Promise<Crop> {
    const crop = this.cropRepo.create({
      ...dto,
      userId,
      fieldId: dto.fieldId ?? DEFAULT_FIELD_ID, // remove when adding field ui ?? DEFAULT_FIELD_ID
    });
    return this.cropRepo.save(crop);
  }

  async findAll(userId: string, pagination: PaginationDto, fieldId?: string): Promise<PaginatedResult<Crop>> {
    const where: any = { userId };
    if (fieldId) where.fieldId = fieldId;
    const [data, total] = await this.cropRepo.findAndCount({
      where,
      skip: pagination.skip,
      take: pagination.limit,
      relations: ['field'],
      order: { createdAt: 'DESC' },
    });
    return new PaginatedResult(data, total, pagination.page, pagination.limit);
  }

  async findOne(id: string, userId: string): Promise<Crop> {
    const crop = await this.cropRepo.findOne({ where: { id, userId }, relations: ['field'] });
    if (!crop) throw new NotFoundException('Crop not found');
    return crop;
  }

  async update(id: string, userId: string, dto: UpdateCropDto): Promise<Crop> {
    const crop = await this.findOne(id, userId);
    Object.assign(crop, dto);
    return this.cropRepo.save(crop);
  }

  async remove(id: string, userId: string): Promise<void> {
    await this.findOne(id, userId);
    await this.cropRepo.softDelete(id);
  }
}