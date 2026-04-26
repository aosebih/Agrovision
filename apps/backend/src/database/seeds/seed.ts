import { DataSource } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import * as dotenv from 'dotenv';
dotenv.config();

async function seed() {
  const dataSource = new DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    username: process.env.DB_USERNAME || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'agri_db',
    entities: [__dirname + '/../../**/*.entity{.ts,.js}'],
    synchronize: true,
  });

  await dataSource.initialize();
  console.log('🌱 Seeding database...');

  // Create demo user
  const hashedPassword = await bcrypt.hash('password123', 10);
  await dataSource.query(`
    INSERT INTO users (id, email, name, password, role, farm_name, is_active, created_at, updated_at)
    VALUES (
      gen_random_uuid(),
      'demo@agriapp.com',
      'Demo Farmer',
      '${hashedPassword}',
      'farmer',
      'Green Valley Farm',
      true,
      NOW(), NOW()
    ) ON CONFLICT (email) DO NOTHING;
  `);

  const user = await dataSource.query(`SELECT id FROM users WHERE email = 'demo@agriapp.com'`);
  const userId = user[0]?.id;
  if (!userId) {
    console.error('User not found');
    process.exit(1);
  }

  // Seed fields
  await dataSource.query(`
    INSERT INTO fields (id, name, location, area_hectares, status, soil_type, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'North Field', 'Section A', 12.5, 'active', 'Clay Loam', '${userId}', NOW(), NOW()),
      (gen_random_uuid(), 'South Field', 'Section B', 8.3, 'active', 'Sandy Loam', '${userId}', NOW(), NOW())
    ON CONFLICT DO NOTHING;
  `);

  const fields = await dataSource.query(`SELECT id, name FROM fields WHERE user_id = '${userId}'`);
  const northField = fields.find((f: any) => f.name === 'North Field');

  // Seed crops
  if (northField) {
    await dataSource.query(`
      INSERT INTO crops (id, name, variety, status, growth_stage, planted_date, expected_harvest_date, health_score, field_id, user_id, created_at, updated_at)
      VALUES
        (gen_random_uuid(), 'Corn', 'Yellow Dent', 'growing', 'vegetative', '2024-03-01', '2024-07-15', 85.0, '${northField.id}', '${userId}', NOW(), NOW()),
        (gen_random_uuid(), 'Wheat', 'Winter Wheat', 'growing', 'flowering', '2023-10-15', '2024-06-01', 78.5, '${northField.id}', '${userId}', NOW(), NOW())
      ON CONFLICT DO NOTHING;
    `);
  }

  // Seed fertilizers
  await dataSource.query(`
    INSERT INTO fertilizers (id, name, brand, type, nitrogen_pct, phosphorus_pct, potassium_pct, unit, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'NPK 20-20-20', 'AgroPlus', 'NPK', 20, 20, 20, 'kg', '${userId}', NOW(), NOW()),
      (gen_random_uuid(), 'Urea 46-0-0', 'FarmChem', 'Nitrogen', 46, 0, 0, 'kg', '${userId}', NOW(), NOW())
    ON CONFLICT DO NOTHING;
  `);

  // Seed inventory
  await dataSource.query(`
    INSERT INTO inventory_items (id, name, category, brand, quantity, unit, min_stock_level, price_per_unit, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'Urea Fertilizer', 'fertilizer', 'FarmChem', 500, 'kg', 100, 0.85, '${userId}', NOW(), NOW()),
      (gen_random_uuid(), 'Corn Seeds', 'seed', 'SeedCo', 200, 'kg', 50, 2.50, '${userId}', NOW(), NOW())
    ON CONFLICT DO NOTHING;
  `);

  // Seed alerts
  await dataSource.query(`
    INSERT INTO alerts (id, title, message, type, severity, is_read, is_acknowledged, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'Frost Warning', 'Expected frost tonight. Protect crops.', 'weather', 'critical', false, false, '${userId}', NOW(), NOW()),
      (gen_random_uuid(), 'Low Moisture', 'North Field soil moisture low', 'crop_health', 'warning', false, false, '${userId}', NOW(), NOW())
    ON CONFLICT DO NOTHING;
  `);

  console.log('✅ Seeding complete!');
  await dataSource.destroy();
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});