library;

String _tModel(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class RemoteExpense {
  final String id;
  final String type; // 'income' | 'expense'
  final String category;
  final double amount;
  final String currency;
  final String? note;
  final String date;
  final String createdAt;

  const RemoteExpense({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.currency,
    this.note,
    required this.date,
    required this.createdAt,
  });

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory RemoteExpense.fromJson(Map<String, dynamic> j) => RemoteExpense(
        id: j['id'] as String,
        type: j['type'] as String? ?? 'expense',
        category: j['category'] as String? ?? 'other',
        amount: _toDouble(j['amount']),
        currency: j['currency'] as String? ?? 'DZD',
        note: j['note'] as String?,
        date: j['date'] as String? ?? j['createdAt'] as String? ?? '',
        createdAt: j['createdAt'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'category': category,
        'amount': amount,
        'currency': currency,
        if (note != null) 'note': note,
        'date': date,
      };

  String categoryLabel(String lang) {
    switch (category) {
      // expense categories
      case 'seeds': return _tModel(lang, 'بذور', 'Semences');
      case 'fertilizer': return _tModel(lang, 'أسمدة', 'Engrais');
      case 'pesticide': return _tModel(lang, 'مبيدات', 'Pesticides');
      case 'labor': return _tModel(lang, 'عمالة', 'Main-d\'œuvre');
      case 'equipment': return _tModel(lang, 'معدات', 'Équipement');
      case 'fuel': return _tModel(lang, 'وقود', 'Carburant');
      case 'irrigation': return _tModel(lang, 'ري', 'Irrigation');
      case 'transport': return _tModel(lang, 'نقل', 'Transport');
      // income categories
      case 'harvest': return _tModel(lang, 'حصاد', 'Récolte');
      case 'subsidy': return _tModel(lang, 'دعم حكومي', 'Subvention');
      case 'livestock': return _tModel(lang, 'ثروة حيوانية', 'Élevage');
      default: return _tModel(lang, 'أخرى', 'Autre');
    }
  }

  String get formattedDate {
    try {
      final d = DateTime.parse(date);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return date;
    }
  }
}

class ExpenseSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final String currency;
  final List<MonthlyStat> monthly;

  const ExpenseSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.currency,
    required this.monthly,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory ExpenseSummary.fromJson(Map<String, dynamic> j) => ExpenseSummary(
        totalIncome: _toDouble(j['totalIncome']),
        totalExpenses: _toDouble(j['totalExpenses']),
        balance: _toDouble(j['balance']),
        currency: j['currency'] as String? ?? 'DZD',
        monthly: (j['monthly'] as List<dynamic>? ?? [])
            .map((e) => MonthlyStat.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class MonthlyStat {
  final String month;
  final double income;
  final double expenses;

  const MonthlyStat({
    required this.month,
    required this.income,
    required this.expenses,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory MonthlyStat.fromJson(Map<String, dynamic> j) => MonthlyStat(
        month: j['month'] as String? ?? '',
        income: _toDouble(j['income']),
        expenses: _toDouble(j['expenses']),
      );
}
