import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { User } from '../users/user.entity';

export enum ItemCategory {
  FERTILIZER = 'fertilizer',
  PESTICIDE = 'pesticide',
  SEED = 'seed',
  EQUIPMENT = 'equipment',
  FUEL = 'fuel',
  OTHER = 'other',
}

const numericTransformer = {
  to: (v: number | null) => v,
  from: (v: string | null) => (v === null || v === undefined ? null : parseFloat(v)),
};

@Entity('inventory_items')
export class InventoryItem extends BaseEntity {
  @Column()
  name: string;

  @Column({ type: 'enum', enum: ItemCategory, default: ItemCategory.OTHER })
  category: ItemCategory;

  @Column({ nullable: true })
  brand: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, transformer: numericTransformer })
  quantity: number;

  @Column()
  unit: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true, transformer: numericTransformer })
  minStockLevel: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true, transformer: numericTransformer })
  pricePerUnit: number;

  @Column({ nullable: true })
  supplier: string;

  @Column({ type: 'date', nullable: true })
  expiryDate: Date;

  @Column({ nullable: true })
  notes: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'user_id' })
  userId: string;
}