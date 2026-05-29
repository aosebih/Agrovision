import { IsString, IsOptional, IsEnum, IsNumber } from 'class-validator';
import { FieldStatus } from '../field.entity';

export class CreateFieldDto {
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsOptional()
  @IsNumber()
  latitude?: number;

  @IsOptional()
  @IsNumber()
  longitude?: number;

  @IsOptional()
  @IsNumber()
  areaHectares?: number;

  @IsOptional()
  @IsEnum(FieldStatus)
  status?: FieldStatus;

  @IsOptional()
  @IsString()
  soilType?: string;
}
