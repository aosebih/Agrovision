import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Field } from './field.entity';
import { FieldPhoto } from './field-photo.entity';
import { CreateFieldDto } from './dto/create-field.dto';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class FieldsService {
  constructor(
    @InjectRepository(Field) private fieldRepo: Repository<Field>,
    @InjectRepository(FieldPhoto) private photoRepo: Repository<FieldPhoto>,
  ) {}

  async create(userId: string, dto: CreateFieldDto): Promise<Field> {
    return this.fieldRepo.save(this.fieldRepo.create({ ...dto, userId }));
  }

  async findAll(
    userId: string,
    pagination: PaginationDto,
  ): Promise<PaginatedResult<Field>> {
    const [data, total] = await this.fieldRepo.findAndCount({
      where: { userId },
      skip: pagination.skip,
      take: pagination.limit,
      order: { createdAt: 'DESC' },
    });
    return new PaginatedResult(data, total, pagination.page, pagination.limit);
  }

  async findOne(id: string, userId: string): Promise<Field> {
    const field = await this.fieldRepo.findOne({ where: { id, userId } });
    if (!field) throw new NotFoundException('Field not found');
    return field;
  }

  async update(
    id: string,
    userId: string,
    dto: Partial<CreateFieldDto>,
  ): Promise<Field> {
    const field = await this.findOne(id, userId);
    Object.assign(field, dto);
    return this.fieldRepo.save(field);
  }

  async remove(id: string, userId: string): Promise<void> {
    const field = await this.findOne(id, userId);
    await this.fieldRepo.softDelete(field.id);
  }

  // ── Field photo methods ────────────────────────────────────────────────────
  async addPhoto(
    fieldId: string,
    userId: string,
    url: string,
    caption?: string,
  ) {
    await this.findOne(fieldId, userId);
    return this.photoRepo.save(
      this.photoRepo.create({ fieldId, userId, url, caption }),
    );
  }

  async getPhotos(fieldId: string, userId: string) {
    await this.findOne(fieldId, userId);
    return this.photoRepo.find({
      where: { fieldId },
      order: { capturedAt: 'DESC' },
    });
  }

  async deletePhoto(photoId: string, userId: string) {
    const photo = await this.photoRepo.findOne({
      where: { id: photoId, userId },
    });
    if (!photo) throw new NotFoundException('Photo not found');
    await this.photoRepo.softDelete(photoId);
    return { message: 'Photo deleted' };
  }
}
