import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

// ── Model registry ────────────────────────────────────────────────────────────

/// One entry per crop model shipped in assets/models/
class CropModelConfig {
  final String cropKey;       // matches pubspec asset path segment
  final String assetPath;     // e.g. 'assets/models/Tomato.tflite'
  final List<String> classes; // must match the order the model was trained on
  final String cropNameAr;
  final String cropNameFr;

  const CropModelConfig({
    required this.cropKey,
    required this.assetPath,
    required this.classes,
    required this.cropNameAr,
    required this.cropNameFr,
  });
}

const _inputSize = 224;

/// All available models – classes follow PlantVillage alphabetical order.
const List<CropModelConfig> cropModels = [
  CropModelConfig(
    cropKey: 'bean',
    assetPath: 'assets/models/bean_dynamic.tflite',
    classes: ['angular_leaf_spot', 'bean_rust', 'healthy'],
    cropNameAr: 'الفاصولياء',
    cropNameFr: 'Haricot',
  ),
  CropModelConfig(
    cropKey: 'apple',
    assetPath: 'assets/models/Apple.tflite',
    classes: ['Apple___Apple_scab', 'Apple___Black_rot', 'Apple___Cedar_apple_rust', 'Apple___healthy'],
    cropNameAr: 'التفاح',
    cropNameFr: 'Pomme',
  ),
  CropModelConfig(
    cropKey: 'cherry',
    assetPath: 'assets/models/Cherry_(including_sour).tflite',
    classes: ['Cherry___Powdery_mildew', 'Cherry___healthy'],
    cropNameAr: 'الكرز',
    cropNameFr: 'Cerise',
  ),
  CropModelConfig(
    cropKey: 'corn',
    assetPath: 'assets/models/Corn_(maize).tflite',
    classes: [
      'Corn___Cercospora_leaf_spot_Gray_leaf_spot',
      'Corn___Common_rust',
      'Corn___Northern_Leaf_Blight',
      'Corn___healthy',
    ],
    cropNameAr: 'الذرة',
    cropNameFr: 'Maïs',
  ),
  CropModelConfig(
    cropKey: 'grape',
    assetPath: 'assets/models/Grape.tflite',
    classes: [
      'Grape___Black_rot',
      'Grape___Esca_(Black_Measles)',
      'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)',
      'Grape___healthy',
    ],
    cropNameAr: 'العنب',
    cropNameFr: 'Raisin',
  ),
  CropModelConfig(
    cropKey: 'lentil',
    assetPath: 'assets/models/lentil_chikpea.tflite',
    classes: ['Ascochyta_blight', 'healthy', 'rust'],
    cropNameAr: 'العدس والحمص',
    cropNameFr: 'Lentille/Pois chiche',
  ),
  CropModelConfig(
    cropKey: 'peach',
    assetPath: 'assets/models/Peach.tflite',
    classes: ['Peach___Bacterial_spot', 'Peach___healthy'],
    cropNameAr: 'الخوخ',
    cropNameFr: 'Pêche',
  ),
  CropModelConfig(
    cropKey: 'pepper',
    assetPath: 'assets/models/Pepper,_bell.tflite',
    classes: ['Pepper___Bacterial_spot', 'Pepper___healthy'],
    cropNameAr: 'الفلفل',
    cropNameFr: 'Poivron',
  ),
  CropModelConfig(
    cropKey: 'potato',
    assetPath: 'assets/models/Potato.tflite',
    classes: ['Potato___Early_blight', 'Potato___Late_blight', 'Potato___healthy'],
    cropNameAr: 'البطاطا',
    cropNameFr: 'Pomme de terre',
  ),
  CropModelConfig(
    cropKey: 'strawberry',
    assetPath: 'assets/models/Strawberry.tflite',
    classes: ['Strawberry___Leaf_scorch', 'Strawberry___healthy'],
    cropNameAr: 'الفراولة',
    cropNameFr: 'Fraise',
  ),
  CropModelConfig(
    cropKey: 'tomato',
    assetPath: 'assets/models/Tomato.tflite',
    classes: [
      'Tomato___Bacterial_spot',
      'Tomato___Early_blight',
      'Tomato___Late_blight',
      'Tomato___Leaf_Mold',
      'Tomato___Septoria_leaf_spot',
      'Tomato___Spider_mites_Two-spotted_spider_mite',
      'Tomato___Target_Spot',
      'Tomato___Tomato_Yellow_Leaf_Curl_Virus',
      'Tomato___Tomato_mosaic_virus',
      'Tomato___healthy',
    ],
    cropNameAr: 'الطماطم',
    cropNameFr: 'Tomate',
  ),
];

