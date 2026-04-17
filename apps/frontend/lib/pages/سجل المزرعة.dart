// ignore_for_file: file_names
// lib/screens/farm_journal_expenses.dart
// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:flutter_application_1/temes/app_colors.dart';
import 'package:flutter_application_1/temes/text_styles.dart';
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRY POINT — Tab shell wrapping both screens
// ═══════════════════════════════════════════════════════════════════════════════

class FarmJournalExpensesShell extends StatefulWidget {
  const FarmJournalExpensesShell({super.key});

  @override
  State<FarmJournalExpensesShell> createState() =>
      _FarmJournalExpensesShellState();
}

class _FarmJournalExpensesShellState
    extends State<FarmJournalExpensesShell>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cf1f5f9,
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ──────────────────────────────────────────────────
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.cffffff,
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.cecfdf5,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.book_outlined,
                      color: AppColors.c16a34a, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('المزرعة',
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.headlineLarge),
                ),
                IconButton(
                  icon: const Icon(Icons.search,
                      color: AppColors.c475569),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: AppColors.c475569),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // ── Tab bar ───────────────────────────────────────────────────
          Container(
            color: AppColors.cffffff,
            child: TabBar(
              controller: _tab,
              labelStyle: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: AppTextStyles.bodySmall,
              labelColor: AppColors.c16a34a,
              unselectedLabelColor: AppColors.c94a3b8,
              indicatorColor: AppColors.c16a34a,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'يوميات المزرعة'),
                Tab(text: 'المصروفات'),
              ],
            ),
          ),
          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const [
                FarmJournalScreen(),
                FarmExpensesScreen(),
              ],
            ),
          ),
        ]),
      ),
      // ── FAB ───────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tab.index == 0) {
            _showAddEntrySheet(context);
          } else {
            _showAddExpenseSheet(context);
          }
        },
        backgroundColor: AppColors.c16a34a,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: AppColors.cffffff),
      ),
      bottomNavigationBar: const _BottomNav(selectedIndex: 1),
    );
  }

  // ── Add Journal Entry bottom sheet ────────────────────────────────────
  void _showAddEntrySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddJournalEntrySheet(),
    );
  }

  // ── Add Expense bottom sheet ──────────────────────────────────────────
  void _showAddExpenseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddExpenseSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1 — يوميات المزرعة  (Farm Journal)
// ═══════════════════════════════════════════════════════════════════════════════

class FarmJournalScreen extends StatefulWidget {
  const FarmJournalScreen({super.key});

  @override
  State<FarmJournalScreen> createState() => _FarmJournalScreenState();
}

class _FarmJournalScreenState extends State<FarmJournalScreen> {
  int _filterIndex = 0;

  final _filters = ['الكل', 'ري', 'تسميد', 'رش', 'حصاد', 'فحص'];

