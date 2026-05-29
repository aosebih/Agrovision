import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { HttpModule } from '@nestjs/axios';
import { ScheduleModule } from '@nestjs/schedule';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { FieldsModule } from './fields/fields.module';
import { CropsModule } from './crops/crops.module';
import { FertilizersModule } from './fertilizers/fertilizers.module';
import { IrrigationModule } from './irrigation/irrigation.module';
import { InventoryModule } from './inventory/inventory.module';
import { AlertsModule } from './alerts/alerts.module';
import { ActivitiesModule } from './activities/activities.module';
import { TreatmentsModule } from './treatments/treatments.module';
import { SchedulesModule } from './schedules/schedules.module';
import { AnalyticsModule } from './analytics/analytics.module';
import { WeatherModule } from './weather/weather.module';
import { ChatModule } from './chat/chat.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    HttpModule,
    ScheduleModule.forRoot(),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get('DB_HOST'),
        port: +config.get('DB_PORT'),
        username: config.get('DB_USERNAME'),
        password: config.get('DB_PASSWORD'),
        database: config.get('DB_NAME'),
        autoLoadEntities: true,
        synchronize: false,
      }),
      inject: [ConfigService],
    }),
    UsersModule,
    AuthModule,
    FieldsModule,
    CropsModule,
    FertilizersModule,
    IrrigationModule,
    InventoryModule,
    AlertsModule,
    ActivitiesModule,
    TreatmentsModule,
    SchedulesModule,
    AnalyticsModule,
    WeatherModule,
    ChatModule,
  ],
})
export class AppModule {}
