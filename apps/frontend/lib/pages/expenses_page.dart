import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../models/remote/expense_model.dart';
import 'add_expense_page.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});
  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _selFilter = 0;
  String _lang = 'ar';
  bool _viewByYear = false; // false = month, true = year
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    // Always load all types — filtering is done locally so switching
    // between chips never wipes out the other category's data.
    context.read<ExpenseProvider>().load(
          month: _viewByYear ? null : _selectedMonth.month,
          year: _viewByYear ? _selectedYear : _selectedMonth.year,
        );
  }

  void _prev() {
    setState(() {
      if (_viewByYear) {
        _selectedYear--;
      } else {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      }
    });
    _reload();
  }

  void _next() {
    final now = DateTime.now();
    if (_viewByYear) {
      if (_selectedYear >= now.year) return;
      setState(() => _selectedYear++);
    } else {
      if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) return;
      setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1));
    }
    _reload();
  }

  bool get _isAtCurrent {
    final now = DateTime.now();
    if (_viewByYear) return _selectedYear >= now.year;
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  String _periodLabel() {
    if (_viewByYear) return '$_selectedYear';
    const arMonths = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    const frMonths = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
    final m = _selectedMonth.month - 1;
    return _lang == 'fr'
        ? '${frMonths[m]} ${_selectedMonth.year}'
        : '${arMonths[m]} ${_selectedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddExpensePage()));
          _reload();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) => SafeArea(
          child: Column(children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  _periodNav(),
                  if (provider.usingLocal) _localBadge(),
                  _summaryCard(provider),
                  _chart(provider),
                  _filterChips(),
                  _body(provider),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // Year / Month toggle
          GestureDetector(
            onTap: () { setState(() => _viewByYear = !_viewByYear); _reload(); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surf(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.bord(context)),
              ),
              child: Text(
                _viewByYear
                    ? _t(_lang, 'سنة', 'Année')
                    : _t(_lang, 'شهر', 'Mois'),
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Text(_t(_lang, 'المالية', 'Finances'), style: AppTextStyles.titleLarge),
        ]),
      );

  Widget _periodNav() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          // Left arrow = go back (prev)
          GestureDetector(
            onTap: _prev,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.surf(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.bord(context))),
              child: Icon(Icons.chevron_left_rounded,
                  size: 20, color: AppColors.txtSec(context)),
            ),
          ),
          Text(_periodLabel(),
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.txt(context))),
          // Right arrow = go forward (next)
          GestureDetector(
            onTap: _next,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: _isAtCurrent
                      ? AppColors.surfAlt(context)
                      : AppColors.surf(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.bord(context))),
              child: Icon(Icons.chevron_right_rounded,
                  size: 20,
                  color: _isAtCurrent
                      ? AppColors.txtMuted(context)
                      : AppColors.txtSec(context)),
            ),
          ),
        ]),
      );

  Widget _localBadge() => Container(
        margin: const EdgeInsets.fromLTRB(20, 4, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.orangeLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.orange.withOpacity(0.4)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.orange),
          const SizedBox(width: 6),
          Text(
              _t(_lang, 'محفوظ محلياً — سيُزامن عند توفر الخادم',
                  'Sauvegardé localement'),
              style: AppTextStyles.caption.copyWith(color: AppColors.orange)),
        ]),
      );

  Widget _summaryCard(ExpenseProvider provider) {
    // Always compute from the full unfiltered list so the summary card
    // always shows the true total even when a chip filter is active.
    final income = provider.totalIncome;
    final expenses = provider.totalExpenses;
    final balance = provider.balance;
    final isPositive = balance >= 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPositive
                ? [const Color(0xFF1B5E20), AppColors.primary]
                : [const Color(0xFF7F1D1D), AppColors.error],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${balance.abs().toStringAsFixed(0)} DZD',
                style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_t(_lang, 'الرصيد الصافي', 'Solde net'),
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text(
                isPositive ? _t(_lang, '▲ ربح', '▲ Bénéfice') : _t(_lang, '▼ خسارة', '▼ Perte'),
                style: TextStyle(
                    color: isPositive ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                    fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ]),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _miniStat(Icons.arrow_upward_rounded,
                _t(_lang, 'الدخل', 'Revenus'), income, const Color(0xFF86EFAC))),
            const SizedBox(width: 10),
            Expanded(child: _miniStat(Icons.arrow_downward_rounded,
                _t(_lang, 'المصاريف', 'Dépenses'), expenses, const Color(0xFFFCA5A5))),
          ]),
        ]),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, double value, Color color) =>
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text('${value.toStringAsFixed(0)} DZD',
                style: const TextStyle(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          ])),
        ]),
      );

  // Distinct palette for category slices
  static const List<Color> _categoryPalette = [
    Color(0xFF2E7D32), Color(0xFF1565C0), Color(0xFFE65100),
    Color(0xFF6A1B9A), Color(0xFF00838F), Color(0xFFC62828),
    Color(0xFF558B2F), Color(0xFF4527A0), Color(0xFFF9A825),
    Color(0xFF37474F),
  ];

  Widget _chart(ExpenseProvider provider) {
    final income = provider.totalIncome;
    final expenses = provider.totalExpenses;
    if (income == 0 && expenses == 0) return const SizedBox.shrink();

    // ── Category-breakdown mode (filter 1 = income, 2 = expense) ────────────
    if (_selFilter == 1 || _selFilter == 2) {
      final isIncome = _selFilter == 1;
      final relevant = provider.expenses.where((e) => e.isIncome == isIncome).toList();

      // Aggregate by category label
      final Map<String, double> byCategory = {};
      for (final e in relevant) {
        final label = e.categoryLabel(_lang);
        byCategory[label] = (byCategory[label] ?? 0) + e.amount;
      }
      if (byCategory.isEmpty) return const SizedBox.shrink();

      final total = byCategory.values.fold(0.0, (a, b) => a + b);
      final entries = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final slices = entries.asMap().entries.map((e) {
        final idx = e.key % _categoryPalette.length;
        return _PieSlice(
          label: e.value.key,
          value: e.value.value,
          color: _categoryPalette[idx],
        );
      }).toList();

      final title = isIncome
          ? _t(_lang, 'توزيع الدخل حسب الفئة', 'Revenus par catégorie')
          : _t(_lang, 'توزيع المصاريف حسب الفئة', 'Dépenses par catégorie');

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.bord(context)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title, style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              SizedBox(
                width: 140,
                height: 140,
                child: _MultiPieChart(slices: slices),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: slices.asMap().entries.map((entry) {
                    final i = entry.key;
                    final s = entry.value;
                    final pct = (s.value / total * 100).toStringAsFixed(1);
                    return Padding(
                      padding: EdgeInsets.only(bottom: i < slices.length - 1 ? 10 : 0),
                      child: _pieLegendRow(s.color, s.label, s.value, pct),
                    );
                  }).toList(),
                ),
              ),
            ]),
          ]),
        ),
      );
    }

    // ── Default: income vs expenses ──────────────────────────────────────────
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.bord(context)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(_t(_lang, 'الدخل مقابل المصاريف', 'Revenus vs Dépenses'),
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          Row(children: [
            SizedBox(
              width: 140,
              height: 140,
              child: _PieChart(
                income: income,
                expenses: expenses,
                incomeColor: AppColors.primary,
                expenseColor: AppColors.error,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pieLegendRow(
                    AppColors.primary,
                    _t(_lang, 'الدخل', 'Revenus'),
                    income,
                    income + expenses > 0
                        ? (income / (income + expenses) * 100).toStringAsFixed(1)
                        : '0',
                  ),
                  const SizedBox(height: 16),
                  _pieLegendRow(
                    AppColors.error,
                    _t(_lang, 'المصاريف', 'Dépenses'),
                    expenses,
                    income + expenses > 0
                        ? (expenses / (income + expenses) * 100).toStringAsFixed(1)
                        : '0',
                  ),
                ],
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _pieLegendRow(Color color, String label, double value, String pct) =>
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${value.toStringAsFixed(0)} DZD',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.txt(context), fontWeight: FontWeight.w700)),
            Text('$pct%', style: AppTextStyles.caption.copyWith(color: color)),
            Text(label,
                style: AppTextStyles.caption,
                overflow: TextOverflow.ellipsis,
                maxLines: 1),
          ]),
        ),
        const SizedBox(width: 10),
        Container(
            width: 12, height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ]);

  Widget _filterChips() {
    final filters = [
      _t(_lang, 'الكل', 'Tout'),
      _t(_lang, 'دخل', 'Revenus'),
      _t(_lang, 'مصاريف', 'Dépenses'),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filters.length,
          itemBuilder: (_, i) {
            final sel = i == _selFilter;
            return GestureDetector(
              onTap: () { setState(() => _selFilter = i); _reload(); },
              child: Container(
                margin: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.surf(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.bord(context)),
                ),
                child: Text(filters[i],
                    style: AppTextStyles.bodySmall.copyWith(
                        color: sel ? Colors.white : AppColors.txtSec(context))),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _body(ExpenseProvider provider) {
    if (provider.isLoading && provider.expenses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    // Apply chip filter locally — all data is always loaded from the API,
    // so switching chips never wipes out the other category's data.
    final filtered = provider.expenses.where((e) {
      if (_selFilter == 1) return e.isIncome;
      if (_selFilter == 2) return e.isExpense;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.receipt_long_outlined, size: 52, color: AppColors.txtMuted(context)),
          const SizedBox(height: 12),
          Text(_t(_lang, 'لا توجد معاملات', 'Aucune transaction'),
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
          const SizedBox(height: 6),
          Text(_t(_lang, 'اضغط + لإضافة معاملة', 'Appuyez sur + pour ajouter'),
              style: AppTextStyles.bodySmall),
        ]),
      );
    }

    // Group the locally-filtered list by date
    final grouped = <String, List<RemoteExpense>>{};
    for (final e in filtered) {
      grouped.putIfAbsent(e.formattedDate, () => []).add(e);
    }
    final dates = grouped.keys.toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: dates.length,
      itemBuilder: (_, i) {
        final date = dates[i];
        final items = grouped[date]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(date,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.txtMuted(context),
                      fontWeight: FontWeight.w600)),
            ),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExpenseCard(expense: e, provider: provider, lang: _lang),
                )),
          ],
        );
      },
    );
  }
}

