import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum FieldStatus {
  ACTIVE = 'active',
  FALLOW = 'fallow',
  HARVESTED = 'harvested',
}

@Entity('fields')
export class Field extends BaseEntity {
  @Column()
  name: string;

  @Column({ nullable: true })
  location: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  areaHectares: number;

  @Column({ type: 'enum', enum: FieldStatus, default: FieldStatus.ACTIVE })
  status: FieldStatus;

  @Column({ nullable: true })
  soilType: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}