  final _entries = [
    _JournalEntry(
      id: '1',
      title: 'ري حقل القمح',
      description:
          'تم ري حقل القمح الصلب كاملاً باستخدام نظام الرش التلقائي. استهلاك 4,500 لتر.',
      field: 'حقل القمح',
      category: 'ري',
      date: 'اليوم، 6:00 م',
      icon: Icons.water_drop_outlined,
      color: AppColors.c3b82f6,
      images: 2,
      weather: '28°C ☀️',
      pinned: true,
    ),
    _JournalEntry(
      id: '2',
      title: 'إضافة سماد NPK',
      description:
          'تم تطبيق الجرعة الثالثة من سماد NPK الثلاثي على حقل الذرة. الكمية: 120 كغ.',
      field: 'حقل الذرة',
      category: 'تسميد',
      date: 'أمس، 8:30 ص',
      icon: Icons.science_outlined,
      color: AppColors.c22c55e,
      images: 1,
      weather: '26°C ⛅',
      pinned: false,
    ),
    _JournalEntry(
      id: '3',
      title: 'رش مبيد حشري وقائي',
      description:
          'رش وقائي ضد حشرة القطن على الخضار. استُخدم مبيد بيولوجي بتركيز 2%.',
      field: 'حقل الخضار',
      category: 'رش',
      date: 'منذ 3 أيام',
      icon: Icons.spa_outlined,
      color: AppColors.cf97316,
      images: 3,
      weather: '30°C ☀️',
      pinned: false,
    ),
    _JournalEntry(
      id: '4',
      title: 'فحص صحة التربة',
      description:
          'تم أخذ عينات من التربة وإرسالها للمختبر. النتائج الأولية تشير إلى نقص طفيف في الفوسفور.',
      field: 'كل الحقول',
      category: 'فحص',
      date: 'منذ 5 أيام',
      icon: Icons.biotech_outlined,
      color: AppColors.ca78bfa,
      images: 0,
      weather: '24°C ⛅',
      pinned: false,
    ),
    _JournalEntry(
      id: '5',
      title: 'حصاد جزئي للطماطم',
      description:
          'تم حصاد الدفعة الأولى من الطماطم. الناتج: 380 كغ. الجودة ممتازة.',
      field: 'حقل الخضار',
      category: 'حصاد',
      date: 'منذ أسبوع',
      icon: Icons.agriculture,
      color: AppColors.c16a34a,
      images: 4,
      weather: '27°C ☀️',
      pinned: false,
    ),
    _JournalEntry(
      id: '6',
      title: 'ري تكميلي للذرة',
      description:
          'لوحظ جفاف خفيف في حقل الذرة؛ تم إجراء جلسة ري تكميلية غير مجدولة.',
      field: 'حقل الذرة',
      category: 'ري',
      date: 'منذ أسبوع',
      icon: Icons.water_drop_outlined,
      color: AppColors.c3b82f6,
      images: 0,
      weather: '32°C ☀️',
      pinned: false,
    ),
  ];

  List<_JournalEntry> get _filtered => _filterIndex == 0
      ? _entries
      : _entries
          .where((e) => e.category == _filters[_filterIndex])
          .toList();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // ── Summary strip ─────────────────────────────────────────────
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(children: [
          _SummaryPill(
              label: 'هذا الأسبوع',
              value: '6',
              color: AppColors.c22c55e),
          const SizedBox(width: 8),
          _SummaryPill(
              label: 'هذا الشهر',
              value: '24',
              color: AppColors.c3b82f6),
          const SizedBox(width: 8),
          _SummaryPill(
              label: 'مُثبّت',
              value: '1',
              color: AppColors.cf59e0b),
        ]),
      ),
      // ── Filter chips ──────────────────────────────────────────────
      SizedBox(
        height: 52,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          scrollDirection: Axis.horizontal,
          reverse: true,
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final sel = _filterIndex == i;
            return GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? AppColors.c16a34a : AppColors.cffffff,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: sel
                        ? AppColors.c16a34a
                        : AppColors.ce2e8f0,
                  ),
                ),
                child: Text(
                  _filters[i],
                  style: AppTextStyles.labelSmall.copyWith(
                    color: sel
                        ? AppColors.cffffff
                        : AppColors.c64748b,
                    fontWeight:
                        sel ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      // ── Entry list ────────────────────────────────────────────────
      Expanded(
        child: _filtered.isEmpty
            ? _EmptyState(
                icon: Icons.book_outlined,
                message: 'لا توجد سجلات في هذه الفئة')
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                itemCount: _filtered.length,
                itemBuilder: (_, i) =>
                    _JournalEntryCard(entry: _filtered[i]),
              ),
      ),
    ]);
  }
}

// ─── Journal Entry Card ────────────────────────────────────────────────────────

class _JournalEntryCard extends StatelessWidget {
  const _JournalEntryCard({required this.entry});
  final _JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cffffff,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _kShadow,
        border: entry.pinned
            // ignore: deprecated_member_use
            ? Border.all(color: AppColors.cf59e0b.withOpacity(0.5))
            : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        // ── Header ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: entry.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(entry.icon, color: entry.color, size: 20),
              ),
              const SizedBox(width: 12),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        if (entry.pinned)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(Icons.push_pin_rounded,
                                color: AppColors.cf59e0b, size: 14),
                          ),
                        Expanded(
                          child: Text(
                            entry.title,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.description,
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Divider ───────────────────────────────────────────────
        Divider(height: 1, color: AppColors.ce2e8f0, indent: 14, endIndent: 14),
        // ── Footer ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // Field chip
              _SmallChip(
                icon: Icons.grass,
                label: entry.field,
                color: entry.color,
              ),
              const SizedBox(width: 8),
              // Category chip
              _SmallChip(
                icon: Icons.label_outline,
                label: entry.category,
                color: AppColors.c64748b,
              ),
              const Spacer(),
              // Weather
              Text(entry.weather,
                  style: AppTextStyles.labelSmall),
              const SizedBox(width: 8),
              // Images count
              if (entry.images > 0) ...[
                const Icon(Icons.photo_outlined,
                    color: AppColors.c94a3b8, size: 13),
                const SizedBox(width: 3),
                Text('${entry.images}',
                    style: AppTextStyles.labelSmall),
                const SizedBox(width: 8),
              ],
              // Date
              Text(entry.date, style: AppTextStyles.labelSmall),
            ],
          ),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 2 — المصروفات  (Farm Expenses)
