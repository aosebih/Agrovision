import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { IrrigationZone } from './irrigation-zone.entity';

export enum EventStatus {
  SCHEDULED = 'scheduled',
  ACTIVE = 'active',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Entity('irrigation_events')
export class IrrigationEvent extends BaseEntity {
  @Column({ name: 'zone_id' })
  zoneId: string;

  @ManyToOne(() => IrrigationZone, (zone) => zone.events)
  @JoinColumn({ name: 'zone_id' })
  zone: IrrigationZone;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ type: 'timestamptz', name: 'started_at' })
  startedAt: Date;

  @Column({ type: 'timestamptz', name: 'ended_at', nullable: true })
  endedAt: Date;

  @Column({ type: 'int', name: 'duration_minutes', nullable: true })
  durationMinutes: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
    name: 'water_used_liters',
  })
  waterUsedLiters: number;

  @Column({ type: 'enum', enum: EventStatus, default: EventStatus.SCHEDULED })
  status: EventStatus;

  @Column({ nullable: true, name: 'triggered_by' })
  triggeredBy: string;

  @Column({ nullable: true })
  notes: string;
}
