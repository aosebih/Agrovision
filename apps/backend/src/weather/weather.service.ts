import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { AlertsService } from '../alerts/alerts.service';

export interface ForecastDay {
  date: string;
  tempMin: number;
  tempMax: number;
  description: string;
  icon: string;
  rainProbability: number;
  condition: string;
}

export interface WeatherData {
  city: string;
  country: string;
  temperature: number;
  feelsLike: number;
  humidity: number;
  windSpeed: number;
  description: string;
  icon: string;
  condition: string;
  forecast: ForecastDay[];
}

@Injectable()
export class WeatherService {
  private readonly logger = new Logger(WeatherService.name);
  private readonly apiKey: string;
  private readonly base = 'https://api.openweathermap.org/data/2.5';

  constructor(
    private config: ConfigService,
    private http: HttpService,
    private alertsService: AlertsService,
  ) {
    this.apiKey = this.config.get<string>('OPENWEATHER_API_KEY') ?? '';
  }

  async getCurrent(location: string, userId: string): Promise<WeatherData> {
    if (!this.apiKey) return this._mock(location);
    try {
      const { data } = await firstValueFrom(
        this.http.get(`${this.base}/weather`, {
          params: {
            q: location,
            appid: this.apiKey,
            units: 'metric',
            lang: 'ar',
          },
        }),
      );
      const forecast = await this._forecast(location);
      const weather = this._map(data, forecast);
      await this._autoAlerts(weather, userId, location);
      return weather;
    } catch (e) {
      this.logger.warn(`Weather API failed: ${e.message}`);
      return this._mock(location);
    }
  }

  private async _forecast(location: string): Promise<ForecastDay[]> {
    const { data } = await firstValueFrom(
      this.http.get(`${this.base}/forecast`, {
        params: {
          q: location,
          appid: this.apiKey,
          units: 'metric',
          lang: 'ar',
          cnt: 24,
        },
      }),
    );
    const daily = new Map<string, any[]>();
    for (const item of data.list) {
      const date = item.dt_txt.split(' ')[0];
      if (!daily.has(date)) daily.set(date, []);
      daily.get(date).push(item);
    }
    return Array.from(daily.entries())
      .slice(0, 5)
      .map(([date, items]) => ({
        date,
        tempMin: Math.min(...items.map((i: any) => i.main.temp_min)),
        tempMax: Math.max(...items.map((i: any) => i.main.temp_max)),
        description: items[0].weather[0].description,
        icon: items[0].weather[0].icon,
        rainProbability: Math.round(
          Math.max(...items.map((i: any) => i.pop ?? 0)) * 100,
        ),
        condition: items[0].weather[0].main.toLowerCase(),
      }));
  }

  private _map(data: any, forecast: ForecastDay[]): WeatherData {
    return {
      city: data.name,
      country: data.sys.country,
      temperature: Math.round(data.main.temp),
      feelsLike: Math.round(data.main.feels_like),
      humidity: data.main.humidity,
      windSpeed: Math.round(data.wind?.speed ?? 0),
      description: data.weather[0].description,
      icon: data.weather[0].icon,
      condition: data.weather[0].main.toLowerCase(),
      forecast,
    };
  }

  private async _autoAlerts(w: WeatherData, userId: string, location: string) {
    if (w.temperature < 2) {
      await this.alertsService.create(userId, {
        title: 'تحذير: صقيع محتمل',
        message: `درجة الحرارة في ${location} انخفضت إلى ${w.temperature}°م — خطر الصقيع على المحاصيل`,
        type: 'weather',
        severity: 'critical',
      });
    } else if (w.temperature > 40) {
      await this.alertsService.create(userId, {
        title: 'تحذير: حرارة شديدة',
        message: `درجة الحرارة في ${location} وصلت ${w.temperature}°م — زيادة الري ضرورية`,
        type: 'weather',
        severity: 'warning',
      });
    }
    const rainDay = w.forecast.find((f) => f.rainProbability > 70);
    if (rainDay) {
      await this.alertsService.create(userId, {
        title: 'أمطار متوقعة',
        message: `احتمال هطول أمطار ${rainDay.rainProbability}% بتاريخ ${rainDay.date} في ${location}`,
        type: 'weather',
        severity: 'info',
      });
    }
  }

  private _mock(location: string): WeatherData {
    const d = (offset: number) =>
      new Date(Date.now() + offset * 86400000).toISOString().split('T')[0];
    return {
      city: location.split(',')[0] || 'وهران',
      country: 'DZ',
      temperature: 24,
      feelsLike: 22,
      humidity: 55,
      windSpeed: 12,
      description: 'غائم جزئياً',
      icon: '02d',
      condition: 'clouds',
      forecast: [
        {
          date: d(0),
          tempMin: 18,
          tempMax: 26,
          description: 'غائم',
          icon: '04d',
          rainProbability: 10,
          condition: 'clouds',
        },
        {
          date: d(1),
          tempMin: 17,
          tempMax: 28,
          description: 'مشمس',
          icon: '01d',
          rainProbability: 5,
          condition: 'clear',
        },
        {
          date: d(2),
          tempMin: 15,
          tempMax: 22,
          description: 'أمطار خفيفة',
          icon: '10d',
          rainProbability: 75,
          condition: 'rain',
        },
        {
          date: d(3),
          tempMin: 16,
          tempMax: 24,
          description: 'غائم جزئياً',
          icon: '02d',
          rainProbability: 20,
          condition: 'clouds',
        },
        {
          date: d(4),
          tempMin: 19,
          tempMax: 27,
          description: 'مشمس',
          icon: '01d',
          rainProbability: 3,
          condition: 'clear',
        },
      ],
    };
  }
}
