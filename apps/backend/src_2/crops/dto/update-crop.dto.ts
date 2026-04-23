import { IsString, IsOptional, IsEnum, IsDateString, IsNumber } from 'class-validator';
import { CropStatus, GrowthStage } from '../crop.entity';

export class UpdateCropDto {
  @IsOptional()
  @IsString()
  name?: string;

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
  @IsDateString()
  actualHarvestDate?: string;

  @IsOptional()
  @IsNumber()
  healthScore?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