// ── Pie chart — 2-slice (income vs expense) ──────────────────────────────────

class _PieChart extends StatelessWidget {
  final double income;
  final double expenses;
  final Color incomeColor;
  final Color expenseColor;

  const _PieChart({
    required this.income,
    required this.expenses,
    required this.incomeColor,
    required this.expenseColor,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PieChartPainter(
          income: income,
          expenses: expenses,
          incomeColor: incomeColor,
          expenseColor: expenseColor,
          bgColor: AppColors.surfAlt(context),
        ),
      );
}

class _PieChartPainter extends CustomPainter {
  final double income;
  final double expenses;
  final Color incomeColor;
  final Color expenseColor;
  final Color bgColor;

  _PieChartPainter({
    required this.income,
    required this.expenses,
    required this.incomeColor,
    required this.expenseColor,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = income + expenses;
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const gap = 0.03;

    final incomeAngle = (income / total) * 2 * math.pi - gap;
    final expenseAngle = (expenses / total) * 2 * math.pi - gap;

    canvas.drawArc(rect, -math.pi / 2 + gap / 2, incomeAngle, true,
        Paint()..color = incomeColor.withOpacity(0.85));
    canvas.drawArc(rect, -math.pi / 2 + gap / 2 + incomeAngle + gap,
        expenseAngle, true, Paint()..color = expenseColor.withOpacity(0.85));

    canvas.drawCircle(center, radius * 0.52, Paint()..color = bgColor);
  }

  @override
  bool shouldRepaint(_PieChartPainter old) =>
      old.income != income || old.expenses != expenses;
}

// ── Multi-slice pie chart (category breakdown) ────────────────────────────────

class _PieSlice {
  final String label;
  final double value;
  final Color color;
  const _PieSlice({required this.label, required this.value, required this.color});
}

class _MultiPieChart extends StatelessWidget {
  final List<_PieSlice> slices;
  const _MultiPieChart({required this.slices});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _MultiPiePainter(
          slices: slices,
          bgColor: AppColors.surfAlt(context),
        ),
      );
}

class _MultiPiePainter extends CustomPainter {
  final List<_PieSlice> slices;
  final Color bgColor;
  _MultiPiePainter({required this.slices, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold(0.0, (s, e) => s + e.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const gap = 0.025;

    double startAngle = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * 2 * math.pi - gap;
      canvas.drawArc(
        rect,
        startAngle + gap / 2,
        sweep,
        true,
        Paint()..color = slice.color.withOpacity(0.88),
      );
      startAngle += sweep + gap;
    }

    canvas.drawCircle(center, radius * 0.52, Paint()..color = bgColor);
  }

  @override
  bool shouldRepaint(_MultiPiePainter old) => old.slices != slices;
}

// ── Expense card ─────────────────────────────────────────────────────────────
class _ExpenseCard extends StatelessWidget {
  final RemoteExpense expense;
  final ExpenseProvider provider;
  final String lang;
  const _ExpenseCard({required this.expense, required this.provider, required this.lang});

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.isIncome;
    final color = isIncome ? AppColors.primary : AppColors.error;
    final bg = isIncome ? AppColors.primaryLight : const Color(0xFFFEF2F2);

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => provider.delete(expense.id),
      background: Container(
        decoration: BoxDecoration(
            color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bord(context)),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              '${isIncome ? '+' : '-'} ${expense.amount.toStringAsFixed(0)} ${expense.currency}',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: color, fontWeight: FontWeight.w800),
            ),
            if (expense.note != null && expense.note!.isNotEmpty)
              Text(expense.note!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.txtMuted(context))),
          ]),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(
              label: expense.categoryLabel(lang),
              color: isIncome ? AppColors.primaryDark : AppColors.error,
              bg: bg,
            ),
            const SizedBox(height: 6),
            Text(
              isIncome ? _t(lang, 'دخل', 'Revenu') : _t(lang, 'مصروف', 'Dépense'),
              style: AppTextStyles.caption.copyWith(color: AppColors.txtSec(context)),
            ),
          ]),
          const SizedBox(width: 10),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(
              isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: color, size: 22,
            ),
          ),
        ]),
      ),
    );
  }
}