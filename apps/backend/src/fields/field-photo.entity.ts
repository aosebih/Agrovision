import { Entity, Column, ManyToOne, JoinColumn } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { Field } from './field.entity';
import { User } from '../users/user.entity';

@Entity('field_photos')
export class FieldPhoto extends BaseEntity {
  @Column() fieldId: string;
  @Column() userId: string;
  @Column({ type: 'text' }) url: string;
  @Column({ type: 'text', nullable: true }) caption: string;
  @Column({ type: 'timestamptz', default: () => 'NOW()' }) capturedAt: Date;

  @ManyToOne(() => Field) @JoinColumn({ name: 'field_id' }) field: Field;
  @ManyToOne(() => User) @JoinColumn({ name: 'user_id' }) user: User;
}
