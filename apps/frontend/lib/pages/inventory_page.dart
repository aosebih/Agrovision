import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/load_state.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/inventory_provider.dart';
import 'add_crop_page.dart';
import '../providers/settings_provider.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selCat = 0;
  String _search = '';
  String _lang = 'ar';
  final _searchCtrl = TextEditingController();

  static const _cats = [
    {'label': 'جميع العناصر', 'value': null},
    {'label': 'الأسمدة', 'value': 'fertilizer'},
    {'label': 'البذور', 'value': 'seed'},
    {'label': 'المبيدات', 'value': 'pesticide'},
    {'label': 'المعدات', 'value': 'equipment'},
    {'label': 'الوقود', 'value': 'fuel'},
    {'label': 'أخرى', 'value': 'other'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final cat = _cats[_selCat]['value'] as String?;
    context
        .read<InventoryProvider>()
        .load(category: cat, search: _search.isNotEmpty ? _search : null);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    final lang = _lang;
    return Scaffold(
          backgroundColor: AppColors.bg(context),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddDialog(context),
            backgroundColor: AppColors.primary,
            child: Icon(Icons.add_rounded, color: Colors.white),
          ),
          body: Consumer<InventoryProvider>(
            builder: (context, provider, _) => SafeArea(
                child: Column(children: [
              // Header
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: AppColors.surf(context),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: AppColors.bord(context))),
                          child: Icon(Icons.tune_rounded,
                              size: 20, color: AppColors.txtSec(context))),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_t(_lang, 'المخزون', 'Stock'), style: AppTextStyles.titleLarge),
                            Text(_t(_lang, 'إدارة مستلزمات مزرعتك', 'Gérer les fournitures'),
                                style: AppTextStyles.caption),
                          ]),
                    ],
                  )),
              // Search
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                        color: AppColors.surf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bord(context))),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) {
                        setState(() => _search = v.trim());
                        _load();
                      },
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.txt(context)),
                      decoration: InputDecoration(
                        hintText: _t(_lang, 'ابحث عن البذور أو الأسمدة...', 'Rechercher...'),
                        hintStyle: AppTextStyles.bodySmall,
                        prefixIcon: Icon(Icons.search_rounded,
                            size: 20, color: AppColors.txtMuted(context)),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  )),
              // Category tabs
              SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _cats.length,
                    itemBuilder: (_, i) {
                      final sel = i == _selCat;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selCat = i;
                            _search = '';
                            _searchCtrl.clear();
                          });
                          _load();
                        },
                        child: Container(
                          margin:
                              const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary
                                : AppColors.surf(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.bord(context)),
                          ),
                          child: Text(_cats[i]['label'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: sel
                                      ? Colors.white
                                      : AppColors.txtSec(context))),
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 8),
              Expanded(child: _body(provider)),
            ])),
          ),
        );
  }

  Widget _body(InventoryProvider provider) {
    if (provider.isLoading)
      // ignore: curly_braces_in_flow_control_structures
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    if (provider.state == LoadState.error) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_off_rounded,
            color: AppColors.txtMuted(context), size: 48),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? _t(_lang, 'تعذر التحميل', 'Erreur de chargement'),
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(label: _t(_lang, 'إعادة المحاولة', 'Réessayer'), onTap: _load),
      ]));
    }

    var items = provider.items;
    if (_search.isNotEmpty) {
      items = items
          .where((i) =>
              i.name.contains(_search) || i.categoryLabel.contains(_search))
          .toList();
    }

    if (items.isEmpty) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inventory_2_outlined,
            color: AppColors.txtMuted(context), size: 52),
        const SizedBox(height: 12),
        Text(_t(_lang, 'لا توجد عناصر في المخزون', 'Aucun article en stock'), style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(
            label: _t(_lang, 'إضافة عنصر جديد', 'Ajouter un article'), onTap: () => _showAddDialog(context)),
      ]));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) =>
            _InventoryCard(item: items[i], provider: provider, lang: _lang),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _AddInventorySheet(onAdded: _load, lang: _lang),
      ),
    );
  }
}

