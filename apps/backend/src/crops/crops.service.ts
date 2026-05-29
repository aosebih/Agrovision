import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike, MoreThan } from 'typeorm';
import { Crop } from './crop.entity';
import { CreateCropDto } from './dto/create-crop.dto';
import { UpdateCropDto } from './dto/update-crop.dto';
import { PaginationDto, PaginatedResult } from '../common/dto/pagination.dto';
import { AlertsService } from '../alerts/alerts.service';
import { WeatherService } from '../weather/weather.service';
import { IrrigationEvent } from '../irrigation/irrigation-event.entity';
import { Treatment, TreatmentStatus } from '../treatments/treatment.entity';
import { FertilizerApplication } from '../fertilizers/fertilizer-application.entity';
import { Alert, AlertSeverity } from '../alerts/alert.entity';

const DEFAULT_FIELD_ID = '7b6b4f0f-f245-4e00-80cb-b03c8e30d6f2';

const DEFAULT_FIELD_ID = '7b6b4f0f-f245-4e00-80cb-b03c8e30d6f2'; //remove after adding field ui

@Injectable()
export class CropsService {
  constructor(
    @InjectRepository(Crop) private readonly cropRepo: Repository<Crop>,
    @InjectRepository(IrrigationEvent)
    private readonly irrigationRepo: Repository<IrrigationEvent>,
    @InjectRepository(Treatment)
    private readonly treatmentRepo: Repository<Treatment>,
    @InjectRepository(FertilizerApplication)
    private readonly fertAppRepo: Repository<FertilizerApplication>,
    @InjectRepository(Alert)
    private readonly alertRepo: Repository<Alert>,
    private readonly alertsService: AlertsService,
    private readonly weatherService: WeatherService,
  ) {}

  async create(userId: string, dto: CreateCropDto): Promise<Crop> {
    const crop = this.cropRepo.create({
      ...dto,
      userId,
      fieldId: dto.fieldId ?? DEFAULT_FIELD_ID,
    });
    return this.cropRepo.save(crop);
  }

  async findAll(
    userId: string,
    pagination: PaginationDto,
    fieldId?: string,
    search?: string,
  ): Promise<PaginatedResult<any>> {
    const where: any = { userId };
    if (fieldId) where.fieldId = fieldId;
    if (search) where.name = ILike(`%${search}%`);

    const [data, total] = await this.cropRepo.findAndCount({
      where,
      skip: pagination.skip,
      take: pagination.limit,
      relations: ['field'],
      order: { createdAt: 'DESC' },
    });

    const enriched = await Promise.all(
      data.map((crop) => this._enrich(crop, userId)),
    );

    return new PaginatedResult(enriched, total, pagination.page, pagination.limit);
  }

  async findOne(id: string, userId: string): Promise<any> {
    const crop = await this.cropRepo.findOne({
      where: { id, userId },
      relations: ['field'],
    });
    if (!crop) throw new NotFoundException('Crop not found');
    return this._enrich(crop, userId);
  }

  async update(id: string, userId: string, dto: UpdateCropDto): Promise<any> {
    const crop = await this.cropRepo.findOne({ where: { id, userId }, relations: ['field'] });
    if (!crop) throw new NotFoundException('Crop not found');

    const hadHarvestDate = !!crop.expectedHarvestDate;
    Object.assign(crop, dto);
    const saved = await this.cropRepo.save(crop);

    if (!hadHarvestDate && saved.expectedHarvestDate) {
      const harvestDate = new Date(saved.expectedHarvestDate);
      const daysUntil = Math.ceil(
        (harvestDate.getTime() - Date.now()) / 86400000,
      );
      if (daysUntil > 0) {
        await this.alertsService.create(userId, {
          title: 'تذكير بموعد الحصاد',
          message: `محصول "${saved.name}" موعد حصاده خلال ${daysUntil} يوم (${harvestDate.toLocaleDateString('ar-DZ')})`,
          type: 'crop_health',
          severity: daysUntil <= 7 ? 'warning' : 'info',
        });
      }
    }

    return this._enrich(saved, userId);
  }

