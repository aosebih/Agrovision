import 'package:flutter/material.dart';

class CropArabic {
  static const Map<String, String> names = {
    'rice': 'أرز', 'maize': 'ذرة', 'chickpea': 'حمص', 'kidneybeans': 'فاصوليا',
    'pigeonpeas': 'بازلاء', 'mothbeans': 'فول', 'mungbean': 'ماش',
    'blackgram': 'جرام أسود', 'lentil': 'عدس', 'pomegranate': 'رمان',
    'banana': 'موز', 'mango': 'مانجو', 'grapes': 'عنب', 'watermelon': 'بطيخ',
    'muskmelon': 'شمام', 'apple': 'تفاح', 'orange': 'برتقال', 'papaya': 'باباي',
    'coconut': 'جوز هند', 'cotton': 'قطن', 'jute': 'جوت', 'coffee': 'قهوة',
  };

  static const Map<String, IconData> icons = {
    'rice': Icons.grass, 'maize': Icons.grass, 'chickpea': Icons.circle,
    'kidneybeans': Icons.grain, 'pigeonpeas': Icons.eco, 'mothbeans': Icons.grain,
    'mungbean': Icons.eco, 'blackgram': Icons.grain, 'lentil': Icons.grain,
    'pomegranate': Icons.circle, 'banana': Icons.spa, 'mango': Icons.spa,
    'grapes': Icons.wine_bar, 'watermelon': Icons.circle, 'muskmelon': Icons.spa,
    'apple': Icons.apple, 'orange': Icons.circle, 'papaya': Icons.spa,
    'coconut': Icons.grain, 'cotton': Icons.filter_vintage, 'jute': Icons.grass,
    'coffee': Icons.coffee,
  };

  static const Map<String, Color> colors = {
    'rice': Color(0xFF7D9B6A), 'maize': Color(0xFFB8860B), 'chickpea': Color(0xFFC8860A),
    'kidneybeans': Color(0xFF8B2020), 'pigeonpeas': Color(0xFF5D8A3C),
    'mothbeans': Color(0xFF8B7355), 'mungbean': Color(0xFF2E7D32),
    'blackgram': Color(0xFF4A2C6E), 'lentil': Color(0xFFA0522D),
    'pomegranate': Color(0xFFC0392B), 'banana': Color(0xFFF1C40F),
    'mango': Color(0xFFE8A020), 'grapes': Color(0xFF8E44AD),
    'watermelon': Color(0xFFD32F2F), 'muskmelon': Color(0xFFE8A020),
    'apple': Color(0xFFE74C3C), 'orange': Color(0xFFF39C12),
    'papaya': Color(0xFFE67E22), 'coconut': Color(0xFF8B4513),
    'cotton': Color(0xFF3B6B47), 'jute': Color(0xFF6B5B35),
    'coffee': Color(0xFF6B3A2A),
  };

  static String name(String en) => names[en] ?? en;
  static IconData icon(String en) => icons[en] ?? Icons.eco;
  static Color color(String en) => colors[en] ?? const Color(0xFF4CAF50);
}
