import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Alert, AlertSeverity, AlertType } from './alert.entity';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';

@Injectable()
export class AlertsService {
  constructor(@InjectRepository(Alert) private repo: Repository<Alert>) {}

  async create(userId: string, dto: any) {
    return this.repo.save(this.repo.create({ ...dto, userId }));
  }

  async findAll(
    userId: string,
    p: PaginationDto,
    type?: AlertType,
    severity?: AlertSeverity,
    unreadOnly = false,
  ) {
    const where: any = { userId };
    if (type) where.type = type;
    if (severity) where.severity = severity;
    if (unreadOnly) where.isRead = false;
    const [data, total] = await this.repo.findAndCount({
      where,
      skip: p.skip,
      take: p.limit,
      order: { createdAt: 'DESC' },
    });
    return new PaginatedResult(data, total, p.page, p.limit);
  }

  async findOne(id: string, userId: string) {
    const alert = await this.repo.findOne({ where: { id, userId } });
    if (!alert) throw new NotFoundException('Alert not found');
    return alert;
  }

  async markRead(id: string, userId: string) {
    const alert = await this.findOne(id, userId);
    alert.isRead = true;
    return this.repo.save(alert);
  }

  async acknowledge(id: string, userId: string) {
    const alert = await this.findOne(id, userId);
    alert.isAcknowledged = true;
    alert.isRead = true;
    alert.acknowledgedAt = new Date();
    return this.repo.save(alert);
  }

  async markAllRead(userId: string) {
    await this.repo.update({ userId, isRead: false }, { isRead: true });
    return { message: 'All alerts marked as read' };
  }

  async getUnreadCount(userId: string) {
    const count = await this.repo.count({ where: { userId, isRead: false } });
    return { count };
  }

  // ── NEW: delete a single alert ────────────────────────────────────────────
  async remove(id: string, userId: string) {
    await this.findOne(id, userId); // ownership check
    await this.repo.softDelete(id);
    return { message: 'Alert deleted' };
  }

  // ── NEW: delete all alerts for user ──────────────────────────────────────
  async removeAll(userId: string) {
    await this.repo.softDelete({ userId });
    return { message: 'All alerts deleted' };
  }
}