// ═══════════════════════════════════════════════════════════════════════════════

class FarmExpensesScreen extends StatefulWidget {
  const FarmExpensesScreen({super.key});

  @override
  State<FarmExpensesScreen> createState() => _FarmExpensesScreenState();
}

class _FarmExpensesScreenState extends State<FarmExpensesScreen>
    with SingleTickerProviderStateMixin {
  int _periodIndex = 1; // 0=week, 1=month, 2=year
  late AnimationController _chartCtrl;
  late Animation<double> _chartAnim;

  final _periods = ['الأسبوع', 'الشهر', 'السنة'];

  final _expenses = [
    _Expense(
      id: '1',
      title: 'شراء سماد NPK',
      category: 'أسمدة',
      amount: 12400,
      date: 'اليوم',
      icon: Icons.science_outlined,
      color: AppColors.c22c55e,
      field: 'حقل القمح',
      isIncome: false,
    ),
    _Expense(
      id: '2',
      title: 'بيع قمح صلب',
      category: 'مبيعات',
      amount: 45000,
      date: 'أمس',
      icon: Icons.sell_outlined,
      color: AppColors.c16a34a,
      field: 'حقل القمح',
      isIncome: true,
    ),
    _Expense(
      id: '3',
      title: 'مبيدات حشرية',
      category: 'مبيدات',
      amount: 3800,
      date: 'منذ 3 أيام',
      icon: Icons.spa_outlined,
      color: AppColors.cf97316,
      field: 'حقل الخضار',
      isIncome: false,
    ),
    _Expense(
      id: '4',
      title: 'صيانة معدات الري',
      category: 'صيانة',
      amount: 7200,
      date: 'منذ 5 أيام',
      icon: Icons.build_outlined,
      color: AppColors.ca78bfa,
      field: 'كل الحقول',
      isIncome: false,
    ),
    _Expense(
      id: '5',
      title: 'بيع طماطم',
      category: 'مبيعات',
      amount: 18600,
      date: 'منذ أسبوع',
      icon: Icons.sell_outlined,
      color: AppColors.c16a34a,
      field: 'حقل الخضار',
      isIncome: true,
    ),
    _Expense(
      id: '6',
      title: 'أجور العمال',
      category: 'أجور',
      amount: 24000,
      date: 'منذ أسبوع',
      icon: Icons.people_outline,
      color: AppColors.c3b82f6,
      field: 'كل الحقول',
      isIncome: false,
    ),
    _Expense(
      id: '7',
      title: 'شراء بذور ذرة',
      category: 'بذور',
      amount: 5600,
      date: 'منذ 10 أيام',
      icon: Icons.grass,
      color: AppColors.c14b8a6,
      field: 'حقل الذرة',
      isIncome: false,
    ),
    _Expense(
      id: '8',
      title: 'بيع ذرة',
      category: 'مبيعات',
      amount: 32000,
      date: 'منذ 2 أسبوع',
      icon: Icons.sell_outlined,
      color: AppColors.c16a34a,
      field: 'حقل الذرة',
      isIncome: true,
    ),
  ];

  double get _totalIncome =>
      _expenses.where((e) => e.isIncome).fold(0, (s, e) => s + e.amount);
  double get _totalExpense =>
      _expenses.where((e) => !e.isIncome).fold(0, (s, e) => s + e.amount);
  double get _netProfit => _totalIncome - _totalExpense;

  // Category breakdown for chart
  Map<String, double> get _categoryTotals {
    final map = <String, double>{};
    for (final e in _expenses.where((e) => !e.isIncome)) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _chartCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _chartAnim = CurvedAnimation(
        parent: _chartCtrl, curve: Curves.easeOutCubic);
    _chartCtrl.forward();
  }

  @override
  void dispose() {
    _chartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      child: Column(children: [
        // ── Period selector ───────────────────────────────────────
        _PeriodSelector(
          periods: _periods,
          selected: _periodIndex,
          onSelect: (i) => setState(() => _periodIndex = i),
        ),
        const SizedBox(height: 14),
        // ── Balance card ──────────────────────────────────────────
        _BalanceCard(
          income: _totalIncome,
          expense: _totalExpense,
          net: _netProfit,
        ),
        const SizedBox(height: 14),
        // ── Donut + breakdown ─────────────────────────────────────
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('توزيع المصروفات',
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  // Donut chart
                  AnimatedBuilder(
                    animation: _chartAnim,
                    builder: (_, __) => SizedBox(
                      width: 110,
                      height: 110,
                      child: CustomPaint(
                        painter: _DonutChartPainter(
                          segments: _buildSegments(),
                          progress: _chartAnim.value,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(_totalExpense / 1000).toStringAsFixed(1)}k',
                                style: AppTextStyles.valueLarge
                                    .copyWith(fontSize: 16),
                              ),
                              Text('دج',
                                  style: AppTextStyles.labelSmall),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Legend
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _buildSegments()
                          .map((s) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  textDirection: TextDirection.rtl,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: s.color,
                                        borderRadius:
                                            BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(s.label,
                                          textDirection:
                                              TextDirection.rtl,
                                          style:
                                              AppTextStyles.labelSmall),
                                    ),
                                    Text(
                                      '${(s.value / 1000).toStringAsFixed(1)}k',
                                      style:
                                          AppTextStyles.labelSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: s.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // ── Monthly bar chart ─────────────────────────────────────
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('تفصيل',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.c22c55e,
                          fontWeight: FontWeight.w600)),
                  Text('الإيرادات مقابل المصروفات',
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.headlineMedium),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _chartAnim,
                builder: (_, __) => SizedBox(
                  height: 140,
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      incomes: const [
                        45000, 32000, 18600, 52000, 38000, 61000
                      ],
                      expenses: const [
                        24000, 12000, 18000, 28000, 21000, 33000
                      ],
                      progress: _chartAnim.value,
                      incomeColor: AppColors.c22c55e,
                      expenseColor: AppColors.cef4444,
                    ),
                    size: const Size(double.infinity, 140),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو']
                    .map((m) => Text(m,
                        style: AppTextStyles.labelSmall))
                    .toList(),
              ),
              const SizedBox(height: 10),
              // Legend
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LegendDot(
                      color: AppColors.c22c55e, label: 'الإيرادات'),
                  const SizedBox(width: 16),
                  _LegendDot(
                      color: AppColors.cef4444, label: 'المصروفات'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // ── Transaction list ──────────────────────────────────────
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('عرض الكل',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.c22c55e,
                          fontWeight: FontWeight.w600)),
                  Text('آخر المعاملات',
                      textDirection: TextDirection.rtl,
                      style: AppTextStyles.headlineMedium),
                ],
              ),
              const SizedBox(height: 14),
              ..._expenses.asMap().entries.map((e) => Column(children: [
                    _ExpenseRow(expense: e.value),
                    if (e.key < _expenses.length - 1)
                      Divider(
                          height: 14, color: AppColors.ce2e8f0),
                  ])),
            ],
          ),
        ),
      ]),
    );
  }

  List<_DonutSegment> _buildSegments() {
    final colors = [
      AppColors.c22c55e,
      AppColors.c3b82f6,
      AppColors.cf97316,
      AppColors.ca78bfa,
      AppColors.c14b8a6,
    ];
    final totals = _categoryTotals;
    final entries = totals.entries.toList();
    return List.generate(entries.length, (i) => _DonutSegment(
          label: entries[i].key,
          value: entries[i].value,
          color: colors[i % colors.length],
        ));
  }
}

