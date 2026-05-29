import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum ScheduleType {
  IRRIGATION = 'irrigation',
  FERTILIZATION = 'fertilization',
  TREATMENT = 'treatment',
  INSPECTION = 'inspection',
  HARVEST = 'harvest',
  OTHER = 'other',
}

export enum RecurrenceType {
  NONE = 'none',
  DAILY = 'daily',
  WEEKLY = 'weekly',
  MONTHLY = 'monthly',
  CUSTOM = 'custom',
}

@Entity('schedules')
export class Schedule extends BaseEntity {
  @Column()
  title: string;

  @Column({ type: 'enum', enum: ScheduleType })
  type: ScheduleType;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'timestamptz', name: 'start_time' })
  startTime: Date;

  @Column({ type: 'timestamptz', name: 'end_time', nullable: true })
  endTime: Date;

  @Column({ type: 'enum', enum: RecurrenceType, default: RecurrenceType.NONE })
  recurrence: RecurrenceType;

  @Column({ type: 'int', nullable: true })
  recurrenceInterval: number;

  @Column({ default: true })
  isActive: boolean;

  @Column({ nullable: true })
  fieldId: string;

  @Column({ nullable: true })
  cropId: string;

  @Column({ nullable: true })
  zoneId: string;

  @Column({ type: 'jsonb', nullable: true })
  config: Record<string, any>;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}