// ── Disease info database ──────────────────────────────────────────────────────

class DiseaseInfo {
  final bool isHealthy;
  final String severity;       // 'none' | 'low' | 'moderate' | 'severe'
  final String descriptionAr;
  final String descriptionFr;
  final String treatmentAr;
  final String treatmentFr;

  const DiseaseInfo({
    required this.isHealthy,
    required this.severity,
    required this.descriptionAr,
    required this.descriptionFr,
    required this.treatmentAr,
    required this.treatmentFr,
  });
}

const Map<String, DiseaseInfo> _diseaseDb = {
  // ── Healthy (all crops) ──
  'healthy': DiseaseInfo(
    isHealthy: true, severity: 'none',
    descriptionAr: 'النبات يبدو سليماً، لا علامات على أمراض.',
    descriptionFr: 'La plante semble saine, aucun signe de maladie.',
    treatmentAr: 'لا علاج مطلوب. واصل برنامج الرعاية الحالي.',
    treatmentFr: 'Aucun traitement requis. Continuez le programme d\'entretien.',
  ),

  // ── Bean ──
  'angular_leaf_spot': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'تبقع الأوراق الزاوي تسببه فطريات Pseudocercospora griseola. تظهر بقع مائية الشكل محدودة بالأوردة.',
    descriptionFr: 'La tache angulaire est causée par Pseudocercospora griseola. Lésions wateuses délimitées par les nervures.',
    treatmentAr: 'رش Mancozeb (2 غ/ل) كل 10–14 يوماً. أزل الأوراق المصابة.',
    treatmentFr: 'Pulvériser Mancozeb (2 g/L) toutes les 10–14 jours. Enlever les feuilles infectées.',
  ),
  'bean_rust': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'صدأ الفاصولياء تسببه فطريات Uromyces appendiculatus. بثور صدئة على الأسطح السفلى للأوراق.',
    descriptionFr: 'La rouille du haricot est causée par Uromyces appendiculatus. Pustules rouille sous les feuilles.',
    treatmentAr: 'طبق Mancozeb أو Chlorothalonil عند أول ظهور. كرر كل 7–14 يوماً.',
    treatmentFr: 'Appliquer Mancozeb ou Chlorothalonil dès les premiers signes. Répéter toutes les 7–14 jours.',
  ),

  // ── Apple ──
  'Apple___Apple_scab': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'الجرب ينتجه فطر Venturia inaequalis. بقع زيتونية داكنة على الأوراق والثمار.',
    descriptionFr: 'La tavelure est causée par Venturia inaequalis. Taches olive-foncées sur feuilles et fruits.',
    treatmentAr: 'رش مبيدات فطرية مثل Captan أو Mancozeb. ابدأ عند انبثاق البراعم.',
    treatmentFr: 'Appliquer Captan ou Mancozeb. Commencer à l\'éclosion des bourgeons.',
  ),
  'Apple___Black_rot': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'العفن الأسود تسببه فطريات Botryosphaeria obtusa. بقع بنية على الأوراق وتعفن الثمار.',
    descriptionFr: 'La pourriture noire est causée par Botryosphaeria obtusa. Taches brunes et pourriture des fruits.',
    treatmentAr: 'أزل الأجزاء المصابة. رش Captan أو Thiophanate-methyl.',
    treatmentFr: 'Enlever les parties infectées. Pulvériser Captan ou Thiophanate-methyl.',
  ),
  'Apple___Cedar_apple_rust': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'صدأ أرز التفاح تسببه فطريات Gymnosporangium juniperi-virginianae.',
    descriptionFr: 'La rouille du cèdre-pommier est causée par Gymnosporangium juniperi-virginianae.',
    treatmentAr: 'رش مبيدات فطرية مثل Myclobutanil عند تفتح الأزهار.',
    treatmentFr: 'Appliquer Myclobutanil à la floraison.',
  ),

  // ── Cherry ──
  'Cherry___Powdery_mildew': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'البياض الدقيقي يغطي الأوراق بطبقة بيضاء مسحوقية.',
    descriptionFr: 'L\'oïdium recouvre les feuilles d\'un duvet blanc poudreux.',
    treatmentAr: 'رش Sulfur أو Potassium bicarbonate. تحسين التهوية.',
    treatmentFr: 'Pulvériser soufre ou bicarbonate de potassium. Améliorer la ventilation.',
  ),

  // ── Corn ──
  'Corn___Cercospora_leaf_spot_Gray_leaf_spot': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'تبقع الأوراق الرمادي تسببه فطريات Cercospora zeae-maydis. خطوط رمادية طولانية.',
    descriptionFr: 'La tache grise est causée par Cercospora zeae-maydis. Stries grises longitudinales.',
    treatmentAr: 'رش Azoxystrobin أو Pyraclostrobin. استخدم أصناف مقاومة.',
    treatmentFr: 'Pulvériser Azoxystrobin ou Pyraclostrobin. Utiliser des variétés résistantes.',
  ),
  'Corn___Common_rust': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'الصدأ الشائع تسببه فطريات Puccinia sorghi. بثور برتقالية-بنية على الأوراق.',
    descriptionFr: 'La rouille commune est causée par Puccinia sorghi. Pustules orange-brunes.',
    treatmentAr: 'طبق مبيدات فطرية عند الإصابة المبكرة. اختر أصنافاً مقاومة.',
    treatmentFr: 'Appliquer des fongicides en début d\'infection. Choisir des variétés résistantes.',
  ),
  'Corn___Northern_Leaf_Blight': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'اللفحة الشمالية للأوراق تسببها Exserohilum turcicum. بقع رمادية-خضراء كبيرة.',
    descriptionFr: 'Le brûlure nordique est causée par Exserohilum turcicum. Grandes taches gris-vert.',
    treatmentAr: 'رش Propiconazole أو Azoxystrobin عند ظهور أولى العلامات.',
    treatmentFr: 'Pulvériser Propiconazole ou Azoxystrobin dès les premiers signes.',
  ),

  // ── Grape ──
  'Grape___Black_rot': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'العفن الأسود للعنب تسببه فطريات Guignardia bidwellii. بقع بنية على الأوراق وتحول الثمار لمومياء.',
    descriptionFr: 'Le black rot est causé par Guignardia bidwellii. Taches brunes, fruits momifiés.',
    treatmentAr: 'رش Captan أو Mancozeb. أزل الثمار المصابة.',
    treatmentFr: 'Pulvériser Captan ou Mancozeb. Enlever les fruits infectés.',
  ),
  'Grape___Esca_(Black_Measles)': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'مرض الإسكا (الحصبة السوداء) مرض فطري خشبي يؤثر على الأوعية.',
    descriptionFr: 'L\'esca (black measles) est une maladie fongique du bois vasculaire.',
    treatmentAr: 'أزل الأجزاء المصابة. لا علاج كيميائي فعال حالياً.',
    treatmentFr: 'Enlever les parties infectées. Pas de traitement chimique efficace.',
  ),
  'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'لفحة الأوراق تسببها Pseudocercospora vitis. بقع بنية-حمراء على الأوراق.',
    descriptionFr: 'Le brûlure foliaire est causé par Pseudocercospora vitis. Taches brun-rouge.',
    treatmentAr: 'رش Mancozeb. حافظ على تهوية الكرمة.',
    treatmentFr: 'Pulvériser Mancozeb. Maintenir une bonne aération de la vigne.',
  ),

  // ── Lentil / Chickpea ──
  'Ascochyta_blight': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'لفحة الأسكوكيتا تسببها فطريات Ascochyta rabiei. تدمر الأوراق والسيقان والثمار.',
    descriptionFr: 'L\'anthracnose à Ascochyta est causée par Ascochyta rabiei. Détruit feuilles, tiges et gousses.',
    treatmentAr: 'استخدم بذوراً معالجة. رش Chlorothalonil أو Mancozeb.',
    treatmentFr: 'Utiliser des semences traitées. Pulvériser Chlorothalonil ou Mancozeb.',
  ),
  'rust': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'صدأ البقوليات يؤثر على العدس والحمص بظهور بثور بنية-برتقالية.',
    descriptionFr: 'La rouille des légumineuses affecte lentilles et pois chiches.',
    treatmentAr: 'رش مبيدات فطرية عند الإصابة المبكرة.',
    treatmentFr: 'Appliquer des fongicides en début d\'infection.',
  ),

  // ── Peach ──
  'Peach___Bacterial_spot': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'التبقع البكتيري يسببه Xanthomonas arboricola. بقع مائية تصبح مثقبة.',
    descriptionFr: 'La tache bactérienne est causée par Xanthomonas arboricola. Lésions qui se perforent.',
    treatmentAr: 'رش مركبات النحاس. استخدم أصنافاً مقاومة.',
    treatmentFr: 'Pulvériser des composés cuivriques. Utiliser des variétés résistantes.',
  ),

  // ── Pepper ──
  'Pepper___Bacterial_spot': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'التبقع البكتيري للفلفل يسببه Xanthomonas campestris. بقع مائية داكنة.',
    descriptionFr: 'La tache bactérienne du poivron est causée par Xanthomonas campestris.',
    treatmentAr: 'رش مركبات النحاس. تجنب الري الرشاشي.',
    treatmentFr: 'Pulvériser des composés cuivriques. Éviter l\'irrigation par aspersion.',
  ),

  // ── Potato ──
  'Potato___Early_blight': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'اللفحة المبكرة تسببها فطريات Alternaria solani. حلقات متحدة المركز على الأوراق.',
    descriptionFr: 'L\'alternariose est causée par Alternaria solani. Anneaux concentriques sur feuilles.',
    treatmentAr: 'رش Mancozeb أو Chlorothalonil. أزل الأوراق المصابة.',
    treatmentFr: 'Pulvériser Mancozeb ou Chlorothalonil. Enlever les feuilles infectées.',
  ),
  'Potato___Late_blight': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'اللفحة المتأخرة تسببها Phytophthora infestans. تدمر المحصول بسرعة في الطقس الرطب.',
    descriptionFr: 'Le mildiou est causé par Phytophthora infestans. Détruit la récolte rapidement.',
    treatmentAr: 'رش Metalaxyl + Mancozeb عند ظهور أولى الأعراض. مراقبة دورية.',
    treatmentFr: 'Pulvériser Metalaxyl + Mancozeb dès les premiers symptômes.',
  ),

  // ── Strawberry ──
  'Strawberry___Leaf_scorch': DiseaseInfo(
    isHealthy: false, severity: 'low',
    descriptionAr: 'احتراق أوراق الفراولة تسببه فطريات Diplocarpon earlianum. بقع أرجوانية صغيرة.',
    descriptionFr: 'La brûlure foliaire du fraisier est causée par Diplocarpon earlianum.',
    treatmentAr: 'رش Captan أو Thiram. أزل الأوراق القديمة المصابة.',
    treatmentFr: 'Pulvériser Captan ou Thiram. Enlever les vieilles feuilles infectées.',
  ),

  // ── Tomato ──
  'Tomato___Bacterial_spot': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'التبقع البكتيري يسببه Xanthomonas campestris. بقع مائية صغيرة تصبح بنية.',
    descriptionFr: 'La tache bactérienne est causée par Xanthomonas campestris.',
    treatmentAr: 'رش مركبات النحاس. تجنب الري الرشاشي.',
    treatmentFr: 'Pulvériser des composés cuivriques. Éviter l\'arrosage par aspersion.',
  ),
  'Tomato___Early_blight': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'اللفحة المبكرة تسببها Alternaria solani. حلقات متحدة المركز داكنة.',
    descriptionFr: 'L\'alternariose est causée par Alternaria solani. Anneaux concentriques sombres.',
    treatmentAr: 'رش Chlorothalonil أو Mancozeb. أزل الأوراق السفلى المصابة.',
    treatmentFr: 'Pulvériser Chlorothalonil ou Mancozeb. Enlever les feuilles basses infectées.',
  ),
  'Tomato___Late_blight': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'اللفحة المتأخرة تسببها Phytophthora infestans. بقع خضراء-رمادية مائية.',
    descriptionFr: 'Le mildiou est causé par Phytophthora infestans. Taches vert-grisâtres wateuses.',
    treatmentAr: 'رش Metalaxyl فوراً. أزل النباتات المصابة بشدة.',
    treatmentFr: 'Pulvériser Metalaxyl immédiatement. Enlever les plants très infectés.',
  ),
  'Tomato___Leaf_Mold': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'عفن الأوراق تسببه Passalora fulva. طبقة خضراء-رمادية على الأسطح السفلى.',
    descriptionFr: 'La moisissure foliaire est causée par Passalora fulva. Couche vert-grisâtre.',
    treatmentAr: 'حسّن التهوية. رش Chlorothalonil.',
    treatmentFr: 'Améliorer la ventilation. Pulvériser Chlorothalonil.',
  ),
  'Tomato___Septoria_leaf_spot': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'تبقع سبتوريا تسببه Septoria lycopersici. بقع صغيرة دائرية بيضاء المركز.',
    descriptionFr: 'La septoriose est causée par Septoria lycopersici. Petites taches circulaires à centre blanc.',
    treatmentAr: 'رش Mancozeb أو Chlorothalonil. أزل الأوراق المصابة.',
    treatmentFr: 'Pulvériser Mancozeb ou Chlorothalonil. Enlever les feuilles infectées.',
  ),
  'Tomato___Spider_mites_Two-spotted_spider_mite': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'العناكب ذات النقطتين تسبب اصفرار وتشبيك الأوراق في الطقس الجاف.',
    descriptionFr: 'Les acariens à deux points causent jaunissement et toiles par temps sec.',
    treatmentAr: 'رش Abamectin أو Spiromesifen. الري الجيد يقلل الإصابة.',
    treatmentFr: 'Pulvériser Abamectin ou Spiromesifen. Un bon arrosage réduit l\'infestation.',
  ),
  'Tomato___Target_Spot': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'تبقع الهدف تسببه Corynespora cassiicola. بقع بنية بحلقات متحدة المركز.',
    descriptionFr: 'La tache cible est causée par Corynespora cassiicola. Taches brunes concentriques.',
    treatmentAr: 'رش Azoxystrobin أو Chlorothalonil.',
    treatmentFr: 'Pulvériser Azoxystrobin ou Chlorothalonil.',
  ),
  'Tomato___Tomato_Yellow_Leaf_Curl_Virus': DiseaseInfo(
    isHealthy: false, severity: 'severe',
    descriptionAr: 'فيروس تجعد أوراق الطماطم الأصفر ينتقل بواسطة الذبابة البيضاء.',
    descriptionFr: 'Le virus du rabougrissement du tomato jaune se propage par les aleurodes.',
    treatmentAr: 'اقتلع النباتات المصابة. استخدم شباكاً لمكافحة الذبابة البيضاء.',
    treatmentFr: 'Arracher les plants infectés. Utiliser des filets anti-aleurodes.',
  ),
  'Tomato___Tomato_mosaic_virus': DiseaseInfo(
    isHealthy: false, severity: 'moderate',
    descriptionAr: 'فيروس فسيفساء الطماطم يسبب تلوناً غير منتظم وتشوه الأوراق.',
    descriptionFr: 'Le virus de la mosaïque cause une coloration irrégulière et des déformations.',
    treatmentAr: 'لا علاج. أزل النباتات المصابة. طهّر الأدوات.',
    treatmentFr: 'Pas de traitement. Enlever les plants infectés. Désinfecter les outils.',
  ),
};

