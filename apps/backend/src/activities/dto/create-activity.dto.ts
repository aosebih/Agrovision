import { IsString, IsEnum, IsOptional, IsDateString, IsUUID } from 'class-validator';
import { ActivityType } from '../activity.entity';

export class CreateActivityDto {
  @IsString()
  title: string;

  @IsEnum(ActivityType)
  type: ActivityType;

  @IsOptional()
  @IsString()
  description?: string;

  @IsDateString()
  performedAt: string;

  @IsOptional()
  @IsUUID()
  fieldId?: string;

  @IsOptional()
  @IsUUID()
  cropId?: string;
}