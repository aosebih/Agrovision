import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';
import { IrrigationZone } from './irrigation-zone.entity';

export enum EventStatus {
  ACTIVE = 'active',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  FAILED = 'failed',
}

@Entity('irrigation_events')
export class IrrigationEvent extends BaseEntity {
  @ManyToOne(() => IrrigationZone)
  @JoinColumn({ name: 'zone_id' })
  zone: IrrigationZone;

  @Column({ name: 'zone_id' })
  zoneId: string;

  @Column({ type: 'timestamptz', name: 'started_at' })
  startedAt: Date;

  @Column({ type: 'timestamptz', name: 'ended_at', nullable: true })
  endedAt: Date;

  @Column({ type: 'int', name: 'duration_minutes', nullable: true })
  durationMinutes: number;

  @Column({ type: 'enum', enum: EventStatus, default: EventStatus.ACTIVE })
  status: EventStatus;

  @Column({ nullable: true })
  triggeredBy: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  waterUsed: number;

  @Column({ nullable: true })
  waterUsedUnit: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}
