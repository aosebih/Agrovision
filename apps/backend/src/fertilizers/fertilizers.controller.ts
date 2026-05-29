import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { FertilizersService } from './fertilizers.service';
import { CreateFertilizerDto } from './dto/create-fertilizer.dto';
import { CreateApplicationDto } from './dto/create-application.dto';
import { PaginationDto } from '../common/dto/pagination.dto';

@Controller('fertilizers')
@UseGuards(JwtAuthGuard)
export class FertilizersController {
  constructor(private readonly service: FertilizersService) {}

  @Post() create(
    @CurrentUser('id') uid: string,
    @Body() dto: CreateFertilizerDto,
  ) {
    return this.service.createFertilizer(uid, dto);
  }
  @Get() findAll(@CurrentUser('id') uid: string, @Query() p: PaginationDto) {
    return this.service.findAllFertilizers(uid, p);
  }
  @Get(':id') findOne(@CurrentUser('id') uid: string, @Param('id') id: string) {
    return this.service.findOneFertilizer(id, uid);
  }
  @Patch(':id') update(
    @CurrentUser('id') uid: string,
    @Param('id') id: string,
    @Body() dto: CreateFertilizerDto,
  ) {
    return this.service.updateFertilizer(id, uid, dto);
  }
  @Delete(':id') remove(
    @CurrentUser('id') uid: string,
    @Param('id') id: string,
  ) {
    return this.service.removeFertilizer(id, uid);
  }

  // Applications sub-resource
  @Post('applications') createApp(
    @CurrentUser('id') uid: string,
    @Body() dto: CreateApplicationDto,
  ) {
    return this.service.createApplication(uid, dto);
  }
  @Get('applications/list') findApps(
    @CurrentUser('id') uid: string,
    @Query() p: PaginationDto,
    @Query('fieldId') fieldId?: string,
    @Query('fertilizerId') fertilizerId?: string,
  ) {
    return this.service.findApplications(uid, p, fieldId, fertilizerId);
  }
}
