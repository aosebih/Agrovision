import {
  IsUUID,
  IsDateString,
  IsOptional,
  IsNumber,
  IsString,
} from 'class-validator';

export class CreateEventDto {
  @IsUUID()
  zoneId: string;

  @IsDateString()
  startedAt: string;

  @IsOptional()
  @IsDateString()
  endedAt?: string;

  @IsOptional()
  @IsNumber()
  durationMinutes?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
