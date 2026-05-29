import { MigrationInterface, QueryRunner } from 'typeorm';

export class InitialSchema1700000000000 implements MigrationInterface {
  name = 'InitialSchema1700000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`);

    // Users table
    await queryRunner.query(`
      CREATE TYPE user_role_enum AS ENUM ('admin', 'farmer', 'manager');
      CREATE TABLE users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR UNIQUE NOT NULL,
        name VARCHAR NOT NULL,
        password VARCHAR NOT NULL,
        role user_role_enum NOT NULL DEFAULT 'farmer',
        farm_name VARCHAR,
        is_active BOOLEAN NOT NULL DEFAULT true,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Fields table
    await queryRunner.query(`
      CREATE TYPE field_status_enum AS ENUM ('active', 'fallow', 'harvested');
      CREATE TABLE fields (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR NOT NULL,
        location VARCHAR,
        area_hectares NUMERIC(10,2),
        status field_status_enum NOT NULL DEFAULT 'active',
        soil_type VARCHAR,
        latitude NUMERIC(9,6),
        longitude NUMERIC(9,6),
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Crops table
    await queryRunner.query(`
      CREATE TYPE crop_status_enum AS ENUM ('planted','growing','ready_to_harvest','harvested');
      CREATE TYPE growth_stage_enum AS ENUM ('germination','seedling','vegetative','flowering','fruiting','maturity');
      CREATE TABLE crops (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR NOT NULL,
        variety VARCHAR,
        status crop_status_enum NOT NULL DEFAULT 'planted',
        growth_stage growth_stage_enum,
        planted_date DATE,
        expected_harvest_date DATE,
        actual_harvest_date DATE,
        health_score NUMERIC(5,2),
        notes TEXT,
        field_id UUID REFERENCES fields(id),
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Fertilizers table
    await queryRunner.query(`
      CREATE TABLE fertilizers (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR NOT NULL,
        brand VARCHAR,
        type VARCHAR,
        nitrogen_pct NUMERIC(5,2),
        phosphorus_pct NUMERIC(5,2),
        potassium_pct NUMERIC(5,2),
        description TEXT,
        unit VARCHAR,
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Fertilizer applications table
    await queryRunner.query(`
      CREATE TABLE fertilizer_applications (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        fertilizer_id UUID NOT NULL REFERENCES fertilizers(id),
        field_id UUID REFERENCES fields(id),
        crop_id UUID REFERENCES crops(id),
        quantity NUMERIC(10,2) NOT NULL,
        unit VARCHAR NOT NULL,
        applied_at TIMESTAMPTZ NOT NULL,
        method VARCHAR,
        notes TEXT,
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Irrigation zones table
    await queryRunner.query(`
      CREATE TYPE irrigation_method_enum AS ENUM ('drip','sprinkler','flood','pivot');
      CREATE TYPE zone_status_enum AS ENUM ('active','inactive','maintenance');
      CREATE TABLE irrigation_zones (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR NOT NULL,
        method irrigation_method_enum NOT NULL DEFAULT 'drip',
        status zone_status_enum NOT NULL DEFAULT 'inactive',
        flow_rate_lph NUMERIC(5,2),
        notes TEXT,
        field_id UUID NOT NULL REFERENCES fields(id),
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Irrigation events table
    await queryRunner.query(`
      CREATE TYPE event_status_enum AS ENUM ('scheduled','active','completed','cancelled','failed');
      CREATE TABLE irrigation_events (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        zone_id UUID NOT NULL REFERENCES irrigation_zones(id),
        started_at TIMESTAMPTZ NOT NULL,
        ended_at TIMESTAMPTZ,
        duration_minutes INT,
        water_used_liters NUMERIC(8,2),
        status event_status_enum NOT NULL DEFAULT 'scheduled',
        triggered_by VARCHAR,
        notes TEXT,
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Inventory items table
    await queryRunner.query(`
      CREATE TYPE item_category_enum AS ENUM ('fertilizer','pesticide','seed','equipment','fuel','other');
      CREATE TABLE inventory_items (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name VARCHAR NOT NULL,
        category item_category_enum NOT NULL DEFAULT 'other',
        brand VARCHAR,
        quantity NUMERIC(10,2) NOT NULL,
        unit VARCHAR NOT NULL,
        min_stock_level NUMERIC(10,2),
        price_per_unit NUMERIC(10,2),
        supplier VARCHAR,
        expiry_date DATE,
        notes TEXT,
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Alerts table
    await queryRunner.query(`
      CREATE TYPE alert_type_enum AS ENUM ('weather','crop_health','irrigation','inventory','fertilizer','equipment','system');
      CREATE TYPE alert_severity_enum AS ENUM ('info','warning','critical');
      CREATE TABLE alerts (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR NOT NULL,
        message TEXT NOT NULL,
        type alert_type_enum NOT NULL,
        severity alert_severity_enum NOT NULL DEFAULT 'info',
        is_read BOOLEAN NOT NULL DEFAULT false,
        is_acknowledged BOOLEAN NOT NULL DEFAULT false,
        acknowledged_at TIMESTAMPTZ,
        related_entity_id VARCHAR,
        related_entity_type VARCHAR,
        metadata JSONB,
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Activities table
    await queryRunner.query(`
      CREATE TYPE activity_type_enum AS ENUM ('irrigation','fertilization','treatment','inspection','harvest','planting','soil_test','aerial_survey','manual_check','other');
      CREATE TYPE activity_status_enum AS ENUM ('pending','completed','cancelled');
      CREATE TABLE activities (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR NOT NULL,
        type activity_type_enum NOT NULL,
        status activity_status_enum NOT NULL DEFAULT 'pending',
        description TEXT,
        performed_at TIMESTAMPTZ NOT NULL,
        related_entity_id VARCHAR,
        related_entity_type VARCHAR,
        field_id UUID,
        crop_id UUID,
        metadata JSONB,
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Treatments table
    await queryRunner.query(`
      CREATE TYPE treatment_type_enum AS ENUM ('herbicide','pesticide','fungicide','insecticide','foliar','other');
      CREATE TYPE treatment_status_enum AS ENUM ('planned','completed','cancelled');
      CREATE TABLE treatments (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        product_name VARCHAR NOT NULL,
        type treatment_type_enum NOT NULL DEFAULT 'other',
        status treatment_status_enum NOT NULL DEFAULT 'planned',
        quantity NUMERIC(10,2),
        unit VARCHAR,
        rate_per_ha NUMERIC(8,2),
        applied_date DATE,
        planned_date DATE,
        target_pest VARCHAR,
        notes TEXT,
        field_id UUID REFERENCES fields(id),
        crop_id UUID REFERENCES crops(id),
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);

    // Schedules table
    await queryRunner.query(`
      CREATE TYPE schedule_type_enum AS ENUM ('irrigation','fertilization','treatment','inspection','harvest','other');
      CREATE TYPE recurrence_type_enum AS ENUM ('none','daily','weekly','monthly','custom');
      CREATE TABLE schedules (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        title VARCHAR NOT NULL,
        type schedule_type_enum NOT NULL,
        description TEXT,
        start_time TIMESTAMPTZ NOT NULL,
        end_time TIMESTAMPTZ,
        recurrence recurrence_type_enum NOT NULL DEFAULT 'none',
        recurrence_interval INT,
        is_active BOOLEAN NOT NULL DEFAULT true,
        field_id UUID,
        crop_id UUID,
        zone_id UUID,
        config JSONB,
        user_id UUID NOT NULL REFERENCES users(id),
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
        deleted_at TIMESTAMPTZ
      );
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const tables = [
      'schedules',
      'treatments',
      'activities',
      'alerts',
      'inventory_items',
      'irrigation_events',
      'irrigation_zones',
      'fertilizer_applications',
      'fertilizers',
      'crops',
      'fields',
      'users',
    ];
    for (const t of tables) {
      await queryRunner.query(`DROP TABLE IF EXISTS ${t} CASCADE`);
    }
    const enums = [
      'schedule_type_enum',
      'recurrence_type_enum',
      'treatment_type_enum',
      'treatment_status_enum',
      'activity_type_enum',
      'activity_status_enum',
      'alert_type_enum',
      'alert_severity_enum',
      'item_category_enum',
      'event_status_enum',
      'zone_status_enum',
      'irrigation_method_enum',
      'crop_status_enum',
      'growth_stage_enum',
      'field_status_enum',
      'user_role_enum',
    ];
    for (const e of enums) {
      await queryRunner.query(`DROP TYPE IF EXISTS ${e}`);
    }
  }
}
