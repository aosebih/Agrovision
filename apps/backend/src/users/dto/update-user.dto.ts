import { IsString, IsOptional, MinLength, IsBoolean } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  @MinLength(3)
  name?: string;

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string;

  @IsOptional()
  @IsString()
  farmName?: string;

  @IsOptional()
  @IsBoolean()
  notificationsEnabled?: boolean;

  @IsOptional()
  @IsBoolean()
  weatherAlerts?: boolean;

  @IsOptional()
  @IsBoolean()
  storageAlerts?: boolean;

  @IsOptional()
  @IsBoolean()
  darkMode?: boolean;

  @IsOptional()
  @IsString()
  language?: string;

  @IsOptional()
  @IsString()
  location?: string;
}
