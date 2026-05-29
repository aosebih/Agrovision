import {
  IsString,
  IsOptional,
  IsEnum,
  IsNumber,
  IsDateString,
  IsUUID,
} from 'class-validator';
import { TreatmentType } from '../treatment.entity';

export class CreateTreatmentDto {
  @IsString()
  productName: string;

  @IsOptional()
  @IsEnum(TreatmentType)
  type?: TreatmentType;

  @IsOptional()
  @IsNumber()
  quantity?: number;

  @IsOptional()
  @IsString()
  unit?: string;

  @IsOptional()
  @IsNumber()
  ratePerHa?: number;

  @IsOptional()
  @IsDateString()
  plannedDate?: string;

  @IsOptional()
  @IsDateString()
  appliedDate?: string;

  @IsOptional()
  @IsString()
  targetPest?: string;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsUUID()
  fieldId?: string;

  @IsOptional()
  @IsUUID()
  cropId?: string;
}
