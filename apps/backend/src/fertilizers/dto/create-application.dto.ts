import {
  IsUUID,
  IsNumber,
  IsString,
  IsDateString,
  IsOptional,
} from 'class-validator';

export class CreateApplicationDto {
  @IsUUID() fertilizerId: string;
  @IsOptional() @IsUUID() fieldId?: string;
  @IsOptional() @IsUUID() cropId?: string;
  @IsNumber() quantity: number;
  @IsString() unit: string;
  @IsDateString() appliedAt: string;
  @IsOptional() @IsString() method?: string;
  @IsOptional() @IsString() notes?: string;
}
