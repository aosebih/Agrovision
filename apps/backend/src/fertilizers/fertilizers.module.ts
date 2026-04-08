import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Fertilizer } from './fertilizer.entity';
import { FertilizerApplication } from './fertilizer-application.entity';
import { FertilizersService } from './fertilizers.service';
import { FertilizersController } from './fertilizers.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Fertilizer, FertilizerApplication])],
  controllers: [FertilizersController],
  providers: [FertilizersService],
  exports: [FertilizersService],
})
export class FertilizersModule {}