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

  // ── Demo user ─────────────────────────────────────────────────────────────
  const demoHash = await bcrypt.hash('password123', 10);
  await dataSource.query(`
    INSERT INTO users (id, email, name, password, role, "farmName", "isActive", "notificationsEnabled", "weatherAlerts", "storageAlerts", "darkMode", language, created_at, updated_at)
    VALUES (gen_random_uuid(), 'demo@agriapp.com', 'Demo Farmer', '${demoHash}', 'farmer', 'Green Valley Farm', true, true, true, false, false, 'ar', NOW(), NOW())
    ON CONFLICT (email) DO NOTHING;
  `);

  const demoRow = await dataSource.query(`SELECT id FROM users WHERE email = 'demo@agriapp.com'`);
  const demoId = demoRow[0]?.id;

  if (demoId) {
    await dataSource.query(`
      INSERT INTO fields (id, name, location, "areaHectares", status, "soilType", user_id, created_at, updated_at)
      VALUES
        (gen_random_uuid(), 'North Field', 'Section A', 12.5, 'active', 'Clay Loam', '${demoId}', NOW(), NOW()),
        (gen_random_uuid(), 'South Field', 'Section B', 8.3,  'active', 'Sandy Loam','${demoId}', NOW(), NOW())
      ON CONFLICT DO NOTHING;
    `);
    const demoFields = await dataSource.query(`SELECT id, name FROM fields WHERE user_id = '${demoId}'`);
    const demoNorth = demoFields.find((f: any) => f.name === 'North Field');
    if (demoNorth) {
      await dataSource.query(`
        INSERT INTO crops (id, name, variety, status, "growthStage", planted_date, expected_harvest_date, "healthScore", field_id, user_id, created_at, updated_at)
        VALUES
          (gen_random_uuid(), 'Corn',  'Yellow Dent',  'growing', 'vegetative', '2024-03-01', '2024-07-15', 85.0, '${demoNorth.id}', '${demoId}', NOW(), NOW()),
          (gen_random_uuid(), 'Wheat', 'Winter Wheat', 'growing', 'flowering',  '2023-10-15', '2024-06-01', 78.5, '${demoNorth.id}', '${demoId}', NOW(), NOW())
        ON CONFLICT DO NOTHING;
      `);
    }
    await dataSource.query(`
      INSERT INTO fertilizers (id, name, brand, type, nitrogen_pct, phosphorus_pct, potassium_pct, unit, user_id, created_at, updated_at)
      VALUES
        (gen_random_uuid(), 'NPK 20-20-20', 'AgroPlus', 'NPK',      20, 20, 20, 'kg', '${demoId}', NOW(), NOW()),
        (gen_random_uuid(), 'Urea 46-0-0',  'FarmChem', 'Nitrogen', 46, 0,  0,  'kg', '${demoId}', NOW(), NOW())
      ON CONFLICT DO NOTHING;
    `);
    await dataSource.query(`
      INSERT INTO inventory_items (id, name, category, brand, quantity, unit, "minStockLevel", "pricePerUnit", user_id, created_at, updated_at)
      VALUES
        (gen_random_uuid(), 'Urea Fertilizer', 'fertilizer', 'FarmChem', 500, 'kg', 100, 0.85, '${demoId}', NOW(), NOW()),
        (gen_random_uuid(), 'Corn Seeds',      'seed',       'SeedCo',   200, 'kg', 50,  2.50, '${demoId}', NOW(), NOW())
      ON CONFLICT DO NOTHING;
    `);
    await dataSource.query(`
      INSERT INTO alerts (id, title, message, type, severity, "isRead", "isAcknowledged", user_id, created_at, updated_at)
      VALUES
        (gen_random_uuid(), 'Frost Warning', 'Expected frost tonight. Protect crops.', 'weather',     'critical', false, false, '${demoId}', NOW(), NOW()),
        (gen_random_uuid(), 'Low Moisture',  'North Field soil moisture low',           'crop_health', 'warning',  false, false, '${demoId}', NOW(), NOW())
      ON CONFLICT DO NOTHING;
    `);
  }

  // ── Old Farmer ────────────────────────────────────────────────────────────
  const oldHash = await bcrypt.hash('oldfarmer12', 10);
  await dataSource.query(`
    INSERT INTO users (id, email, name, password, role, "farmName", "isActive", "notificationsEnabled", "weatherAlerts", "storageAlerts", "darkMode", language, location, created_at, updated_at)
    VALUES (gen_random_uuid(), 'oldfarmer@gmail.com', 'oldfarmer', '${oldHash}', 'farmer', 'مزرعة الأمل', true, true, true, true, false, 'ar', 'سطيف، الجزائر', NOW() - INTERVAL '4 years', NOW())
    ON CONFLICT (email) DO NOTHING;
  `);

  const ofRow = await dataSource.query(`SELECT id FROM users WHERE email = 'oldfarmer@gmail.com'`);
  const uid = ofRow[0]?.id;
  if (!uid) { console.error('oldfarmer not found'); process.exit(1); }

  // Fields
  await dataSource.query(`
    INSERT INTO fields (id, name, location, "areaHectares", status, "soilType", latitude, longitude, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'الحقل الشمالي', 'قطاع أ', 18.5, 'active',    'Clay Loam',  36.1898, 5.4139, '${uid}', NOW() - INTERVAL '4 years', NOW()),
      (gen_random_uuid(), 'الحقل الجنوبي', 'قطاع ب', 12.0, 'active',    'Sandy Loam', 36.1850, 5.4200, '${uid}', NOW() - INTERVAL '4 years', NOW()),
      (gen_random_uuid(), 'حقل الواحة',    'قطاع ج',  9.3, 'active',    'Silty Clay', 36.1920, 5.4080, '${uid}', NOW() - INTERVAL '3 years', NOW()),
      (gen_random_uuid(), 'الحقل الغربي',  'قطاع د',  6.8, 'fallow',    'Loam',       36.1870, 5.4060, '${uid}', NOW() - INTERVAL '2 years', NOW()),
      (gen_random_uuid(), 'حقل الحصاد',    'قطاع هـ', 7.2, 'harvested', 'Clay',       36.1940, 5.4250, '${uid}', NOW() - INTERVAL '3 years', NOW())
    ON CONFLICT DO NOTHING;
  `);

  const fields = await dataSource.query(`SELECT id, name FROM fields WHERE user_id = '${uid}'`);
  const fNorth   = fields.find((f: any) => f.name === 'الحقل الشمالي');
  const fSouth   = fields.find((f: any) => f.name === 'الحقل الجنوبي');
  const fOasis   = fields.find((f: any) => f.name === 'حقل الواحة');
  const fWest    = fields.find((f: any) => f.name === 'الحقل الغربي');
  const fHarvest = fields.find((f: any) => f.name === 'حقل الحصاد');

  // Crops
  await dataSource.query(`
    INSERT INTO crops (id, name, variety, status, "growthStage", planted_date, expected_harvest_date, actual_harvest_date, "healthScore", notes, field_id, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'القمح',      'دوروم',       'growing',          'flowering',  '2025-11-10', '2026-06-15', NULL,         88.0, 'نمو جيد، تم الري مرتين هذا الشهر',     '${fNorth.id}',   '${uid}', NOW() - INTERVAL '6 months',  NOW()),
      (gen_random_uuid(), 'الشعير',     'محلي',        'growing',          'vegetative', '2025-12-01', '2026-05-20', NULL,         82.5, 'يحتاج رشة مبيد في الأسبوع القادم',   '${fNorth.id}',   '${uid}', NOW() - INTERVAL '5 months',  NOW()),
      (gen_random_uuid(), 'الطماطم',    'ريو غراند',   'growing',          'fruiting',   '2026-02-15', '2026-06-01', NULL,         91.0, 'إنتاج ممتاز، ثمار كبيرة وصحية',       '${fSouth.id}',   '${uid}', NOW() - INTERVAL '3 months',  NOW()),
      (gen_random_uuid(), 'الفلفل',     'كاليفورنيا',  'growing',          'flowering',  '2026-02-20', '2026-06-10', NULL,         78.0, 'حاجة لرش مغذيات إضافية',              '${fSouth.id}',   '${uid}', NOW() - INTERVAL '3 months',  NOW()),
      (gen_random_uuid(), 'البطاطا',    'ديزيريه',     'ready_to_harvest', 'maturity',   '2025-10-01', '2026-03-01', NULL,         95.0, 'جاهزة للحصاد، جودة عالية جداً',       '${fOasis.id}',   '${uid}', NOW() - INTERVAL '7 months',  NOW()),
      (gen_random_uuid(), 'الذرة',      'أصفر هجين',   'growing',          'seedling',   '2026-04-01', '2026-09-01', NULL,         74.0, 'زراعة حديثة، تحتاج متابعة',           '${fOasis.id}',   '${uid}', NOW() - INTERVAL '2 months',  NOW()),
      (gen_random_uuid(), 'دوار الشمس', 'هجين 64',     'harvested',        'maturity',   '2025-04-01', '2025-09-15', '2025-09-10', 89.0, 'حصاد ناجح، إنتاج 4.2 طن/هكتار',      '${fHarvest.id}', '${uid}', NOW() - INTERVAL '13 months', NOW()),
      (gen_random_uuid(), 'العدس',      'محلي صغير',   'harvested',        'maturity',   '2024-11-01', '2025-05-01', '2025-04-28', 84.0, 'جودة ممتازة، سعر جيد في السوق',       '${fHarvest.id}', '${uid}', NOW() - INTERVAL '18 months', NOW())
    ON CONFLICT DO NOTHING;
  `);

  const crops = await dataSource.query(`SELECT id, name FROM crops WHERE user_id = '${uid}'`);
  const cWheat  = crops.find((c: any) => c.name === 'القمح');
  const cBarley = crops.find((c: any) => c.name === 'الشعير');
  const cTomato = crops.find((c: any) => c.name === 'الطماطم');
  const cPepper = crops.find((c: any) => c.name === 'الفلفل');
  const cPotato = crops.find((c: any) => c.name === 'البطاطا');
  const cCorn   = crops.find((c: any) => c.name === 'الذرة');

  // Fertilizers
  await dataSource.query(`
    INSERT INTO fertilizers (id, name, brand, type, nitrogen_pct, phosphorus_pct, potassium_pct, description, unit, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'NPK 20-20-20',      'AgroPlus', 'NPK',        20, 20, 20, 'سماد متوازن لجميع المراحل',          'kg', '${uid}', NOW() - INTERVAL '4 years', NOW()),
      (gen_random_uuid(), 'يوريا 46',           'FarmChem', 'Nitrogen',   46,  0,  0, 'مصدر نيتروجين عالي للنمو الخضري',   'kg', '${uid}', NOW() - INTERVAL '3 years', NOW()),
      (gen_random_uuid(), 'سوبر فوسفات',        'PhosAg',   'Phosphorus',  0, 46,  0, 'يقوي الجذور ويحسن الإنتاج',         'kg', '${uid}', NOW() - INTERVAL '3 years', NOW()),
      (gen_random_uuid(), 'كبريتات البوتاسيوم', 'KaliPro',  'Potassium',   0,  0, 50, 'يحسن جودة الثمار ومقاومة الأمراض', 'kg', '${uid}', NOW() - INTERVAL '2 years', NOW()),
      (gen_random_uuid(), 'سماد عضوي كومبوست',  'BioFarm',  'Organic',     2,  1,  1, 'سماد طبيعي يحسن بنية التربة',       'kg', '${uid}', NOW() - INTERVAL '4 years', NOW()),
      (gen_random_uuid(), 'نترات الأمونيوم 33', 'NitroMax', 'Nitrogen',   33,  0,  0, 'سريع الذوبان للإضافة عبر الري',     'kg', '${uid}', NOW() - INTERVAL '2 years', NOW())
    ON CONFLICT DO NOTHING;
  `);

  const fertRows = await dataSource.query(`SELECT id, name FROM fertilizers WHERE user_id = '${uid}'`);
  const fNPK     = fertRows.find((f: any) => f.name === 'NPK 20-20-20');
  const fUrea    = fertRows.find((f: any) => f.name === 'يوريا 46');
  const fPhos    = fertRows.find((f: any) => f.name === 'سوبر فوسفات');
  const fKali    = fertRows.find((f: any) => f.name === 'كبريتات البوتاسيوم');
  const fOrganic = fertRows.find((f: any) => f.name === 'سماد عضوي كومبوست');

  // Fertilizer applications
  const fertApps = [
    { fid: fOrganic.id, field: fNorth.id,  crop: cWheat.id,  qty: 800,  unit: 'kg', at: `NOW() - INTERVAL '6 months'`,  method: 'broadcast',    notes: 'تحضير التربة قبل الزراعة' },
    { fid: fNPK.id,     field: fNorth.id,  crop: cWheat.id,  qty: 120,  unit: 'kg', at: `NOW() - INTERVAL '4 months'`,  method: 'broadcast',    notes: 'التسميد الأساسي' },
    { fid: fUrea.id,    field: fNorth.id,  crop: cWheat.id,  qty: 80,   unit: 'kg', at: `NOW() - INTERVAL '2 months'`,  method: 'top_dressing', notes: 'تنشيط النمو الخضري' },
    { fid: fNPK.id,     field: fNorth.id,  crop: cBarley.id, qty: 100,  unit: 'kg', at: `NOW() - INTERVAL '5 months'`,  method: 'broadcast',    notes: 'التسميد عند الزراعة' },
    { fid: fUrea.id,    field: fNorth.id,  crop: cBarley.id, qty: 60,   unit: 'kg', at: `NOW() - INTERVAL '3 months'`,  method: 'top_dressing', notes: 'دفعة نيتروجين' },
    { fid: fOrganic.id, field: fSouth.id,  crop: cTomato.id, qty: 600,  unit: 'kg', at: `NOW() - INTERVAL '3 months'`,  method: 'incorporated', notes: 'تحسين التربة' },
    { fid: fNPK.id,     field: fSouth.id,  crop: cTomato.id, qty: 90,   unit: 'kg', at: `NOW() - INTERVAL '2 months'`,  method: 'fertigation',  notes: 'عبر نظام التنقيط' },
    { fid: fKali.id,    field: fSouth.id,  crop: cTomato.id, qty: 45,   unit: 'kg', at: `NOW() - INTERVAL '5 weeks'`,   method: 'fertigation',  notes: 'لتحسين جودة الثمار' },
    { fid: fNPK.id,     field: fSouth.id,  crop: cPepper.id, qty: 80,   unit: 'kg', at: `NOW() - INTERVAL '2 months'`,  method: 'broadcast',    notes: 'التسميد الأساسي' },
    { fid: fPhos.id,    field: fSouth.id,  crop: cPepper.id, qty: 50,   unit: 'kg', at: `NOW() - INTERVAL '6 weeks'`,   method: 'incorporated', notes: 'تقوية الجذور' },
    { fid: fOrganic.id, field: fOasis.id,  crop: cPotato.id, qty: 1200, unit: 'kg', at: `NOW() - INTERVAL '7 months'`,  method: 'incorporated', notes: 'قبل الزراعة' },
    { fid: fNPK.id,     field: fOasis.id,  crop: cPotato.id, qty: 150,  unit: 'kg', at: `NOW() - INTERVAL '5 months'`,  method: 'broadcast',    notes: 'التسميد الأساسي' },
    { fid: fKali.id,    field: fOasis.id,  crop: cPotato.id, qty: 80,   unit: 'kg', at: `NOW() - INTERVAL '3 months'`,  method: 'fertigation',  notes: 'تحسين حجم الدرنات' },
    { fid: fNPK.id,     field: fOasis.id,  crop: cCorn.id,   qty: 70,   unit: 'kg', at: `NOW() - INTERVAL '7 weeks'`,   method: 'broadcast',    notes: 'عند الزراعة' },
    { fid: fUrea.id,    field: fOasis.id,  crop: cCorn.id,   qty: 40,   unit: 'kg', at: `NOW() - INTERVAL '3 weeks'`,   method: 'top_dressing', notes: 'دفعة النيتروجين الأولى' },
  ];
  for (const a of fertApps) {
    await dataSource.query(`
      INSERT INTO fertilizer_applications (id, fertilizer_id, field_id, crop_id, quantity, unit, applied_at, method, notes, user_id, created_at, updated_at)
      VALUES (gen_random_uuid(), '${a.fid}', '${a.field}', '${a.crop}', ${a.qty}, '${a.unit}', ${a.at}, '${a.method}', '${a.notes}', '${uid}', ${a.at}, NOW())
      ON CONFLICT DO NOTHING;
    `);
  }

  // Inventory
  await dataSource.query(`
    INSERT INTO inventory_items (id, name, category, brand, quantity, unit, "minStockLevel", "pricePerUnit", supplier, "expiryDate", notes, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'يوريا 46',             'fertilizer', 'FarmChem',    320, 'kg',   100, 65.00,  'الشركة الجزائرية للأسمدة', '2027-12-01', 'مخزن في المستودع الرئيسي',    '${uid}', NOW() - INTERVAL '2 months', NOW()),
      (gen_random_uuid(), 'NPK 20-20-20',          'fertilizer', 'AgroPlus',    180, 'kg',    80, 72.00,  'AgroPlus الجزائر',          '2027-06-01', 'نصف الكمية متبقية',           '${uid}', NOW() - INTERVAL '1 month',  NOW()),
      (gen_random_uuid(), 'بذور قمح دوروم',        'seed',       'SeedAlgerie', 450, 'kg',   200, 55.00,  'مؤسسة البذور الوطنية',      '2026-09-01', 'معبأة في أكياس 50 كغ',        '${uid}', NOW() - INTERVAL '3 months', NOW()),
      (gen_random_uuid(), 'بذور طماطم ريو غراند', 'seed',       'Clauseen',     12, 'kg',     5, 420.00, 'مستورد من إسبانيا',          '2026-08-01', 'بذور محقونة ضد الأمراض',     '${uid}', NOW() - INTERVAL '2 months', NOW()),
      (gen_random_uuid(), 'مبيد أمثيسترين',       'pesticide',  'BayerCrop',    28, 'L',     10, 380.00, 'وكيل بايير الجزائر',        '2026-03-01', 'للحشرات الماصة',             '${uid}', NOW() - INTERVAL '1 month',  NOW()),
      (gen_random_uuid(), 'فطرية مانكوزيب',       'pesticide',  'SyngentaAlg',  35, 'kg',    15, 210.00, 'سينجنتا الجزائر',           '2026-07-01', 'لعلاج البياض الدقيقي',       '${uid}', NOW() - INTERVAL '6 weeks',  NOW()),
      (gen_random_uuid(), 'وقود ديزل',             'fuel',       'Sonatrach',   800, 'L',    300, 20.50,  'محطة سطيف المركزية',        NULL,         'خزان المزرعة 1000 لتر',       '${uid}', NOW() - INTERVAL '2 weeks',  NOW()),
      (gen_random_uuid(), 'زيت محرك 15W-40',      'fuel',       'Total',        24, 'L',     10, 450.00, 'توتال الجزائر',             NULL,         'للجرار والمعدات',             '${uid}', NOW() - INTERVAL '1 month',  NOW()),
      (gen_random_uuid(), 'خرطوم ري تنقيط 16mm', 'equipment',  'Netafim',     800, 'm',    200, 18.00,  'Netafim الجزائر',           NULL,         'احتياط لصيانة الشبكة',        '${uid}', NOW() - INTERVAL '3 months', NOW()),
      (gen_random_uuid(), 'مضخة ري 5.5 حصان',    'equipment',  'Grundfos',      2, 'unit',   1, 45000,  'توزيع المضخات سطيف',        NULL,         'واحدة رئيسية وواحدة احتياط', '${uid}', NOW() - INTERVAL '1 year',   NOW()),
      (gen_random_uuid(), 'كبريتات البوتاسيوم',  'fertilizer', 'KaliPro',      90, 'kg',    40, 95.00,  'KaliPro المغرب',            '2028-01-01', 'عالي الجودة منخفض الكلور',   '${uid}', NOW() - INTERVAL '6 weeks',  NOW()),
      (gen_random_uuid(), 'أسلاك ربط شبكة',      'other',      'AgroMat',     500, 'm',    100, 12.00,  'محلات الفلاحة',             NULL,         'للدعامات والتعريش',           '${uid}', NOW() - INTERVAL '2 months', NOW())
    ON CONFLICT DO NOTHING;
  `);

  // Irrigation zones
  await dataSource.query(`
    INSERT INTO irrigation_zones (id, name, method, status, flow_rate_lph, notes, field_id, user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'منطقة الشمال أ', 'drip',      'active',   2400, 'نظام تنقيط رئيسي للقمح',       '${fNorth.id}', '${uid}', NOW() - INTERVAL '3 years', NOW()),
      (gen_random_uuid(), 'منطقة الشمال ب', 'sprinkler', 'active',   5800, 'رش للشعير وباقي المحاصيل',     '${fNorth.id}', '${uid}', NOW() - INTERVAL '3 years', NOW()),
      (gen_random_uuid(), 'منطقة الجنوب',   'drip',      'active',   3200, 'تنقيط للخضروات بضغط عالٍ',    '${fSouth.id}', '${uid}', NOW() - INTERVAL '2 years', NOW()),
      (gen_random_uuid(), 'منطقة الواحة',   'drip',      'active',   2800, 'تنقيط للبطاطا والذرة',         '${fOasis.id}', '${uid}', NOW() - INTERVAL '2 years', NOW()),
      (gen_random_uuid(), 'منطقة الغرب',    'flood',     'inactive', 0,    'ري بالغمر موقوف مؤقتاً',      '${fWest.id}',  '${uid}', NOW() - INTERVAL '1 year',  NOW())
    ON CONFLICT DO NOTHING;
  `);

  const zones = await dataSource.query(`SELECT id, name FROM irrigation_zones WHERE user_id = '${uid}'`);
  const zNorthA = zones.find((z: any) => z.name === 'منطقة الشمال أ');
  const zNorthB = zones.find((z: any) => z.name === 'منطقة الشمال ب');
  const zSouth  = zones.find((z: any) => z.name === 'منطقة الجنوب');
  const zOasis  = zones.find((z: any) => z.name === 'منطقة الواحة');

  // Irrigation events
  const irrigEvents = [
    { zone: zNorthA.id, start: `NOW() - INTERVAL '7 days'`,  dur: 90,  water: 3600, status: 'completed', by: 'schedule' },
    { zone: zNorthA.id, start: `NOW() - INTERVAL '14 days'`, dur: 90,  water: 3600, status: 'completed', by: 'schedule' },
    { zone: zNorthA.id, start: `NOW() - INTERVAL '21 days'`, dur: 90,  water: 3600, status: 'completed', by: 'schedule' },
    { zone: zNorthA.id, start: `NOW() - INTERVAL '28 days'`, dur: 90,  water: 3600, status: 'completed', by: 'schedule' },
    { zone: zNorthA.id, start: `NOW() - INTERVAL '42 days'`, dur: 120, water: 4800, status: 'completed', by: 'manual'   },
    { zone: zNorthA.id, start: `NOW() - INTERVAL '60 days'`, dur: 90,  water: 3600, status: 'completed', by: 'schedule' },
    { zone: zNorthB.id, start: `NOW() - INTERVAL '5 days'`,  dur: 60,  water: 5800, status: 'completed', by: 'schedule' },
    { zone: zNorthB.id, start: `NOW() - INTERVAL '12 days'`, dur: 60,  water: 5800, status: 'completed', by: 'schedule' },
    { zone: zNorthB.id, start: `NOW() - INTERVAL '19 days'`, dur: 60,  water: 5800, status: 'completed', by: 'schedule' },
    { zone: zNorthB.id, start: `NOW() - INTERVAL '26 days'`, dur: 60,  water: 5800, status: 'completed', by: 'schedule' },
    { zone: zSouth.id,  start: `NOW() - INTERVAL '2 days'`,  dur: 45,  water: 2400, status: 'completed', by: 'schedule' },
    { zone: zSouth.id,  start: `NOW() - INTERVAL '5 days'`,  dur: 45,  water: 2400, status: 'completed', by: 'schedule' },
    { zone: zSouth.id,  start: `NOW() - INTERVAL '8 days'`,  dur: 45,  water: 2400, status: 'completed', by: 'schedule' },
    { zone: zSouth.id,  start: `NOW() - INTERVAL '11 days'`, dur: 45,  water: 2400, status: 'completed', by: 'schedule' },
    { zone: zSouth.id,  start: `NOW() - INTERVAL '16 days'`, dur: 60,  water: 3200, status: 'completed', by: 'manual'   },
    { zone: zOasis.id,  start: `NOW() - INTERVAL '3 days'`,  dur: 75,  water: 3500, status: 'completed', by: 'schedule' },
    { zone: zOasis.id,  start: `NOW() - INTERVAL '10 days'`, dur: 75,  water: 3500, status: 'completed', by: 'schedule' },
    { zone: zOasis.id,  start: `NOW() - INTERVAL '17 days'`, dur: 75,  water: 3500, status: 'completed', by: 'schedule' },
    { zone: zNorthA.id, start: `NOW() + INTERVAL '7 days'`,  dur: 90,  water: null, status: 'scheduled', by: 'schedule' },
    { zone: zSouth.id,  start: `NOW() + INTERVAL '2 days'`,  dur: 45,  water: null, status: 'scheduled', by: 'schedule' },
    { zone: zOasis.id,  start: `NOW() + INTERVAL '4 days'`,  dur: 75,  water: null, status: 'scheduled', by: 'schedule' },
  ];
  for (const e of irrigEvents) {
    const endAt    = e.status === 'completed' ? `(${e.start})::timestamptz + INTERVAL '${e.dur} minutes'` : 'NULL';
    const waterVal = e.water !== null ? e.water : 'NULL';
    await dataSource.query(`
      INSERT INTO irrigation_events (id, zone_id, started_at, ended_at, duration_minutes, water_used_liters, status, triggered_by, user_id, created_at, updated_at)
      VALUES (gen_random_uuid(), '${e.zone}', ${e.start}, ${endAt}, ${e.dur}, ${waterVal}, '${e.status}', '${e.by}', '${uid}', ${e.start}, NOW())
      ON CONFLICT DO NOTHING;
    `);
  }

  // Treatments
  const treatments = [
    { product: 'ثيوفانات ميثيل',   type: 'fungicide',   status: 'completed', qty: 3.5, unit: 'kg', rate: 0.19, applied: `NOW() - INTERVAL '8 weeks'`,  planned: null,                         pest: 'صدأ القمح',            field: fNorth.id, crop: cWheat.id,  notes: 'رش عند ظهور الأعراض الأولى' },
    { product: 'مانكوزيب',         type: 'fungicide',   status: 'completed', qty: 4.0, unit: 'kg', rate: 0.22, applied: `NOW() - INTERVAL '5 weeks'`,  planned: null,                         pest: 'البياض الزغبي',        field: fNorth.id, crop: cBarley.id, notes: 'وقائي قبل موسم الأمطار' },
    { product: 'أبامكتين',         type: 'insecticide', status: 'completed', qty: 1.5, unit: 'L',  rate: 0.08, applied: `NOW() - INTERVAL '3 weeks'`,  planned: null,                         pest: 'عنكبوت أحمر',          field: fSouth.id, crop: cTomato.id, notes: 'إصابة متوسطة تمت السيطرة' },
    { product: 'غليفوسات',         type: 'herbicide',   status: 'completed', qty: 8.0, unit: 'L',  rate: 0.44, applied: `NOW() - INTERVAL '10 weeks'`, planned: null,                         pest: 'أعشاب عريضة الأوراق', field: fNorth.id, crop: null,       notes: 'ما قبل الزراعة للحقل' },
    { product: 'إيميداكلوبريد',    type: 'insecticide', status: 'completed', qty: 2.0, unit: 'L',  rate: 0.17, applied: `NOW() - INTERVAL '6 weeks'`,  planned: null,                         pest: 'حشرة المن',            field: fSouth.id, crop: cPepper.id, notes: 'اشتداد الإصابة بعد الحرارة' },
    { product: 'سيبروكونازول',     type: 'fungicide',   status: 'completed', qty: 2.5, unit: 'L',  rate: 0.13, applied: `NOW() - INTERVAL '4 weeks'`,  planned: null,                         pest: 'لفحة الأوراق المبكرة',field: fOasis.id, crop: cPotato.id, notes: 'رش وقائي لمنع الانتشار' },
    { product: 'كلوربيريفوس',      type: 'pesticide',   status: 'completed', qty: 5.0, unit: 'L',  rate: 0.28, applied: `NOW() - INTERVAL '5 months'`, planned: null,                         pest: 'نيماتودا التربة',      field: fOasis.id, crop: null,       notes: 'معالجة قبل زراعة البطاطا' },
    { product: 'سبينوساد',         type: 'insecticide', status: 'planned',   qty: 1.8, unit: 'L',  rate: 0.15, applied: null,                          planned: `NOW() + INTERVAL '3 days'`,  pest: 'حشرة الثريبس',        field: fSouth.id, crop: cTomato.id, notes: 'مجدول بعد انتهاء مفعول الأول' },
    { product: 'كلسيوم بورون',     type: 'foliar',      status: 'planned',   qty: 3.0, unit: 'kg', rate: 0.17, applied: null,                          planned: `NOW() + INTERVAL '7 days'`,  pest: null,                   field: fSouth.id, crop: cPepper.id, notes: 'لتقوية عقد الثمار' },
    { product: 'كابتان 50%',       type: 'fungicide',   status: 'planned',   qty: 4.5, unit: 'kg', rate: 0.25, applied: null,                          planned: `NOW() + INTERVAL '14 days'`, pest: 'أمراض فطرية',         field: fNorth.id, crop: cWheat.id,  notes: 'رش وقائي موسمي' },
  ];
  for (const t of treatments) {
    const appliedVal = t.applied ? `(${t.applied})::date` : 'NULL';
    const plannedVal = t.planned ? `(${t.planned})::date` : 'NULL';
    const pestVal    = t.pest    ? `'${t.pest}'`          : 'NULL';
    const cropVal    = t.crop    ? `'${t.crop}'`          : 'NULL';
    await dataSource.query(`
      INSERT INTO treatments (id, "productName", type, status, quantity, unit, "ratePerHa", applied_date, planned_date, "targetPest", notes, field_id, crop_id, user_id, created_at, updated_at)
      VALUES (gen_random_uuid(), '${t.product}', '${t.type}', '${t.status}', ${t.qty}, '${t.unit}', ${t.rate}, ${appliedVal}, ${plannedVal}, ${pestVal}, '${t.notes}', '${t.field}', ${cropVal}, '${uid}', NOW() - INTERVAL '3 months', NOW())
      ON CONFLICT DO NOTHING;
    `);
  }

  // Schedules
  await dataSource.query(`
    INSERT INTO schedules (id, title, type, description, start_time, end_time, recurrence, "recurrenceInterval", "isActive", "fieldId", "cropId", "zoneId", user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'ري أسبوعي - الشمال أ', 'irrigation',    'ري تنقيط القمح كل أسبوع',           NOW() + INTERVAL '7 days',  NOW() + INTERVAL '7 days 2 hours', 'weekly',  1,    true, '${fNorth.id}', '${cWheat.id}',  '${zNorthA.id}', '${uid}', NOW() - INTERVAL '6 months', NOW()),
      (gen_random_uuid(), 'ري ثلاثي - الجنوب',    'irrigation',    'ري تنقيط الطماطم ثلاث مرات أسبوع', NOW() + INTERVAL '2 days',  NULL,                              'weekly',  1,    true, '${fSouth.id}', '${cTomato.id}', '${zSouth.id}',  '${uid}', NOW() - INTERVAL '3 months', NOW()),
      (gen_random_uuid(), 'فحص القمح الأسبوعي',   'inspection',    'مراقبة الأمراض والآفات',             NOW() + INTERVAL '3 days',  NULL,                              'weekly',  1,    true, '${fNorth.id}', '${cWheat.id}',  NULL,            '${uid}', NOW() - INTERVAL '5 months', NOW()),
      (gen_random_uuid(), 'تسميد شهري الطماطم',   'fertilization', 'إضافة NPK عبر التنقيط',             NOW() + INTERVAL '15 days', NULL,                              'monthly', 1,    true, '${fSouth.id}', '${cTomato.id}', NULL,            '${uid}', NOW() - INTERVAL '3 months', NOW()),
      (gen_random_uuid(), 'معالجة فطرية وقائية',  'treatment',     'رش مانكوزيب وقائي',                 NOW() + INTERVAL '14 days', NULL,                              'monthly', 1,    true, '${fNorth.id}', '${cWheat.id}',  NULL,            '${uid}', NOW() - INTERVAL '4 months', NOW()),
      (gen_random_uuid(), 'جرد المخزون الشهري',   'inspection',    'فحص المخزون وتحديث السجلات',        NOW() + INTERVAL '10 days', NULL,                              'monthly', 1,    true, NULL,           NULL,            NULL,            '${uid}', NOW() - INTERVAL '1 year',   NOW()),
      (gen_random_uuid(), 'حصاد البطاطا',          'harvest',       'البطاطا جاهزة للحصاد',              NOW() + INTERVAL '5 days',  NOW() + INTERVAL '8 days',         'none',    NULL, true, '${fOasis.id}', '${cPotato.id}', NULL,            '${uid}', NOW() - INTERVAL '1 month',  NOW())
    ON CONFLICT DO NOTHING;
  `);

  // Activities
  const activities = [
    { title: 'زراعة القمح الدوروم',       type: 'planting',      status: 'completed', desc: 'تمت الزراعة بمعدل 180 كغ/هكتار',                        at: `NOW() - INTERVAL '6 months'`,  field: fNorth.id,   crop: cWheat.id  },
    { title: 'زراعة الطماطم ريو غراند',  type: 'planting',      status: 'completed', desc: 'شتلات مزروعة بمسافة 60×40 سم',                           at: `NOW() - INTERVAL '3 months'`,  field: fSouth.id,   crop: cTomato.id },
    { title: 'زراعة الذرة الهجين',       type: 'planting',      status: 'completed', desc: 'بذور معالجة، عمق 5 سم، كثافة 7 نباتات/م²',             at: `NOW() - INTERVAL '2 months'`,  field: fOasis.id,   crop: cCorn.id   },
    { title: 'فحص صحة القمح',            type: 'inspection',    status: 'completed', desc: 'لا أمراض ظاهرة، نمو منتظم في جميع القطاعات',           at: `NOW() - INTERVAL '5 weeks'`,   field: fNorth.id,   crop: cWheat.id  },
    { title: 'فحص الطماطم - إنتاج جيد', type: 'inspection',    status: 'completed', desc: 'ثمار تبلغ 80% من حجمها النهائي، لون أخضر غامق',         at: `NOW() - INTERVAL '2 weeks'`,   field: fSouth.id,   crop: cTomato.id },
    { title: 'فحص البطاطا للحصاد',      type: 'inspection',    status: 'completed', desc: 'درنات كبيرة وسليمة، جاهزة للحصاد خلال أسبوع',          at: `NOW() - INTERVAL '1 week'`,    field: fOasis.id,   crop: cPotato.id },
    { title: 'ري إضافي بسبب الحرارة',   type: 'irrigation',    status: 'completed', desc: 'ري استثنائي بسبب الحرارة الشديدة 38 درجة',              at: `NOW() - INTERVAL '10 days'`,   field: fSouth.id,   crop: cTomato.id },
    { title: 'تسميد يوريا للقمح',        type: 'fertilization', status: 'completed', desc: '80 كغ يوريا موزعة بشكل منتظم على 18 هكتار',            at: `NOW() - INTERVAL '2 months'`,  field: fNorth.id,   crop: cWheat.id  },
    { title: 'معالجة صدأ القمح',         type: 'treatment',     status: 'completed', desc: 'رش ثيوفانات ميثيل، تمت السيطرة على الإصابة',           at: `NOW() - INTERVAL '8 weeks'`,   field: fNorth.id,   crop: cWheat.id  },
    { title: 'مكافحة العنكبوت الأحمر',  type: 'treatment',     status: 'completed', desc: 'رش أبامكتين، تراجع الإصابة بنسبة 90%',                 at: `NOW() - INTERVAL '3 weeks'`,   field: fSouth.id,   crop: cTomato.id },
    { title: 'اختبار تربة الحقل الشمالي',type:'soil_test',     status: 'completed', desc: 'pH 7.2، نيتروجين متوسط، فوسفور منخفض، بوتاسيوم كافٍ', at: `NOW() - INTERVAL '4 months'`,  field: fNorth.id,   crop: null       },
    { title: 'اختبار تربة حقل الواحة',  type: 'soil_test',     status: 'completed', desc: 'pH 7.0، نيتروجين جيد، مناسب للبطاطا والذرة',           at: `NOW() - INTERVAL '8 months'`,  field: fOasis.id,   crop: null       },
    { title: 'حصاد دوار الشمس',         type: 'harvest',       status: 'completed', desc: 'إنتاج 4.2 طن/هكتار، رطوبة 8%، جودة ممتازة',           at: `NOW() - INTERVAL '13 months'`, field: fHarvest.id, crop: null       },
    { title: 'حصاد العدس',              type: 'harvest',       status: 'completed', desc: 'إنتاج 1.8 طن/هكتار، سعر 180 دج/كغ',                    at: `NOW() - INTERVAL '13 months'`, field: fHarvest.id, crop: null       },
    { title: 'صيانة نظام التنقيط',      type: 'manual_check',  status: 'completed', desc: 'استبدال 3 قطارات متآكلة، ضبط الضغط',                   at: `NOW() - INTERVAL '1 month'`,   field: fSouth.id,   crop: null       },
    { title: 'صيانة الجرار الموسمية',   type: 'other',         status: 'completed', desc: 'تغيير زيت المحرك وفلتر الهواء، فحص شامل',              at: `NOW() - INTERVAL '6 weeks'`,   field: null,        crop: null       },
  ];
  for (const a of activities) {
    const cropVal  = a.crop  ? `'${a.crop}'`  : 'NULL';
    const fieldVal = a.field ? `'${a.field}'` : 'NULL';
    await dataSource.query(`
      INSERT INTO activities (id, title, type, status, description, performed_at, "fieldId", "cropId", user_id, created_at, updated_at)
      VALUES (gen_random_uuid(), '${a.title}', '${a.type}', '${a.status}', '${a.desc}', ${a.at}, ${fieldVal}, ${cropVal}, '${uid}', ${a.at}, NOW())
      ON CONFLICT DO NOTHING;
    `);
  }

  // Alerts
  await dataSource.query(`
    INSERT INTO alerts (id, title, message, type, severity, "isRead", "isAcknowledged", user_id, created_at, updated_at)
    VALUES
      (gen_random_uuid(), 'البطاطا جاهزة للحصاد', 'حقل الواحة: البطاطا بلغت مرحلة النضج الكامل، ينصح بالحصاد خلال 5-7 أيام.',       'crop_health', 'critical', false, false, '${uid}', NOW() - INTERVAL '2 days',   NOW()),
      (gen_random_uuid(), 'مخزون وقود منخفض',      'مستوى الوقود وصل إلى 20%، يُنصح بإعادة الملء قبل موسم الحصاد.',                 'inventory',   'warning',  false, false, '${uid}', NOW() - INTERVAL '1 day',    NOW()),
      (gen_random_uuid(), 'توقع موجة حرارة',       'ارتفاع درجات الحرارة إلى 42 درجة يومي الأربعاء والخميس. فعّل الري المكثف.',     'weather',     'critical', false, false, '${uid}', NOW() - INTERVAL '12 hours', NOW()),
      (gen_random_uuid(), 'موعد تسميد الطماطم',    'اقترب موعد جرعة NPK الشهرية لمحصول الطماطم. الكمية المطلوبة: 90 كغ.',            'fertilizer',  'info',     false, false, '${uid}', NOW() - INTERVAL '3 days',   NOW()),
      (gen_random_uuid(), 'مبيد الثريبس - تجديد', 'انتهى مفعول الرش الأول. الرشة الثانية مجدولة بعد 3 أيام.',                       'crop_health', 'warning',  false, false, '${uid}', NOW() - INTERVAL '1 day',    NOW()),
      (gen_random_uuid(), 'رصد أمطار محتملة',      'توقعات بأمطار خفيفة الأسبوع القادم. قد يتأثر جدول الري.',                        'weather',     'info',     true,  true,  '${uid}', NOW() - INTERVAL '5 days',   NOW()),
      (gen_random_uuid(), 'مخزون بذور القمح جاهز','تم تسلم 450 كغ بذور قمح دوروم. المخزون جاهز للموسم القادم.',                     'inventory',   'info',     true,  true,  '${uid}', NOW() - INTERVAL '1 week',   NOW()),
      (gen_random_uuid(), 'صيانة الري مكتملة',     'تمت صيانة نظام التنقيط بنجاح. الضغط طبيعي في جميع المناطق.',                   'irrigation',  'info',     true,  true,  '${uid}', NOW() - INTERVAL '1 month',  NOW())
    ON CONFLICT DO NOTHING;
  `);

  console.log('✅ Seeding complete!');
  await dataSource.destroy();
}

seed().catch((err) => {
  console.error(err);
  process.exit(1);
});
