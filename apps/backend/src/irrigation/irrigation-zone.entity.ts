import { Entity, Column, ManyToOne, OneToMany } from 'typeorm';
import { BaseEntity } from '../common/entities/base.entity';
import { Field } from '../fields/field.entity';
import { IrrigationEvent } from './irrigation-event.entity';

export enum IrrigationMethod {
  DRIP = 'drip',
  SPRINKLER = 'sprinkler',
  FLOOD = 'flood',
  PIVOT = 'pivot',
}

@Entity('irrigation_zones')
export class IrrigationZone extends BaseEntity {
  @Column()
  name: string;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ name: 'field_id' })
  fieldId: string;

  @ManyToOne(() => Field, { nullable: true })
  field: Field;

  @Column({ type: 'enum', enum: IrrigationMethod, nullable: true })
  method: IrrigationMethod;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
    name: 'flow_rate_lph',
  })
  flowRateLph: number;

  @Column({ nullable: true })
  notes: string;

  @Column({ default: 'inactive' })
  status: string;

  @OneToMany(() => IrrigationEvent, (event) => event.zone)
  events: IrrigationEvent[];
}
