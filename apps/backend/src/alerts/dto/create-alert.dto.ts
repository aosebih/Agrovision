import { IsString, IsEnum, IsOptional } from 'class-validator';
import { AlertType, AlertSeverity } from '../alert.entity';

export class CreateAlertDto {
  @IsString()
  title: string;

  @IsString()
  message: string;

  @IsEnum(AlertType)
  type: AlertType;

  @IsOptional()
  @IsEnum(AlertSeverity)
  severity?: AlertSeverity;

  @IsOptional()
  @IsString()
  relatedEntityId?: string;

  @IsOptional()
  @IsString()
  relatedEntityType?: string;
}