import { Entity, Column } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';

export enum UserRole {
  ADMIN = 'admin',
  FARMER = 'farmer',
  MANAGER = 'manager',
}

@Entity('users')
export class User extends BaseEntity {
  @Column({ unique: true })
  email: string;

  @Column()
  name: string;

  @Column()
  password: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.FARMER })
  role: UserRole;

  @Column({ nullable: true })
  farmName: string;

  @Column({ default: true })
  isActive: boolean;
}