import { Entity, Column } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';

@Entity('fertilizers')
export class Fertilizer extends BaseEntity {
  @Column()
  name: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ nullable: true })
  brand: string;

  @Column({ nullable: true })
  type: string;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, name: 'nitrogen_pct' })
  nitrogenPct: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, name: 'phosphorus_pct' })
  phosphorusPct: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true, name: 'potassium_pct' })
  potassiumPct: number;

  @Column({ nullable: true })
  description: string;

  @Column({ nullable: true })
  unit: string;
}