// ─── Expense Row ──────────────────────────────────────────────────────────────

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.expense});
  final _Expense expense;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: expense.isIncome
                ? AppColors.cecfdf5
                // ignore: deprecated_member_use
                : expense.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            expense.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: expense.isIncome
                ? AppColors.c16a34a
                : expense.color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(expense.title,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600)),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Text(expense.category,
                      style: AppTextStyles.labelSmall),
                  const SizedBox(width: 6),
                  Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                          color: AppColors.c94a3b8,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(expense.date,
                      style: AppTextStyles.labelSmall),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${expense.isIncome ? '+' : '-'}'
              '${_formatAmount(expense.amount)} دج',
              style: AppTextStyles.bodyMedium.copyWith(
                color: expense.isIncome
                    ? AppColors.c16a34a
                    : AppColors.cdc2626,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(expense.field,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.labelSmall),
          ],
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD JOURNAL ENTRY SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _AddJournalEntrySheet extends StatefulWidget {
  const _AddJournalEntrySheet();

  @override
  State<_AddJournalEntrySheet> createState() =>
      _AddJournalEntrySheetState();
}

class _AddJournalEntrySheetState extends State<_AddJournalEntrySheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedField = 'حقل القمح';
  String _selectedCategory = 'ري';

  final _fields = ['حقل القمح', 'حقل الذرة', 'حقل الخضار', 'كل الحقول'];
  final _categories = ['ري', 'تسميد', 'رش', 'حصاد', 'فحص', 'أخرى'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.cffffff,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.ce2e8f0,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('تسجيل يومية جديدة',
                textDirection: TextDirection.rtl,
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),
            // Title field
            _SheetField(
              controller: _titleCtrl,
              label: 'عنوان السجل',
              hint: 'مثال: ري حقل القمح',
            ),
            const SizedBox(height: 12),
            // Description field
            _SheetField(
              controller: _descCtrl,
              label: 'التفاصيل',
              hint: 'أضف تفاصيل عن النشاط...',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            // Field selector
            _SheetDropdown(
              label: 'الحقل',
              value: _selectedField,
              items: _fields,
              onChanged: (v) => setState(() => _selectedField = v!),
            ),
            const SizedBox(height: 12),
            // Category selector
            Text('الفئة',
                textDirection: TextDirection.rtl,
                style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              textDirection: TextDirection.rtl,
              spacing: 8,
              runSpacing: 8,
              children: _categories
                  .map((c) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedCategory == c
                                ? AppColors.c16a34a
                                : AppColors.cf1f5f9,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _selectedCategory == c
                                    ? AppColors.c16a34a
                                    : AppColors.ce2e8f0),
                          ),
                          child: Text(c,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _selectedCategory == c
                                    ? AppColors.cffffff
                                    : AppColors.c64748b,
                                fontWeight: _selectedCategory == c
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              )),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save_outlined,
                    color: AppColors.cffffff, size: 18),
                label: Text('حفظ السجل',
                    style: AppTextStyles.buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.c16a34a,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADD EXPENSE SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _selectedField = 'حقل القمح';
  String _selectedCategory = 'أسمدة';
  bool _isIncome = false;

  final _fields = ['حقل القمح', 'حقل الذرة', 'حقل الخضار', 'كل الحقول'];
  final _expenseCategories = [
    'أسمدة', 'مبيدات', 'بذور', 'صيانة', 'أجور', 'وقود', 'أخرى'
  ];
  final _incomeCategories = [
    'مبيعات قمح', 'مبيعات خضار', 'مبيعات ذرة', 'إعانات', 'أخرى'
  ];

  List<String> get _categories =>
      _isIncome ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.cffffff,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.ce2e8f0,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('إضافة معاملة',
                textDirection: TextDirection.rtl,
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            // Income / Expense toggle
            Container(
              decoration: BoxDecoration(
                color: AppColors.cf1f5f9,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _isIncome = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: !_isIncome
                            ? AppColors.cdc2626
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text('مصروف',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: !_isIncome
                                ? AppColors.cffffff
                                : AppColors.c64748b,
                            fontWeight: !_isIncome
                                ? FontWeight.w700
                                : FontWeight.w400,
                          )),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _isIncome = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _isIncome
                            ? AppColors.c16a34a
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text('إيراد',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _isIncome
                                ? AppColors.cffffff
                                : AppColors.c64748b,
                            fontWeight: _isIncome
                                ? FontWeight.w700
                                : FontWeight.w400,
                          )),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            // Amount input
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('المبلغ (دج)',
                    textDirection: TextDirection.rtl,
                    style: AppTextStyles.labelMedium),
                const SizedBox(height: 6),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: AppTextStyles.valueLarge
                      .copyWith(fontSize: 28, color: _isIncome
                          ? AppColors.c16a34a
                          : AppColors.cdc2626),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: AppTextStyles.valueLarge.copyWith(
                        fontSize: 28, color: AppColors.ce2e8f0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.ce2e8f0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.ce2e8f0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: _isIncome
                              ? AppColors.c16a34a
                              : AppColors.cdc2626,
                          width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text('دج',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.c94a3b8)),
                    ),
                    suffixIconConstraints:
                        const BoxConstraints(minHeight: 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            _SheetField(
              controller: _titleCtrl,
              label: 'الوصف',
              hint: 'مثال: شراء سماد NPK',
            ),
            const SizedBox(height: 12),
            // Field
            _SheetDropdown(
              label: 'الحقل',
              value: _selectedField,
              items: _fields,
              onChanged: (v) => setState(() => _selectedField = v!),
            ),
            const SizedBox(height: 12),
            // Category chips
            Text('الفئة',
                textDirection: TextDirection.rtl,
                style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              textDirection: TextDirection.rtl,
              spacing: 8,
              runSpacing: 8,
              children: _categories
                  .map((c) => GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedCategory == c
                                ? (_isIncome
                                    ? AppColors.c16a34a
                                    : AppColors.cdc2626)
                                : AppColors.cf1f5f9,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _selectedCategory == c
                                    ? (_isIncome
                                        ? AppColors.c16a34a
                                        : AppColors.cdc2626)
                                    : AppColors.ce2e8f0),
                          ),
                          child: Text(c,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _selectedCategory == c
                                    ? AppColors.cffffff
                                    : AppColors.c64748b,
                                fontWeight: _selectedCategory == c
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              )),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.save_outlined,
                    color: AppColors.cffffff, size: 18),
                label: Text('حفظ المعاملة',
                    style: AppTextStyles.buttonText),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIncome
                      ? AppColors.c16a34a
                      : AppColors.cdc2626,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMALL REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _SummaryPill extends StatelessWidget {
  const _SummaryPill(
      {required this.label,
      required this.value,
      required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.cffffff,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _kShadow,
        ),
        child: Row(children: [
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Text(label,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.labelSmall),
        ]),
      );
}

