import { IsString, IsOptional, IsEnum, IsUUID, IsDateString, IsNumber } from 'class-validator';
import { CropStatus, GrowthStage } from '../crop.entity';

export class CreateCropDto {
  @IsString()
  name: string;

  @IsUUID()
  fieldId: string;

  @IsOptional()
  @IsString()
  variety?: string;

  @IsOptional()
  @IsEnum(CropStatus)
  status?: CropStatus;

  @IsOptional()
  @IsEnum(GrowthStage)
  growthStage?: GrowthStage;

  @IsOptional()
  @IsDateString()
  plantedDate?: string;

  @IsOptional()
  @IsDateString()
  expectedHarvestDate?: string;

  @IsOptional()
  @IsNumber()
  healthScore?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}