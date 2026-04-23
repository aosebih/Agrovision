import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum FertilizerType {
  NITROGEN = 'nitrogen',
  PHOSPHORUS = 'phosphorus',
  POTASSIUM = 'potassium',
  COMPOUND = 'compound',
  ORGANIC = 'organic',
  MICRONUTRIENT = 'micronutrient',
}

@Entity('fertilizers')
export class Fertilizer extends BaseEntity {
  @Column()
  name: string;

  @Column({ type: 'enum', enum: FertilizerType, default: FertilizerType.COMPOUND })
  type: FertilizerType;

  @Column({ nullable: true })
  brand: string;

  @Column({ nullable: true })
  npkRatio: string;

  @Column({ type: 'text', nullable: true })
  composition: string;

  @Column({ nullable: true })
  manufacturer: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}