class _SmallChip extends StatelessWidget {
  const _SmallChip(
      {required this.icon,
      required this.label,
      required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: color, fontSize: 11)),
          ],
        ),
      );
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.periods,
    required this.selected,
    required this.onSelect,
  });
  final List<String> periods;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cffffff,
          borderRadius: BorderRadius.circular(12),
          boxShadow: _kShadow,
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: periods.asMap().entries.map((e) {
            final sel = e.key == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.c16a34a
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(e.value,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: sel
                            ? AppColors.cffffff
                            : AppColors.c64748b,
                        fontWeight: sel
                            ? FontWeight.w700
                            : FontWeight.w400,
                      )),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.income,
    required this.expense,
    required this.net,
  });
  final double income, expense, net;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.c16a34a, AppColors.c22c55e],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: AppColors.c16a34a.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('صافي الربح الشهري',
              style: AppTextStyles.labelSmall
                  // ignore: deprecated_member_use
                  .copyWith(color: AppColors.cffffff.withOpacity(0.8))),
          const SizedBox(height: 6),
          Text(
            '${_fmt(net)} دج',
            style: AppTextStyles.valueLarge.copyWith(
              color: AppColors.cffffff,
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.cffffff.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(Icons.arrow_downward,
                          color: AppColors.cffffff, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('إيرادات',
                                style: AppTextStyles.labelSmall
                                    .copyWith(
                                        color: AppColors.cffffff
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.8))),
                            Text('${_fmt(income)} دج',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(
                                        color: AppColors.cffffff,
                                        fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppColors.cffffff.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(Icons.arrow_upward,
                          color: AppColors.cffffff, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('مصروفات',
                                style: AppTextStyles.labelSmall
                                    .copyWith(
                                        color: AppColors.cffffff
                                            // ignore: deprecated_member_use
                                            .withOpacity(0.8))),
                            Text('${_fmt(expense)} دج',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(
                                        color: AppColors.cffffff,
                                        fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ]),
      );

  String _fmt(double v) {
    if (v.abs() >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return v.toStringAsFixed(0);
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.ce2e8f0),
            const SizedBox(height: 12),
            Text(message,
                textDirection: TextDirection.rtl,
                style: AppTextStyles.bodySmall),
          ],
        ),
      );
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });
  final TextEditingController controller;
  final String label, hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.ce2e8f0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.ce2e8f0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.c16a34a, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
        ],
      );
}

