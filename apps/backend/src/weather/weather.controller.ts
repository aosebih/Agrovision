import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { WeatherService } from './weather.service';

@Controller('weather')
@UseGuards(JwtAuthGuard)
export class WeatherController {
  constructor(private readonly service: WeatherService) {}

  @Get('current')
  getCurrent(
    @CurrentUser('id') userId: string,
    @Query('location') location = 'Oran,DZ',
  ) {
    return this.service.getCurrent(location, userId);
  }
}