// ── Inventory Card ─────────────────────────────────────────────────────────────
class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final InventoryProvider provider;
  final String lang;
  const _InventoryCard({required this.item, required this.provider, required this.lang});

  Color get _statusColor => item.statusLabel == 'متوفر'
      ? AppColors.primary
      : item.statusLabel == 'مخزون منخفض'
          ? AppColors.error
          : AppColors.warning;

  Color get _statusBg => item.statusLabel == 'متوفر'
      ? AppColors.primaryLight
      : item.statusLabel == 'مخزون منخفض'
          ? const Color(0xFFFEF2F2)
          : AppColors.orangeLight;

  double get _pct => item.minStockLevel != null && item.minStockLevel! > 0
      ? (item.quantity / (item.minStockLevel! * 3)).clamp(0.0, 1.0)
      : 1.0;

  IconData get _icon {
    switch (item.category) {
      case 'fertilizer':
        return Icons.eco_rounded;
      case 'seed':
        return Icons.grass_rounded;
      case 'pesticide':
        return Icons.bug_report_rounded;
      case 'equipment':
        return Icons.construction_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatusBadge(
                label: item.statusLabel, color: _statusColor, bg: _statusBg),
            SizedBox(height: 8),
            Row(children: [
              // Adjust buttons
              _AdjustButton(
                icon: Icons.remove,
                color: AppColors.error,
                onTap: () => _adjust(context, -1),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _showAdjustSheet(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      border: Border.all(color: AppColors.bord(context)),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(_t(lang, 'تعديل الكمية', 'Modifier quantité'),
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.txtSec(context))),
                ),
              ),
              SizedBox(width: 6),
              _AdjustButton(
                icon: Icons.add,
                color: AppColors.primary,
                onTap: () => _adjust(context, 1),
              ),
            ]),
          ]),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item.name,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.txt(context))),
            Text(
                '${item.quantity.toStringAsFixed(item.quantity == item.quantity.roundToDouble() ? 0 : 1)} ${item.unit}',
                style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w700, color: _statusColor)),
            Text(item.categoryLabel, style: AppTextStyles.caption),
          ])),
          SizedBox(width: 12),
          Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(_icon, color: AppColors.primary, size: 28)),
        ]),
        SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
              value: _pct,
              backgroundColor: AppColors.surfAlt(context),
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              minHeight: 6),
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          GestureDetector(
            onTap: () => _confirmDelete(context),
            child: Text(_t(lang, 'حذف', 'Supprimer'),
                style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          ),
          Text(
              item.minStockLevel != null
                  ? 'الحد الأدنى: ${item.minStockLevel!.toStringAsFixed(0)} ${item.unit}'
                  : '',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.txtMuted(context))),
        ]),
      ]),
    );
  }

  void _adjust(BuildContext context, double delta) async {
    final ok = await provider.adjustQuantity(item.id, delta);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.errorMessage ?? 'خطأ'),
          backgroundColor: AppColors.error));
    }
  }

  void _showAdjustSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _AdjustQuantitySheet(item: item, provider: provider, lang: lang),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('حذف ${item.name}؟', style: AppTextStyles.headlineMedium),
          content: Text('سيتم حذف هذا العنصر من المخزون نهائياً',
              style: AppTextStyles.bodySmall),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(_t(lang, 'إلغاء', 'Annuler'))),
            TextButton(
              onPressed: () async {
                // Capture provider before Navigator.pop invalidates context
                final p = provider;
                final id = item.id;
                Navigator.pop(context);
                await p.deleteItem(id);
              },
              child: Text(_t(lang, 'حذف', 'Supprimer'),
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AdjustButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              // ignore: deprecated_member_use
              border: Border.all(color: color.withOpacity(0.3))),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

// ── Adjust Quantity Bottom Sheet ───────────────────────────────────────────────
class _AdjustQuantitySheet extends StatefulWidget {
  final InventoryItem item;
  final InventoryProvider provider;
  final String lang;
  const _AdjustQuantitySheet({required this.item, required this.provider, required this.lang});

  @override
  State<_AdjustQuantitySheet> createState() => _AdjustQuantitySheetState();
}

class _AdjustQuantitySheetState extends State<_AdjustQuantitySheet> {
  final _ctrl = TextEditingController();
  bool _isAdd = true;
  bool _loading = false;
  String get lang => widget.lang;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final val = double.tryParse(_ctrl.text);
    if (val == null || val <= 0) return;
    setState(() => _loading = true);
    final delta = _isAdd ? val : -val;
    final ok = await widget.provider.adjustQuantity(widget.item.id, delta);
    if (mounted) {
      setState(() => _loading = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.bord(context),
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('تعديل كمية: ${widget.item.name}',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 6),
            Text('الكمية الحالية: ${widget.item.quantity} ${widget.item.unit}',
                style: AppTextStyles.bodySmall),
            SizedBox(height: 20),

            // Add / Remove toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: AppColors.surfAlt(context),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Expanded(
                    child: GestureDetector(
                  onTap: () => setState(() => _isAdd = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isAdd ? AppColors.error : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_t(lang, 'سحب من المخزون', 'Retirer du stock'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: !_isAdd
                                ? Colors.white
                                : AppColors.txtMuted(context),
                            fontWeight: FontWeight.w600)),
                  ),
                )),
                Expanded(
                    child: GestureDetector(
                  onTap: () => setState(() => _isAdd = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isAdd ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_t(lang, 'إضافة للمخزون', 'Ajouter au stock'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: _isAdd
                                ? Colors.white
                                : AppColors.txtMuted(context),
                            fontWeight: FontWeight.w600)),
                  ),
                )),
              ]),
            ),
            SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.bord(context))),
              child: TextField(
                controller: _ctrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.ltr,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.txt(context)),
                decoration: InputDecoration(
                  hintText: _t(lang, 'أدخل الكمية', 'Entrer la quantité'),
                  hintStyle: AppTextStyles.bodySmall,
                  suffixText: widget.item.unit,
                  suffixStyle: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.txtMuted(context)),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _isAdd ? AppColors.primary : AppColors.error,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(_isAdd ? _t(lang, 'إضافة للمخزون', 'Ajouter au stock') : _t(lang, 'سحب من المخزون', 'Retirer du stock'),
                          style: AppTextStyles.buttonText),
                ),
              ),
            ),
          ]),
    );
  }
}

