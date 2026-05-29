import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Field } from './field.entity';
import { FieldPhoto } from './field-photo.entity';
import { FieldsService } from './fields.service';
import { FieldsController } from './fields.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Field, FieldPhoto])],
  controllers: [FieldsController],
  providers: [FieldsService],
  exports: [FieldsService],
})
export class FieldsModule {}
