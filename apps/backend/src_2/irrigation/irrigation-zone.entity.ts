import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';
import { Field } from '../fields/field.entity';

export enum ZoneStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  MAINTENANCE = 'maintenance',
}

export enum IrrigationType {
  DRIP = 'drip',
  SPRINKLER = 'sprinkler',
  FLOOD = 'flood',
  PIVOT = 'pivot',
  MANUAL = 'manual',
}

@Entity('irrigation_zones')
export class IrrigationZone extends BaseEntity {
  @Column()
  name: string;

  @Column({ type: 'enum', enum: ZoneStatus, default: ZoneStatus.INACTIVE })
  status: ZoneStatus;

  @Column({ type: 'enum', enum: IrrigationType, default: IrrigationType.DRIP })
  type: IrrigationType;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  flowRate: number;

  @Column({ nullable: true })
  flowRateUnit: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @ManyToOne(() => Field)
  @JoinColumn({ name: 'field_id' })
  field: Field;

  @Column({ name: 'field_id' })
  fieldId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}