// ── Add Inventory Bottom Sheet ─────────────────────────────────────────────────
class _AddInventorySheet extends StatefulWidget {
  final VoidCallback onAdded;
  final String lang;
  const _AddInventorySheet({required this.onAdded, required this.lang});
  @override
  State<_AddInventorySheet> createState() => _AddInventorySheetState();
}

class _AddInventorySheetState extends State<_AddInventorySheet> {
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'كغ');
  final _minCtrl = TextEditingController();
  String _category = 'other';
  bool _loading = false;
  String? _error;
  String get lang => widget.lang;

  static const _categories = [
    {'label': 'سماد', 'value': 'fertilizer'},
    {'label': 'بذور', 'value': 'seed'},
    {'label': 'مبيد', 'value': 'pesticide'},
    {'label': 'معدات', 'value': 'equipment'},
    {'label': 'وقود', 'value': 'fuel'},
    {'label': 'أخرى', 'value': 'other'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameCtrl.text.trim();
    final qty = double.tryParse(_qtyCtrl.text.trim());
    final unit = _unitCtrl.text.trim();
    final minRaw = _minCtrl.text.trim();
    final minStock = minRaw.isNotEmpty ? double.tryParse(minRaw) : null;

    if (name.isEmpty || qty == null || unit.isEmpty) {
      setState(() => _error = _t(lang, 'يرجى ملء جميع الحقول الإلزامية', 'Veuillez remplir tous les champs obligatoires'));
      return;
    }
    if (minRaw.isNotEmpty && minStock == null) {
      setState(() => _error = _t(lang, 'الحد الأدنى يجب أن يكون رقماً صحيحاً', 'Le seuil doit être un nombre valide'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final provider = context.read<InventoryProvider>();
    final dto = <String, dynamic>{
      'name': name,
      'category': _category,
      'quantity': qty,
      'unit': unit,
      // Only include minStockLevel if the user actually entered a valid number
      if (minStock != null) 'minStockLevel': minStock,
    };
    final ok = await provider.addItem(dto);
    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        widget.onAdded();
        Navigator.pop(context);
      } else {
        setState(() => _error = provider.errorMessage ?? _t(lang, 'حدث خطأ', 'Une erreur est survenue'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.bord(context),
                        borderRadius: BorderRadius.circular(2)))),
            SizedBox(height: 20),
            Text(_t(lang, 'إضافة عنصر جديد', 'Nouvel article'), style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),

            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        // ignore: deprecated_member_use
                        Border.all(color: AppColors.error.withOpacity(0.3))),
                child: Text(_error!,
                    style:
                        AppTextStyles.caption.copyWith(color: AppColors.error)),
              ),

            _SheetField(
                label: _t(lang, 'اسم العنصر *', 'Nom de l\'article *'),
                controller: _nameCtrl,
                hint: _t(lang, 'سماد نيتروجيني', 'Engrais azoté')),
            const SizedBox(height: 12),

            // Category chips
            Text(_t(lang, 'الفئة', 'Catégorie'),
                style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.txt(context))),
            const SizedBox(height: 8),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final sel = c['value'] == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = c['value']!),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                          color: sel
                              ? AppColors.primary
                              : AppColors.surfAlt(context),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.bord(context))),
                      child: Text(c['label']!,
                          style: AppTextStyles.caption.copyWith(
                              color: sel
                                  ? Colors.white
                                  : AppColors.txtSec(context))),
                    ),
                  );
                }).toList()),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                  child: _SheetField(
                      label: _t(lang, 'الكمية *', 'Quantité *'),
                      controller: _qtyCtrl,
                      hint: '100',
                      isNumber: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _SheetField(
                      label: _t(lang, 'الوحدة *', 'Unité *'), controller: _unitCtrl, hint: 'kg')),
            ]),
            const SizedBox(height: 12),
            _SheetField(
                label: _t(lang, 'الحد الأدنى للتنبيه', 'Seuil d\'alerte'),
                controller: _minCtrl,
                hint: '10',
                isNumber: true),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: _loading ? null : _submit,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _loading
                      // ignore: deprecated_member_use
                      ? AppColors.primary.withOpacity(0.7)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        // ignore: deprecated_member_use
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(_t(lang, 'إضافة للمخزون', 'Ajouter au stock'), style: AppTextStyles.buttonText),
                ),
              ),
            ),
          ])),
    );
  }
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isNumber;
  const _SheetField(
      {required this.label,
      required this.controller,
      required this.hint,
      this.isNumber = false});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.txt(context), fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bord(context))),
            child: TextField(
              controller: controller,
              keyboardType: isNumber
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              textDirection: isNumber ? TextDirection.ltr : null,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.txt(context)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.caption
                    .copyWith(color: AppColors.txtMuted(context)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
        ],
      );
}