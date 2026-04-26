import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';
import { Field } from '../fields/field.entity';
import { Crop } from '../crops/crop.entity';

export enum TreatmentType {
  HERBICIDE = 'herbicide',
  PESTICIDE = 'pesticide',
  FUNGICIDE = 'fungicide',
  INSECTICIDE = 'insecticide',
  FOLIAR = 'foliar',
  OTHER = 'other',
}

export enum TreatmentStatus {
  PLANNED = 'planned',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
}

@Entity('treatments')
export class Treatment extends BaseEntity {
  @Column()
  productName: string;

  @Column({ type: 'enum', enum: TreatmentType, default: TreatmentType.OTHER })
  type: TreatmentType;

  @Column({ type: 'enum', enum: TreatmentStatus, default: TreatmentStatus.PLANNED })
  status: TreatmentStatus;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  quantity: number;

  @Column({ nullable: true })
  unit: string;

  @Column({ type: 'decimal', precision: 8, scale: 2, nullable: true })
  ratePerHa: number;

  @Column({ type: 'date', name: 'applied_date', nullable: true })
  appliedDate: Date;

  @Column({ type: 'date', name: 'planned_date', nullable: true })
  plannedDate: Date;

  @Column({ nullable: true })
  targetPest: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @ManyToOne(() => Field, { nullable: true })
  @JoinColumn({ name: 'field_id' })
  field: Field;

  @Column({ name: 'field_id', nullable: true })
  fieldId: string;

  @ManyToOne(() => Crop, { nullable: true })
  @JoinColumn({ name: 'crop_id' })
  crop: Crop;

  @Column({ name: 'crop_id', nullable: true })
  cropId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}