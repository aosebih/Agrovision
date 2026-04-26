// ─── Data models (mock data) ──────────────────────────────────────────────────

class CropModel {
  final String id;
  final String name;
  final String field;
  final String variety;
  final double health;       // 0.0 – 1.0
  final String status;       // 'سليمة' | 'تحذير' | 'حرجة'
  final double humidity;
  final double temp;
  final String imagePath;

  const CropModel({required this.id, required this.name, required this.field,
      required this.variety, required this.health, required this.status,
      required this.humidity, required this.temp, required this.imagePath});
}

class InventoryItem {
  final String id;
  final String name;
  final String supplier;
  final double current;
  final double capacity;
  final String unit;
  final String status;       // 'متوفر' | 'مخزون منخفض' | 'متوسط'
  final String imagePath;

  const InventoryItem({required this.id, required this.name,
      required this.supplier, required this.current, required this.capacity,
      required this.unit, required this.status, required this.imagePath});

  double get percentage => (current / capacity).clamp(0.0, 1.0);
}

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String type;         // 'حرجة' | 'تحذير' | 'معلومات'
  final String time;
  final String field;

  const AlertModel({required this.id, required this.title,
      required this.description, required this.type,
      required this.time, required this.field});
}

class ActivityModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String category;    // 'ري' | 'سماد' | 'تنبيه' | 'فحص'
  final String status;      // 'مكتمل' | 'قيد التشغيل' | 'مطلوب اتخاذ إجراء'

  const ActivityModel({required this.id, required this.title,
      required this.subtitle, required this.time,
      required this.category, required this.status});
}

// ─── Mock Data ────────────────────────────────────────────────────────────────
class MockData {
  static const List<CropModel> crops = [
    CropModel(id:'1', name:'حقل القمح أ', field:'حقل الشمال', variety:'قمح شتوي أحمر', health:0.92, status:'سليمة', humidity:42, temp:24, imagePath:'lib/compenent/images/Wheat field.png'),
    CropModel(id:'2', name:'قسم الذرة ب', field:'حقل الوسط', variety:'ذرة حلوة', health:0.65, status:'يحتاج ماء', humidity:18, temp:28, imagePath:'lib/compenent/images/Corn.png'),
    CropModel(id:'3', name:'4قطعة فول الصويا', field:'المنطقة الجنوبية', variety:'مقاوم للقليقوسات', health:0.45, status:'تحذير', humidity:35, temp:26, imagePath:'lib/compenent/images/Soybean.png'),
    CropModel(id:'4', name:'حقل الأرزج', field:'المنطقة الشرقية', variety:'باسمتي', health:0.88, status:'سليمة', humidity:55, temp:22, imagePath:'lib/compenent/images/Rice.png'),
  ];

  static const List<InventoryItem> inventory = [
    InventoryItem(id:'1', name:'سماد اليوريا', supplier:'شركة أجريكورب العالمية', current:15, capacity:100, unit:'كجم', status:'مخزون منخفض', imagePath:'lib/compenent/images/Sack of urea fertilizer granules.png'),
    InventoryItem(id:'2', name:'بذور القمح HYV', supplier:'بذور جرين فيلد', current:400, capacity:500, unit:'كجم', status:'متوفر', imagePath:'lib/compenent/images/Golden wheat seeds in hands.png'),
    InventoryItem(id:'3', name:'X-200 مبيد حشرى', supplier:'شركة كيم أجرو', current:90, capacity:200, unit:'لتر', status:'متوسط', imagePath:'lib/compenent/images/Pesticide sprayer bottle close up.png'),
    InventoryItem(id:'4', name:'سماد عضوي', supplier:'مزرعة البيئة النظيفة', current:350, capacity:1000, unit:'كجم', status:'متوفر', imagePath:'lib/compenent/images/Organic compost soil texture.png'),
  ];

  static const List<AlertModel> alerts = [
    AlertModel(id:'1', title:'تحذير من الصقيع', description:'مئوية الليلة في 0° ستنخفض درجة الحرارة إلى ما دون الساتين. يرجى تفعيل حماية الصقيع فوراً - القطاع 3.', type:'حرجة', time:'منذ دقيقتين', field:'القطاع 3: بساتين'),
    AlertModel(id:'2', title:'انخفاض السماد', description:'سعة الخزان عند 10% في القطاع 4. يلزم إعادة التعبئة للحفاظ على جدول التوزيع.', type:'حرجة', time:'منذ 12 دقيقة', field:'القطاع 4'),
    AlertModel(id:'3', title:'عطل في الري', description:'توقفت المضخة رقم 2 بشكل غير متوقع. معدل التدفق 0 لتر/دقيقة. افحص مصدر الطاقة.', type:'حرجة', time:'منذ 15 دقيقة', field:'المنطقة ج'),
    AlertModel(id:'4', title:'تنبيه انخفاض الرطوبة', description:'رطوبة التربة عند 15% في القطاع 4. الري الفوري لمحاصيل الذرة مطلوب.', type:'تحذير', time:'منذ ساعة', field:'القطاع 4'),
  ];

  static const List<ActivityModel> activities = [
    ActivityModel(id:'1', title:'الري المجدول', subtitle:'الحقل الشمالي • المنطقة أ', time:'10:00 AM', category:'ري', status:'قيد التشغيل'),
    ActivityModel(id:'2', title:'تم وضع السماد', subtitle:'البيت الزجاجي 2 • الطماطم', time:'08:30 AM', category:'سماد', status:'مكتمل'),
    ActivityModel(id:'3', title:'تنبيه انخفاض الرطوبة', subtitle:'المنطقة ج • مستشعر #142', time:'07:15 AM', category:'تنبيه', status:'مطلوب اتخاذ إجراء'),
    ActivityModel(id:'4', title:'فحص صحي يدوي', subtitle:'البستان الجنوبي', time:'04:45 PM', category:'فحص', status:'مكتمل'),
    ActivityModel(id:'5', title:'مسح جوي', subtitle:'كامل المزرعة', time:'01:20 PM', category:'فحص', status:'مكتمل'),
  ];
}
