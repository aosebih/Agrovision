import { IsString, IsEnum, IsOptional, IsNumber, IsDateString } from 'class-validator';
import { ItemCategory } from '../inventory-item.entity';

export class CreateInventoryItemDto {
  @IsString()
  name: string;

  @IsEnum(ItemCategory)
  category: ItemCategory;

  @IsOptional()
  @IsString()
  brand?: string;

  @IsNumber()
  quantity: number;

  @IsString()
  unit: string;

  @IsOptional()
  @IsNumber()
  minStockLevel?: number;

  @IsOptional()
  @IsNumber()
  pricePerUnit?: number;

  @IsOptional()
  @IsString()
  supplier?: string;

  @IsOptional()
  @IsDateString()
  expiryDate?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
