import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum ActivityType {
  IRRIGATION = 'irrigation',
  FERTILIZATION = 'fertilization',
  TREATMENT = 'treatment',
  INSPECTION = 'inspection',
  HARVEST = 'harvest',
  PLANTING = 'planting',
  SOIL_TEST = 'soil_test',
  AERIAL_SURVEY = 'aerial_survey',
  MANUAL_CHECK = 'manual_check',
  OTHER = 'other',
}

export enum ActivityStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

@Entity('activities')
export class Activity extends BaseEntity {
  @Column()
  title: string;

  @Column({ type: 'enum', enum: ActivityType })
  type: ActivityType;

  @Column({
    type: 'enum',
    enum: ActivityStatus,
    default: ActivityStatus.PENDING,
  })
  status: ActivityStatus;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'timestamptz', name: 'performed_at' })
  performedAt: Date;

  @Column({ nullable: true })
  relatedEntityId: string;

  @Column({ nullable: true })
  relatedEntityType: string;

  @Column({ nullable: true })
  fieldId: string;

  @Column({ nullable: true })
  cropId: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: Record<string, any>;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}