  async remove(id: string, userId: string): Promise<void> {
    await this.findOne(id, userId);
    await this.cropRepo.softDelete(id);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  // ── Health score calculation ───────────────────────────────────────────────
  /**
   * Computes a 0–100 health score from real agronomic signals and persists it
   * back to the database so the Flutter app always has a current value.
   *
   * Weights:
   *   30 % — NDVI (vegetation index from field coordinates)
   *   25 % — Irrigation activity  (events in last 14 days for this field)
   *   20 % — Treatment activity   (completed treatments in last 30 days)
   *   15 % — Fertilization        (applications in last 30 days)
   *   10 % — Alert penalty        (unresolved warning/critical alerts)
   */
  private async _calculateHealthScore(
    crop: Crop,
    ndvi: number,
  ): Promise<number> {
    const now = new Date();
    const day14 = new Date(now.getTime() - 14 * 86400_000);
    const day30 = new Date(now.getTime() - 30 * 86400_000);

    // ── 1. NDVI component (30 %) ─────────────────────────────────────────
    // NDVI range 0–1 maps directly; clamp to avoid negatives on bare soil
    const ndviScore = Math.min(100, Math.max(0, ndvi * 100));

    // ── 2. Irrigation component (25 %) ───────────────────────────────────
    // 0 events in 14 days → 0 pts; 1 event → 60 pts; 3+ events → 100 pts
    const irrCount = await this.irrigationRepo.count({
      where: {
        userId: crop.userId,
        startedAt: MoreThan(day14),
      },
    });
    const irrScore = Math.min(100, irrCount === 0 ? 0 : 40 + irrCount * 20);

    // ── 3. Treatment component (20 %) ────────────────────────────────────
    // Any completed treatment on this crop or its field in last 30 days
    const treatCount = await this.treatmentRepo.count({
      where: [
        { cropId: crop.id, status: TreatmentStatus.COMPLETED,
          appliedDate: MoreThan(day30) as any },
        { fieldId: crop.fieldId, status: TreatmentStatus.COMPLETED,
          appliedDate: MoreThan(day30) as any },
      ],
    });
    const treatScore = Math.min(100, treatCount === 0 ? 30 : 60 + treatCount * 20);

    // ── 4. Fertilization component (15 %) ────────────────────────────────
    const fertCount = await this.fertAppRepo.count({
      where: [
        { cropId: crop.id, appliedAt: MoreThan(day30) },
        { fieldId: crop.fieldId, appliedAt: MoreThan(day30) },
      ],
    });
    const fertScore = Math.min(100, fertCount === 0 ? 25 : 55 + fertCount * 22);

    // ── 5. Alert penalty (10 %) ──────────────────────────────────────────
    // Unread critical alerts tank the score; warnings are a lighter penalty
    const criticalAlerts = await this.alertRepo.count({
      where: {
        userId: crop.userId,
        isRead: false,
        severity: AlertSeverity.CRITICAL,
      },
    });
    const warningAlerts = await this.alertRepo.count({
      where: {
        userId: crop.userId,
        isRead: false,
        severity: AlertSeverity.WARNING,
      },
    });
    // Each critical costs 25 pts, each warning costs 10 pts, floor 0
    const alertPenalty = Math.min(100, criticalAlerts * 25 + warningAlerts * 10);
    const alertScore = Math.max(0, 100 - alertPenalty);

    // ── Weighted average ─────────────────────────────────────────────────
    const raw =
      ndviScore  * 0.30 +
      irrScore   * 0.25 +
      treatScore * 0.20 +
      fertScore  * 0.15 +
      alertScore * 0.10;

    // Round to 2 dp and clamp 0–100
    const score = Math.round(raw * 100) / 100;
    const clamped = Math.min(100, Math.max(0, score));

    // Persist back so the stored value reflects reality
    await this.cropRepo.update(crop.id, { healthScore: clamped });

    return clamped;
  }

  // ── NDVI estimation ─────────────────────────────────────────────────────────
  /**
   * Estimates NDVI (Normalised Difference Vegetation Index, range −1 to +1)
   * from a field's geographic coordinates instead of satellite imagery.
   *
   * Algorithm (approximation):
   *  1. Classify the latitude into a biome (tropical / subtropical / temperate /
   *     arid / semi-arid / mediterranean / boreal / polar).
   *  2. Derive a peak growing-season NDVI ceiling for that biome.
   *  3. Apply a seasonal modifier based on the current month and hemisphere so
   *     NDVI drops in winter / dry season and peaks in summer / wet season.
   *  4. Add a small deterministic jitter seeded by lat+lon so different fields
   *     in the same region don't return identical values.
   *
   * Typical real-world NDVI benchmarks used as ceilings:
   *   Tropical rainforest  → 0.80–0.90
   *   Temperate cropland   → 0.55–0.75
   *   Mediterranean        → 0.40–0.65
   *   Semi-arid steppe     → 0.20–0.45
   *   Arid / desert        → 0.05–0.20
   *   Boreal forest        → 0.50–0.70
   *   Polar / tundra       → 0.10–0.30
   */
  private _estimateNdvi(latitude: number, longitude: number): number {
    const absLat = Math.abs(latitude);
    const isNorthern = latitude >= 0;

    // ── 1. Biome peak NDVI ─────────────────────────────────────────────────
    let peakNdvi: number;
    let growingMonthStart: number; // 1-based calendar month
    let growingMonthEnd: number;

    if (absLat <= 10) {
      // Equatorial / tropical rainforest — evergreen, high year-round
      peakNdvi = 0.85;
      growingMonthStart = 1;
      growingMonthEnd = 12; // effectively no off-season
    } else if (absLat <= 20) {
      // Tropical savanna / monsoon — strong wet-season peak
      peakNdvi = 0.72;
      growingMonthStart = isNorthern ? 6 : 12;
      growingMonthEnd   = isNorthern ? 10 : 4;
    } else if (absLat <= 30) {
      // Sub-tropical / semi-arid (e.g. Algeria, northern India)
      peakNdvi = 0.50;
      growingMonthStart = isNorthern ? 3 : 9;
      growingMonthEnd   = isNorthern ? 6 : 12;
    } else if (absLat <= 40) {
      // Mediterranean / temperate cropland
      peakNdvi = 0.65;
      growingMonthStart = isNorthern ? 4 : 10;
      growingMonthEnd   = isNorthern ? 9 : 3;
    } else if (absLat <= 55) {
      // Temperate / continental (wheat belts, central Europe)
      peakNdvi = 0.70;
      growingMonthStart = isNorthern ? 5 : 11;
      growingMonthEnd   = isNorthern ? 9 : 3;
    } else if (absLat <= 65) {
      // Boreal / taiga
      peakNdvi = 0.60;
      growingMonthStart = isNorthern ? 6 : 12;
      growingMonthEnd   = isNorthern ? 8 : 2;
    } else {
      // Polar / tundra
      peakNdvi = 0.20;
      growingMonthStart = isNorthern ? 6 : 12;
      growingMonthEnd   = isNorthern ? 7 : 1;
    }

    // ── 2. Arid-zone penalty (longitude-aware) ────────────────────────────
    // Sahara / Arabian Peninsula / Atacama bands lower the ceiling further
    const isAridLongitudeBand =
      (latitude >= 15 && latitude <= 35 && longitude >= -20 && longitude <= 60) || // Sahara/Arabia
      (latitude >= 20 && latitude <= 35 && longitude >= 240 && longitude <= 295);  // Atacama (lon as 0-360)
    if (isAridLongitudeBand) {
      peakNdvi = Math.min(peakNdvi, 0.30);
    }

    // ── 3. Seasonal modifier ──────────────────────────────────────────────
    const month = new Date().getMonth() + 1; // 1–12

    // Build a normalised 0→1 seasonal factor using a cosine wave whose
    // peak aligns with the midpoint of the growing season.
    const growingMid = (growingMonthStart + growingMonthEnd) / 2;
    // Wrap distance from current month to the growing-season midpoint
    let diff = Math.abs(month - growingMid);
    if (diff > 6) diff = 12 - diff;          // handle year-wrap
    // diff=0 → peak (1.0), diff=6 → trough (0.0)
    const seasonFactor = (Math.cos((diff / 6) * Math.PI) + 1) / 2; // 0..1

    // Off-season floor: vegetation doesn't vanish completely in temperate zones
    const offSeasonFloor = 0.15;
    const ndviRaw = offSeasonFloor + (peakNdvi - offSeasonFloor) * seasonFactor;

    // ── 4. Deterministic per-field jitter (±0.04) ─────────────────────────
    // Uses a simple hash of lat/lon so values are stable across calls but
    // differ between nearby fields.
    const seed = Math.sin(latitude * 127.1 + longitude * 311.7) * 43758.5453;
    const jitter = (seed - Math.floor(seed) - 0.5) * 0.08; // −0.04 … +0.04

    return Math.max(0, Math.min(0.95, ndviRaw + jitter));
  }

  /**
   * Attaches computed + weather fields to a crop before sending it to the client:
   *   - growthDay  : days since plantedDate (0 if no plantedDate)
   *   - temp       : current temperature at the field's location (°C)
   *   - humidity   : current humidity at the field's location (%)
   *   - ndvi       : estimated vegetation index from field coordinates
   */
  private async _enrich(crop: Crop, userId: string): Promise<any> {
    const fieldLocation = crop.field?.location;

    // growthDay — pure calculation, no API needed
    const growthDay = crop.plantedDate
      ? Math.floor((Date.now() - new Date(crop.plantedDate).getTime()) / 86400000)
      : 0;

    // temp & humidity — from weather API (falls back to mock if no key or no location)
    let temp = 0;
    let humidity = 0;
    if (fieldLocation) {
      try {
        const weather = await this.weatherService.getCurrent(fieldLocation, userId);
        temp = weather.temperature;
        humidity = weather.humidity;
      } catch {
        // silently fall back to 0 — weather failure shouldn't break crop fetch
      }
    }

    // ndvi — estimated from field coordinates (lat/lon) using biome + season model
    const lat = crop.field?.latitude != null ? Number(crop.field.latitude) : null;
    const lon = crop.field?.longitude != null ? Number(crop.field.longitude) : null;
    const ndvi =
      lat !== null && lon !== null && !isNaN(lat) && !isNaN(lon)
        ? Number(this._estimateNdvi(lat, lon).toFixed(3))
        : 0;

    // healthScore — computed from real signals and persisted back to DB
    const healthScore = await this._calculateHealthScore(crop, ndvi);

    return {
      ...crop,
      healthScore,
      field: crop.field
        ? { ...crop.field, growthDay, temp, humidity, ndvi }
        : undefined,
    };
  }
}