// ── Human-readable display names ──────────────────────────────────────────────

const Map<String, Map<String, String>> _classDisplayNames = {
  'angular_leaf_spot':       {'ar': 'تبقع الأوراق الزاوي',       'fr': 'Tache angulaire'},
  'bean_rust':               {'ar': 'صدأ الفاصولياء',             'fr': 'Rouille du haricot'},
  'Apple___Apple_scab':      {'ar': 'جرب التفاح',                 'fr': 'Tavelure du pommier'},
  'Apple___Black_rot':       {'ar': 'العفن الأسود للتفاح',        'fr': 'Pourriture noire'},
  'Apple___Cedar_apple_rust':{'ar': 'صدأ أرز التفاح',             'fr': 'Rouille cèdre-pommier'},
  'Cherry___Powdery_mildew': {'ar': 'البياض الدقيقي للكرز',       'fr': 'Oïdium du cerisier'},
  'Corn___Cercospora_leaf_spot_Gray_leaf_spot': {'ar': 'تبقع الأوراق الرمادي', 'fr': 'Tache grise du maïs'},
  'Corn___Common_rust':      {'ar': 'الصدأ الشائع للذرة',         'fr': 'Rouille commune du maïs'},
  'Corn___Northern_Leaf_Blight': {'ar': 'اللفحة الشمالية للذرة', 'fr': 'Brûlure nordique du maïs'},
  'Grape___Black_rot':       {'ar': 'العفن الأسود للعنب',         'fr': 'Black rot de la vigne'},
  'Grape___Esca_(Black_Measles)': {'ar': 'الإسكا (الحصبة السوداء)', 'fr': 'Esca (black measles)'},
  'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': {'ar': 'لفحة أوراق العنب', 'fr': 'Brûlure foliaire de la vigne'},
  'Ascochyta_blight':        {'ar': 'لفحة الأسكوكيتا',            'fr': 'Anthracnose à Ascochyta'},
  'rust':                    {'ar': 'الصدأ',                      'fr': 'Rouille'},
  'Peach___Bacterial_spot':  {'ar': 'التبقع البكتيري للخوخ',      'fr': 'Tache bactérienne du pêcher'},
  'Pepper___Bacterial_spot': {'ar': 'التبقع البكتيري للفلفل',     'fr': 'Tache bactérienne du poivron'},
  'Potato___Early_blight':   {'ar': 'اللفحة المبكرة للبطاطا',     'fr': 'Alternariose de la pomme de terre'},
  'Potato___Late_blight':    {'ar': 'اللفحة المتأخرة للبطاطا',    'fr': 'Mildiou de la pomme de terre'},
  'Strawberry___Leaf_scorch':{'ar': 'احتراق أوراق الفراولة',      'fr': 'Brûlure foliaire du fraisier'},
  'Tomato___Bacterial_spot': {'ar': 'التبقع البكتيري للطماطم',    'fr': 'Tache bactérienne de la tomate'},
  'Tomato___Early_blight':   {'ar': 'اللفحة المبكرة للطماطم',     'fr': 'Alternariose de la tomate'},
  'Tomato___Late_blight':    {'ar': 'اللفحة المتأخرة للطماطم',    'fr': 'Mildiou de la tomate'},
  'Tomato___Leaf_Mold':      {'ar': 'عفن أوراق الطماطم',          'fr': 'Moisissure foliaire de la tomate'},
  'Tomato___Septoria_leaf_spot': {'ar': 'تبقع سبتوريا',           'fr': 'Septoriose de la tomate'},
  'Tomato___Spider_mites_Two-spotted_spider_mite': {'ar': 'عناكب الطماطم', 'fr': 'Acariens à deux points'},
  'Tomato___Target_Spot':    {'ar': 'تبقع الهدف',                 'fr': 'Tache cible de la tomate'},
  'Tomato___Tomato_Yellow_Leaf_Curl_Virus': {'ar': 'فيروس تجعد الأوراق الأصفر', 'fr': 'TYLCV'},
  'Tomato___Tomato_mosaic_virus': {'ar': 'فيروس فسيفساء الطماطم', 'fr': 'Virus de la mosaïque'},
  'healthy':                 {'ar': 'سليم',                       'fr': 'Sain'},
};

