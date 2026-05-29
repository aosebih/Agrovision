import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { IrrigationZone } from './irrigation-zone.entity';
import { IrrigationEvent, EventStatus } from './irrigation-event.entity';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class IrrigationService {
  constructor(
    @InjectRepository(IrrigationZone)
    private zoneRepo: Repository<IrrigationZone>,
    @InjectRepository(IrrigationEvent)
    private eventRepo: Repository<IrrigationEvent>,
  ) {}

  async createZone(userId: string, dto: any) {
    return this.zoneRepo.save(this.zoneRepo.create({ ...dto, userId }));
  }

  async findAllZones(userId: string, p: PaginationDto, fieldId?: string) {
    const where: any = { userId };
    if (fieldId) where.fieldId = fieldId;
    const [data, total] = await this.zoneRepo.findAndCount({
      where,
      skip: p.skip,
      take: p.limit,
      relations: ['field'],
    });
    return new PaginatedResult(data, total, p.page, p.limit);
  }

  async findOneZone(id: string, userId: string) {
    const z = await this.zoneRepo.findOne({
      where: { id, userId },
      relations: ['field'],
    });
    if (!z) throw new NotFoundException('Irrigation zone not found');
    return z;
  }

  async updateZone(id: string, userId: string, dto: any) {
    const z = await this.findOneZone(id, userId);
    Object.assign(z, dto);
    return this.zoneRepo.save(z);
  }

  async activateZone(id: string, userId: string) {
    const z = await this.findOneZone(id, userId);
    z.status = 'active';
    const event = this.eventRepo.create({
      zoneId: z.id,
      startedAt: new Date(),
      status: EventStatus.ACTIVE,
      triggeredBy: 'manual',
      userId,
    });
    await this.eventRepo.save(event);
    return this.zoneRepo.save(z);
  }

  async stopZone(id: string, userId: string) {
    const z = await this.findOneZone(id, userId);
    z.status = 'inactive';
    const activeEvent = await this.eventRepo.findOne({
      where: { zoneId: z.id, status: EventStatus.ACTIVE },
      order: { startedAt: 'DESC' },
    });
    if (activeEvent) {
      activeEvent.endedAt = new Date();
      activeEvent.status = EventStatus.COMPLETED;
      const diffMs =
        activeEvent.endedAt.getTime() - activeEvent.startedAt.getTime();
      activeEvent.durationMinutes = Math.round(diffMs / 60000);
      await this.eventRepo.save(activeEvent);
    }
    return this.zoneRepo.save(z);
  }

  async createEvent(userId: string, dto: any) {
    return this.eventRepo.save(this.eventRepo.create({ ...dto, userId }));
  }

  async findEvents(userId: string, p: PaginationDto, zoneId?: string) {
    const where: any = { userId };
    if (zoneId) where.zoneId = zoneId;
    const [data, total] = await this.eventRepo.findAndCount({
      where,
      skip: p.skip,
      take: p.limit,
      relations: ['zone'],
      order: { startedAt: 'DESC' },
    });
    return new PaginatedResult(data, total, p.page, p.limit);
  }

  async stopAll(userId: string) {
    await this.zoneRepo.update(
      { userId, status: 'active' },
      { status: 'inactive' },
    );
    await this.eventRepo.update(
      { userId, status: EventStatus.ACTIVE },
      { status: EventStatus.COMPLETED, endedAt: new Date() },
    );
    return { message: 'All irrigation zones stopped' };
  }
}
