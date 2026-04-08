import { IsString, IsOptional, IsEnum, IsNumber, IsUUID } from 'class-validator';
import { IrrigationMethod } from '../irrigation-zone.entity';

export class CreateZoneDto {
  @IsString()
  name: string;

  @IsUUID()
  fieldId: string;

  @IsOptional()
  @IsEnum(IrrigationMethod)
  method?: IrrigationMethod;

  @IsOptional()
  @IsNumber()
  flowRateLph?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}