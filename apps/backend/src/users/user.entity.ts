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

  // ── Settings columns ──────────────────────────────────────────────────────
  @Column({ name: 'notificationsEnabled', default: true })
  notificationsEnabled: boolean;

  @Column({ name: 'weatherAlerts', default: true })
  weatherAlerts: boolean;

  @Column({ name: 'storageAlerts', default: false })
  storageAlerts: boolean;

  @Column({ name: 'darkMode', default: false })
  darkMode: boolean;

  @Column({ name: 'language', default: 'ar' })
  language: string;

  @Column({ name: 'location', nullable: true })
  location: string;
}