import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { Fertilizer } from './fertilizer.entity';
import { Field } from '../fields/field.entity';
import { Crop } from '../crops/crop.entity';
import { User } from '../users/user.entity';

@Entity('fertilizer_applications')
export class FertilizerApplication extends BaseEntity {
  @ManyToOne(() => Fertilizer) @JoinColumn({ name: 'fertilizer_id' }) fertilizer: Fertilizer;
  @Column({ name: 'fertilizer_id' }) fertilizerId: string;

  @ManyToOne(() => Field, { nullable: true }) @JoinColumn({ name: 'field_id' }) field: Field;
  @Column({ name: 'field_id', nullable: true }) fieldId: string;

  @ManyToOne(() => Crop, { nullable: true }) @JoinColumn({ name: 'crop_id' }) crop: Crop;
  @Column({ name: 'crop_id', nullable: true }) cropId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 }) quantity: number;
  @Column() unit: string;
  @Column({ type: 'timestamptz', name: 'applied_at' }) appliedAt: Date;
  @Column({ nullable: true }) method: string;
  @Column({ nullable: true }) notes: string;

  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
  @Column({ name: 'user_id' }) userId: string;
}