import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum AlertType {
  WEATHER = 'weather',
  CROP_HEALTH = 'crop_health',
  IRRIGATION = 'irrigation',
  INVENTORY = 'inventory',
  FERTILIZER = 'fertilizer',
  EQUIPMENT = 'equipment',
  SYSTEM = 'system',
}

export enum AlertSeverity {
  INFO = 'info',
  WARNING = 'warning',
  CRITICAL = 'critical',
}

@Entity('alerts')
export class Alert extends BaseEntity {
  @Column()
  title: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'enum', enum: AlertType })
  type: AlertType;

  @Column({ type: 'enum', enum: AlertSeverity, default: AlertSeverity.INFO })
  severity: AlertSeverity;

  @Column({ default: false })
  isRead: boolean;

  @Column({ default: false })
  isAcknowledged: boolean;

  @Column({ type: 'timestamptz', nullable: true })
  acknowledgedAt: Date;

  @Column({ nullable: true })
  relatedEntityId: string;

  @Column({ nullable: true })
  relatedEntityType: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}
