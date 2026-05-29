import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { WeatherService } from './weather.service';
import { WeatherController } from './weather.controller';
import { AlertsModule } from '../alerts/alerts.module';

@Module({
  imports: [HttpModule, AlertsModule],
  controllers: [WeatherController],
  providers: [WeatherService],
  exports: [WeatherService],
})
export class WeatherModule {}
