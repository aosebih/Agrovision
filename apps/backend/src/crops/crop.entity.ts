import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';
import { Field } from '../fields/field.entity';

export enum CropStatus {
  PLANTED = 'planted',
  GROWING = 'growing',
  READY_TO_HARVEST = 'ready_to_harvest',
  HARVESTED = 'harvested',
}

export enum GrowthStage {
  GERMINATION = 'germination',
  SEEDLING = 'seedling',
  VEGETATIVE = 'vegetative',
  FLOWERING = 'flowering',
  FRUITING = 'fruiting',
  MATURITY = 'maturity',
}

@Entity('crops')
export class Crop extends BaseEntity {
  @Column()
  name: string;

  @Column({ nullable: true })
  variety: string;

  @Column({ type: 'enum', enum: CropStatus, default: CropStatus.PLANTED })
  status: CropStatus;

  @Column({ type: 'enum', enum: GrowthStage, nullable: true })
  growthStage: GrowthStage;

  @Column({ type: 'date', name: 'planted_date', nullable: true })
  plantedDate: Date;

  @Column({ type: 'date', name: 'expected_harvest_date', nullable: true })
  expectedHarvestDate: Date;

  @Column({ type: 'date', name: 'actual_harvest_date', nullable: true })
  actualHarvestDate: Date;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  healthScore: number;

  @Column({ nullable: true })
  notes: string;

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
