import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Field } from './field.entity';
import { FieldsService } from './fields.service';
import { FieldsController } from './fields.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Field])],
  controllers: [FieldsController],
  providers: [FieldsService],
  exports: [FieldsService],
})
export class FieldsModule {}