class _SheetDropdown extends StatelessWidget {
  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label, value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              textDirection: TextDirection.rtl,
              style: AppTextStyles.labelMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.ce2e8f0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              underline: const SizedBox(),
              alignment: AlignmentDirectional.centerEnd,
              style: AppTextStyles.bodyMedium,
              items: items
                  .map((i) => DropdownMenuItem(
                        value: i,
                        child: Text(i,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyles.bodyMedium),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cffffff,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _kShadow,
        ),
        child: child,
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED BOTTOM NAV
// ═══════════════════════════════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex});
  final int selectedIndex;

  static const _items = [
    (Icons.home_rounded, 'الرئيسية'),
    (Icons.book_outlined, 'اليوميات'),
    (Icons.map_outlined, 'الخريطة'),
    (Icons.shopping_cart_outlined, 'المتجر'),
    (Icons.person_outline_rounded, 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cffffff,
          boxShadow: [
            BoxShadow(
                // ignore: deprecated_member_use
                color: AppColors.c0f172a.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -3))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _items.asMap().entries.map((e) {
                final sel = e.key == selectedIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.cecfdf5
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(e.value.$1,
                          color: sel
                              ? AppColors.c16a34a
                              : AppColors.c94a3b8,
                          size: 22),
                      const SizedBox(height: 3),
                      Text(e.value.$2,
                          textDirection: TextDirection.rtl,
                          style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: sel
                                  ? AppColors.c16a34a
                                  : AppColors.c94a3b8)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class _JournalEntry {
  const _JournalEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.field,
    required this.category,
    required this.date,
    required this.icon,
    required this.color,
    required this.images,
    required this.weather,
    required this.pinned,
  });
  final String id, title, description, field, category, date, weather;
  final IconData icon;
  final Color color;
  final int images;
  final bool pinned;
}

class _Expense {
  const _Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
    required this.field,
    required this.isIncome,
  });
  final String id, title, category, date, field;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isIncome;
}

class _DonutSegment {
  const _DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

// ═══════════════════════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════════════════════

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({
    required this.segments,
    required this.progress,
  });
  final List<_DonutSegment> segments;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold(0.0, (s, e) => s + e.value);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeW = 18.0;
    final rect = Rect.fromCircle(
        center: center, radius: radius - strokeW / 2);

    double startAngle = -math.pi / 2;
    for (final seg in segments) {
      final sweep =
          2 * math.pi * (seg.value / total) * progress;
      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep + 0.03;
    }
  }

  @override
  bool shouldRepaint(_DonutChartPainter o) =>
      o.progress != progress;
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({
    required this.incomes,
    required this.expenses,
    required this.progress,
    required this.incomeColor,
    required this.expenseColor,
  });
  final List<double> incomes, expenses;
  final double progress;
  final Color incomeColor, expenseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = [...incomes, ...expenses]
        .reduce((a, b) => a > b ? a : b);
    final count = incomes.length;
    final groupW = size.width / count;
    const barW = 10.0;
    const gap = 3.0;

    for (int i = 0; i < count; i++) {
      final cx = groupW * i + groupW / 2;

      // Income bar
      final ih = (incomes[i] / maxVal) * size.height * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              cx - barW - gap / 2, size.height - ih, barW, ih),
          const Radius.circular(4),
        ),
        Paint()..color = incomeColor,
      );

      // Expense bar
      final eh =
          (expenses[i] / maxVal) * size.height * progress;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              cx + gap / 2, size.height - eh, barW, eh),
          const Radius.circular(4),
        ),
        // ignore: deprecated_member_use
        Paint()..color = expenseColor.withOpacity(0.75),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter o) => o.progress != progress;
}

const _kShadow = [
  BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
];