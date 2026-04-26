import { IsString, IsEnum, IsOptional, IsDateString, IsInt, IsBoolean, IsUUID } from 'class-validator';
import { ScheduleType, RecurrenceType } from '../schedule.entity';

export class CreateScheduleDto {
  @IsString()
  title: string;

  @IsEnum(ScheduleType)
  type: ScheduleType;

  @IsOptional()
  @IsString()
  description?: string;

  @IsDateString()
  startTime: string;

  @IsOptional()
  @IsDateString()
  endTime?: string;

  @IsOptional()
  @IsEnum(RecurrenceType)
  recurrence?: RecurrenceType;

  @IsOptional()
  @IsInt()
  recurrenceInterval?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @IsOptional()
  @IsUUID()
  fieldId?: string;

  @IsOptional()
  @IsUUID()
  cropId?: string;

  @IsOptional()
  @IsUUID()
  zoneId?: string;
}