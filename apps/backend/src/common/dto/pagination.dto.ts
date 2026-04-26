import { IsOptional, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class PaginationDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit: number = 20;

  get skip(): number {
    return (this.page - 1) * this.limit;
  }
}

export class PaginatedResult<T> {
  constructor(public items: T[], public total: number, public page: number, public limit: number) {}
  get totalPages(): number {
    return Math.ceil(this.total / this.limit);
  }
}