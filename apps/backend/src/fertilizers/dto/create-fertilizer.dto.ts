import { IsString, IsOptional, IsNumber } from 'class-validator';

export class CreateFertilizerDto {
  @IsString() name: string;
  @IsOptional() @IsString() brand?: string;
  @IsOptional() @IsString() type?: string;
  @IsOptional() @IsNumber() nitrogenPct?: number;
  @IsOptional() @IsNumber() phosphorusPct?: number;
  @IsOptional() @IsNumber() potassiumPct?: number;
  @IsOptional() @IsString() description?: string;
  @IsOptional() @IsString() unit?: string;
}