String _displayName(String classKey, String lang) {
  final names = _classDisplayNames[classKey];
  if (names == null) return classKey.replaceAll('___', ' ').replaceAll('_', ' ');
  return names[lang] ?? names['ar']!;
}

// ── Service ───────────────────────────────────────────────────────────────────

class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  /// Currently loaded interpreter and its config
  Interpreter? _interpreter;
  CropModelConfig? _loadedConfig;

  bool get isLoaded => _interpreter != null && _loadedConfig != null;
  String? get loadedCropKey => _loadedConfig?.cropKey;

  /// Returns all available crop models (for the UI picker)
  static List<CropModelConfig> get availableModels => cropModels;

  // ── Scaler values for the crop recommendation model ──────────────────────
  // Must match the feature_scaler.pkl used during Python training.
  // Inputs: [temperature, humidity, pH, rainfall]
  static const List<double> _recMeans = [26.5, 75.2, 6.5, 185.4];
  static const List<double> _recStds  = [5.2,  18.3, 0.8, 45.6];

  /// Loads the model for [cropKey], swapping out the previous one if needed.
  Future<void> loadModel(String cropKey) async {
    final config = cropModels.firstWhere(
      (m) => m.cropKey == cropKey,
      orElse: () => cropModels.first,
    );

    // Already loaded
    if (_loadedConfig?.cropKey == cropKey && _interpreter != null) return;

    // Dispose previous
    _interpreter?.close();
    _interpreter = null;
    _loadedConfig = null;

    try {
      _interpreter = await Interpreter.fromAsset(
        config.assetPath,
        options: InterpreterOptions()..threads = 2,
      );
      _loadedConfig = config;
      debugPrint('TFLite loaded: ${config.cropKey}');
    } on Exception catch (e) {
      final msg = e.toString();
      if (msg.contains('Unable to open') ||
          msg.contains('not found') ||
          msg.contains('FileNotFoundException') ||
          msg.contains('asset')) {
        debugPrint('Model asset not found for ${config.cropKey}: $e');
        throw Exception(
          'Model file not found: ${config.assetPath}\n'
          'Make sure it is declared in pubspec.yaml under flutter > assets.',
        );
      }
      debugPrint('Failed to load model ${config.cropKey}: $e');
      rethrow;
    }
  }

  /// Run inference on [imageFile] for the already-loaded crop model.
  /// Used by all image-based disease detection models.
  Future<Map<String, dynamic>> predict(File imageFile, String lang) async {
    if (!isLoaded || _interpreter == null || _loadedConfig == null) {
      throw StateError('No model loaded. Call loadModel(cropKey) first.');
    }

    final config = _loadedConfig!;
    final classes = config.classes;

    // Pre-process
    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Could not decode image');
    final resized = img.copyResize(decoded,
        width: _inputSize, height: _inputSize, interpolation: img.Interpolation.linear);

    final input = List.generate(1, (_) =>
      List.generate(_inputSize, (y) =>
        List.generate(_inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        })));

    final output = List.generate(1, (_) => List.filled(classes.length, 0.0));
    _interpreter!.run(input, output);

    final scores = output[0];
    int bestIdx = 0;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > scores[bestIdx]) bestIdx = i;
    }

    final bestClass = classes[bestIdx];
    final probabilities = <String, double>{
      for (int i = 0; i < classes.length; i++) classes[i]: scores[i],
    };

    final info = _diseaseDb[bestClass] ?? _diseaseDb['healthy']!;

    return {
      'cropKey':       config.cropKey,
      'label':         bestClass,
      'displayNameAr': _displayName(bestClass, 'ar'),
      'displayNameFr': _displayName(bestClass, 'fr'),
      'displayName':   _displayName(bestClass, lang),
      'confidence':    scores[bestIdx],
      'probabilities': probabilities,
      'isHealthy':     info.isHealthy,
      'severity':      info.severity,
      'descriptionAr': info.descriptionAr,
      'descriptionFr': info.descriptionFr,
      'treatmentAr':   info.treatmentAr,
      'treatmentFr':   info.treatmentFr,
      'description':   lang == 'fr' ? info.descriptionFr : info.descriptionAr,
      'treatment':     lang == 'fr' ? info.treatmentFr   : info.treatmentAr,
    };
  }

  /// Run inference on tabular values for the crop recommendation model.
  /// Requires the 'crop_recommendation' model to be loaded first.
  /// Inputs: temperature (°C), humidity (%), pH, rainfall (mm).
  /// Returns the recommended crop name (English key, e.g. 'rice').
  String predictFromValues(double temp, double hum, double ph, double water) {
    if (_loadedConfig?.cropKey != 'crop_recommendation' || _interpreter == null) {
      throw StateError(
        'Crop recommendation model not loaded. '
        'Call loadModel(\'crop_recommendation\') first.',
      );
    }

    final classes = _loadedConfig!.classes;

    // Normalise using the same StandardScaler as Python training
    final input = [[
      (temp  - _recMeans[0]) / _recStds[0],
      (hum   - _recMeans[1]) / _recStds[1],
      (ph    - _recMeans[2]) / _recStds[2],
      (water - _recMeans[3]) / _recStds[3],
    ]];

    final output = List.generate(1, (_) => List.filled(classes.length, 0.0));
    _interpreter!.run(input, output);

    final scores = output[0];
    int best = 0;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > scores[best]) best = i;
    }

    return classes[best];
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _loadedConfig = null;
  }
}