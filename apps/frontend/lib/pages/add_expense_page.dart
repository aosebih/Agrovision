import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  String _type = 'expense';
  String _category = 'seeds';
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _loading = false;
  String? _error;
  String _lang = 'ar';

  static const _expenseCategories = [
    'seeds', 'fertilizer', 'pesticide', 'labor',
    'equipment', 'fuel', 'irrigation', 'transport', 'other',
  ];
  static const _incomeCategories = [
    'harvest', 'subsidy', 'livestock', 'other',
  ];

  List<String> get _categories =>
      _type == 'income' ? _incomeCategories : _expenseCategories;

  String _catLabel(String cat) {
    switch (cat) {
      case 'seeds': return _t(_lang, 'بذور', 'Semences');
      case 'fertilizer': return _t(_lang, 'أسمدة', 'Engrais');
      case 'pesticide': return _t(_lang, 'مبيدات', 'Pesticides');
      case 'labor': return _t(_lang, 'عمالة', 'Main-d\'œuvre');
      case 'equipment': return _t(_lang, 'معدات', 'Équipement');
      case 'fuel': return _t(_lang, 'وقود', 'Carburant');
      case 'irrigation': return _t(_lang, 'ري', 'Irrigation');
      case 'transport': return _t(_lang, 'نقل', 'Transport');
      case 'harvest': return _t(_lang, 'حصاد', 'Récolte');
      case 'subsidy': return _t(_lang, 'دعم حكومي', 'Subvention');
      case 'livestock': return _t(_lang, 'ثروة حيوانية', 'Élevage');
      default: return _t(_lang, 'أخرى', 'Autre');
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'seeds': return Icons.grass_rounded;
      case 'fertilizer': return Icons.science_rounded;
      case 'pesticide': return Icons.bug_report_rounded;
      case 'labor': return Icons.people_rounded;
      case 'equipment': return Icons.construction_rounded;
      case 'fuel': return Icons.local_gas_station_rounded;
      case 'irrigation': return Icons.water_drop_rounded;
      case 'transport': return Icons.local_shipping_rounded;
      case 'harvest': return Icons.agriculture_rounded;
      case 'subsidy': return Icons.account_balance_rounded;
      case 'livestock': return Icons.pets_rounded;
      default: return Icons.category_rounded;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _submit() async {
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = _t(_lang, 'أدخل مبلغاً صحيحاً', 'Entrez un montant valide'));
      return;
    }
    setState(() { _loading = true; _error = null; });
    final ok = await context.read<ExpenseProvider>().add({
      'type': _type,
      'category': _category,
      'amount': amount,
      'currency': 'DZD',
      'note': _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      'date': _date.toIso8601String(),
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t(_lang, 'تمت الإضافة بنجاح', 'Ajouté avec succès'))));
      Navigator.pop(context);
    } else {
      setState(() => _error =
          context.read<ExpenseProvider>().errorMessage ??
              _t(_lang, 'حدث خطأ', 'Erreur'));
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    return Directionality(
      textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppColors.surf(context),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: AppColors.bord(context))),
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            size: 18, color: AppColors.txtSec(context)),
                      ),
                    ),
                    Text(
                        _t(_lang, 'إضافة معاملة', 'Nouvelle transaction'),
                        style: AppTextStyles.titleLarge),
                  ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  const SizedBox(height: 8),

                  // Type toggle
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bord(context))),
                    child: Row(children: [
                      Expanded(
                          child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 'income';
                          _category = 'harvest';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                              color: _type == 'income'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(13)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_upward_rounded,
                                    size: 16,
                                    color: _type == 'income'
                                        ? Colors.white
                                        : AppColors.txtSec(context)),
                                const SizedBox(width: 6),
                                Text(
                                    _t(_lang, 'دخل', 'Revenu'),
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: _type == 'income'
                                            ? Colors.white
                                            : AppColors.txtSec(context),
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ),
                      )),
                      Expanded(
                          child: GestureDetector(
                        onTap: () => setState(() {
                          _type = 'expense';
                          _category = 'seeds';
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                              color: _type == 'expense'
                                  ? AppColors.error
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(13)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_downward_rounded,
                                    size: 16,
                                    color: _type == 'expense'
                                        ? Colors.white
                                        : AppColors.txtSec(context)),
                                const SizedBox(width: 6),
                                Text(
                                    _t(_lang, 'مصروف', 'Dépense'),
                                    style: AppTextStyles.bodySmall.copyWith(
                                        color: _type == 'expense'
                                            ? Colors.white
                                            : AppColors.txtSec(context),
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ),
                      )),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // Amount
                  Text(_t(_lang, 'المبلغ (دج)', 'Montant (DZD)'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bord(context))),
                    child: TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLarge.copyWith(
                          color: _type == 'income'
                              ? AppColors.primary
                              : AppColors.error,
                          fontSize: 32),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.txtMuted(context), fontSize: 32),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Category
                  Text(_t(_lang, 'الفئة', 'Catégorie'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((cat) {
                      final sel = cat == _category;
                      final color = _type == 'income'
                          ? AppColors.primary
                          : AppColors.error;
                      return GestureDetector(
                        onTap: () => setState(() => _category = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? color.withOpacity(0.1)
                                : AppColors.surf(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: sel
                                    ? color
                                    : AppColors.bord(context),
                                width: sel ? 1.5 : 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_catIcon(cat),
                                size: 16,
                                color: sel
                                    ? color
                                    : AppColors.txtSec(context)),
                            const SizedBox(width: 6),
                            Text(_catLabel(cat),
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: sel
                                        ? color
                                        : AppColors.txtSec(context),
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Date
                  Text(_t(_lang, 'التاريخ', 'Date'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppColors.surf(context),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: AppColors.bord(context))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.txtSec(context)),
                            Text(_formatDate(_date),
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.txt(context))),
                          ]),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Note
                  Text(_t(_lang, 'ملاحظة (اختياري)', 'Note (optionnel)'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bord(context))),
                    child: TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _t(_lang, 'أضف ملاحظة...', 'Ajouter une note...'),
                        hintStyle: AppTextStyles.bodySmall,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.error)),
                  ],

                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _loading ? null : _submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _type == 'income'
                              ? AppColors.primary
                              : AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text(
                                  _t(_lang, '✓  حفظ المعاملة',
                                      '✓  Enregistrer'),
                                  style: AppTextStyles.buttonText),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
