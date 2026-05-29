import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/settings_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/fields_provider.dart';
import '../models/remote/crop_model.dart';
import '../services/api_client.dart';
import 'crop_health_detail_page.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

/// Translates a raw application method key to a display label.
String _methodLabel(String method, String lang) {
  const labels = {
    'foliar':    {'ar': 'رش ورقي',   'fr': 'Foliaire'},
    'soil':      {'ar': 'تطبيق تربة','fr': 'Sol'},
    'drip':      {'ar': 'تنقيط',     'fr': 'Goutte-à-goutte'},
    'broadcast': {'ar': 'بث عام',    'fr': 'Épandage'},
  };
  return labels[method]?[lang] ?? method;
}

/// Feature 2: Field detail showing linked crops + fertilizer log
/// Feature 5: Fertilizer application log per field
class FieldDetailPage extends StatefulWidget {
  final Field field;
  const FieldDetailPage({super.key, required this.field});

  @override
  State<FieldDetailPage> createState() => _FieldDetailPageState();
}

class _FieldDetailPageState extends State<FieldDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  List<RemoteCrop> _fieldCrops = [];
  List<Map<String, dynamic>> _fertApplications = [];
  List<Map<String, dynamic>> _fertilizers = [];
  bool _loadingCrops = true;
  bool _loadingFert = true;
  String _lang = 'ar';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCrops();
      _loadFertilizers();
      _loadApplications();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadCrops() async {
    if (widget.field.id.isEmpty) {
      setState(() => _loadingCrops = false);
      return;
    }
    try {
      // Feature 2: fetch crops filtered by fieldId
      final provider = context.read<DashboardProvider>();
      // Filter local crops first (fast), then also try API filter
      final local = provider.crops
          .where((c) => c.fieldId == widget.field.id)
          .toList();
      setState(() {
        _fieldCrops = local;
        _loadingCrops = false;
      });
      // Also refresh from API with fieldId filter
      final api = context.read<ApiClient>();
      final res = await api.get('/crops?fieldId=${widget.field.id}&limit=50');
      final list =
          res['items'] as List? ?? res['data'] as List? ?? res as List? ?? [];
      if (mounted) {
        setState(() {
          _fieldCrops = list
              .map((e) => RemoteCrop.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCrops = false);
    }
  }

  Future<void> _loadFertilizers() async {
    try {
      final api = context.read<ApiClient>();
      final res = await api.get('/fertilizers?limit=50');
      final list =
          res['items'] as List? ?? res['data'] as List? ?? res as List? ?? [];
      if (mounted) {
        setState(() {
          _fertilizers =
              List<Map<String, dynamic>>.from(list);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadApplications() async {
    if (widget.field.id.isEmpty) {
      setState(() => _loadingFert = false);
      return;
    }
    try {
      final api = context.read<ApiClient>();
      // Feature 5: load fertilizer applications for this field
      final res = await api
          .get('/fertilizers/applications/list?fieldId=${widget.field.id}&limit=50');
      final list =
          res['items'] as List? ?? res['data'] as List? ?? res as List? ?? [];
      if (mounted) {
        setState(() {
          _fertApplications =
              List<Map<String, dynamic>>.from(list);
          _loadingFert = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFert = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    final field = widget.field;
    return Directionality(
      textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddApplicationSheet(context),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.science_outlined, color: Colors.white),
          label: Text(
            _t(_lang, 'تسجيل سماد', 'Ajouter application'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Column(children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                        color: AppColors.surfAlt(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.bord(context))),
                    child: Icon(
                      _lang == 'fr'
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: AppColors.txtSec(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(field.name, style: AppTextStyles.titleLarge),
                    if (field.location != null)
                      Text(field.location!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.txtMuted(context))),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            // Field stats strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CardShell(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                  _stat(context,
                      field.areaHectares != null
                          ? '${field.areaHectares!.toStringAsFixed(1)} ha'
                          : '--',
                      _t(_lang, 'المساحة', 'Surface'),
                      Icons.crop_square_rounded),
                  _stat(
                      context,
                      '${_fieldCrops.length}',
                      _t(_lang, 'محاصيل', 'Cultures'),
                      Icons.grass_rounded),
                  _stat(
                      context,
                      '${_fertApplications.length}',
                      _t(_lang, 'تطبيقات', 'Applications'),
                      Icons.science_outlined),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            // Tabs
            TabBar(
              controller: _tabs,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.txtMuted(context),
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: _t(_lang, 'المحاصيل', 'Cultures')),
                Tab(text: _t(_lang, 'الأسمدة', 'Engrais')),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _cropsTab(context),
                  _fertTab(context),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Tab 1: Crops linked to this field ────────────────────────────────────
  Widget _cropsTab(BuildContext context) {
    if (_loadingCrops) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_fieldCrops.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.grass_rounded,
              size: 52, color: AppColors.txtMuted(context)),
          const SizedBox(height: 12),
          Text(_t(_lang, 'لا توجد محاصيل في هذا الحقل',
              'Aucune culture dans ce champ'),
              style: AppTextStyles.bodySmall),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: _fieldCrops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final crop = _fieldCrops[i];
        final statusColor = crop.statusKey == 'healthy'
            ? AppColors.primary
            : crop.statusKey == 'warning'
                ? AppColors.warning
                : AppColors.error;
        final statusBg = crop.statusKey == 'healthy'
            ? AppColors.primaryLight
            : crop.statusKey == 'warning'
                ? AppColors.orangeLight
                : const Color(0xFFFEF2F2);
        return CardShell(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => CropHealthDetailPage(crop: crop))),
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.grass_rounded,
                  size: 26, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(crop.name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.txt(context))),
                if (crop.variety != null)
                  Text(crop.variety!, style: AppTextStyles.caption),
                if (crop.plantedDate != null)
                  Text(
                    _t(_lang, 'زُرع: ${crop.plantedDate!.split('T').first}',
                        'Planté: ${crop.plantedDate!.split('T').first}'),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.txtMuted(context)),
                  ),
              ]),
            ),
            StatusBadge(
                label: crop.statusLabel,
                color: statusColor,
                bg: statusBg),
          ]),
        );
      },
    );
  }

  // ── Tab 2: Fertilizer applications for this field ─────────────────────────
  Widget _fertTab(BuildContext context) {
    if (_loadingFert) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_fertApplications.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.science_outlined,
              size: 52, color: AppColors.txtMuted(context)),
          const SizedBox(height: 12),
          Text(
            _t(_lang, 'لم يتم تسجيل أي سماد لهذا الحقل',
                'Aucune application enregistrée'),
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 16),
          GreenButton(
            label: _t(_lang, 'تسجيل أول تطبيق', 'Première application'),
            onTap: () => _showAddApplicationSheet(context),
          ),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: _fertApplications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final app = _fertApplications[i];
        final fertName = (app['fertilizer'] as Map<String, dynamic>?)?['name']
                as String? ??
            _t(_lang, 'سماد', 'Engrais');
        final qty = app['quantity']?.toString() ?? '?';
        final unit = app['unit'] as String? ?? 'kg';
        final appliedAt = (app['appliedAt'] as String? ?? '')
            .split('T')
            .first;
        final method = app['method'] as String?;
        final notes = app['notes'] as String?;
        return CardShell(
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.science_outlined,
                  size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(fertName,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.txt(context))),
                Text(
                  '$qty $unit${method != null ? ' · ${_methodLabel(method, _lang)}' : ''}',
                  style: AppTextStyles.caption,
                ),
                if (notes != null && notes.isNotEmpty)
                  Text(notes,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.txtMuted(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ]),
            ),
            Text(appliedAt,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.txtMuted(context))),
          ]),
        );
      },
    );
  }

  // ── Add fertilizer application bottom sheet ───────────────────────────────
  void _showAddApplicationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddApplicationSheet(
        fieldId: widget.field.id,
        fertilizers: _fertilizers,
        lang: _lang,
        onAdded: () {
          _loadApplications();
        },
      ),
    );
  }

  Widget _stat(BuildContext context, String val, String label, IconData icon) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(val,
            style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.txt(context), fontWeight: FontWeight.w700)),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.txtMuted(context))),
      ]);
}

// ── Add Application Sheet ─────────────────────────────────────────────────────
class _AddApplicationSheet extends StatefulWidget {
  final String fieldId;
  final List<Map<String, dynamic>> fertilizers;
  final String lang;
  final VoidCallback onAdded;

  const _AddApplicationSheet({
    required this.fieldId,
    required this.fertilizers,
    required this.lang,
    required this.onAdded,
  });

  @override
  State<_AddApplicationSheet> createState() => _AddApplicationSheetState();
}

class _AddApplicationSheetState extends State<_AddApplicationSheet> {
  String? _selectedFertId;
  final _qtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _unit = 'kg';
  String _method = 'foliar';
  DateTime _appliedAt = DateTime.now();
  bool _loading = false;
  String? _error;

  static const _methods = ['foliar', 'soil', 'drip', 'broadcast'];

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _t(String ar, String fr) =>
      widget.lang == 'fr' ? fr : ar;

  Future<void> _submit() async {
    if (_selectedFertId == null) {
      setState(() => _error = _t('اختر نوع السماد', 'Choisissez un engrais'));
      return;
    }
    final qty = double.tryParse(_qtyCtrl.text.trim());
    if (qty == null || qty <= 0) {
      setState(() => _error = _t('أدخل كمية صحيحة', 'Quantité invalide'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<ApiClient>();
      await api.post('/fertilizers/applications', {
        'fertilizerId': _selectedFertId,
        'fieldId': widget.fieldId,
        'quantity': qty,
        'unit': _unit,
        'method': _method,
        'appliedAt': _appliedAt.toIso8601String(),
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      });
      if (mounted) {
        widget.onAdded();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = _t('فشل التسجيل', 'Échec de l\'enregistrement');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surf(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
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
          const SizedBox(height: 16),
          Text(_t('تسجيل تطبيق سماد', 'Enregistrer une application'),
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 16),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(_error!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.error)),
            ),
          // Fertilizer picker
          Text(_t('نوع السماد *', 'Engrais *'),
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.txt(context))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
                color: AppColors.bg(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bord(context))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFertId,
                hint: Text(_t('اختر سماداً', 'Choisir un engrais'),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.txtMuted(context))),
                isExpanded: true,
                items: widget.fertilizers.map((f) {
                  return DropdownMenuItem<String>(
                    value: f['id'] as String,
                    child: Text(f['name'] as String? ?? '',
                        style: AppTextStyles.bodySmall),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedFertId = v),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Quantity + unit
          Row(children: [
            Expanded(
              flex: 2,
              child: _field(
                _t('الكمية *', 'Quantité *'),
                _qtyCtrl,
                hint: '50',
                isNumber: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(_t('الوحدة', 'Unité'),
                    style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.txt(context))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      color: AppColors.bg(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.bord(context))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _unit,
                      isExpanded: true,
                      items: ['kg', 'L', 'g', 'mL'].map((u) =>
                          DropdownMenuItem(
                              value: u,
                              child: Text(u,
                                  style: AppTextStyles.bodySmall))).toList(),
                      onChanged: (v) =>
                          setState(() => _unit = v ?? 'kg'),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          // Method
          Text(_t('طريقة التطبيق', 'Méthode'),
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.txt(context))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _methods.map((m) {
              final sel = m == _method;
              return GestureDetector(
                onTap: () => setState(() => _method = m),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primary
                        : AppColors.surfAlt(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel
                            ? AppColors.primary
                            : AppColors.bord(context)),
                  ),
                  // ✅ FIX: use widget.lang instead of _lang
                  child: Text(_methodLabel(m, widget.lang),
                      style: AppTextStyles.caption.copyWith(
                          color: sel
                              ? Colors.white
                              : AppColors.txtSec(context))),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Date
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _appliedAt,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: AppColors.primary),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _appliedAt = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.bg(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.bord(context))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                Text(
                  '${_appliedAt.year}/${_appliedAt.month.toString().padLeft(2, '0')}/${_appliedAt.day.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.txt(context)),
                ),
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.txtMuted(context)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          _field(_t('ملاحظات', 'Notes'), _notesCtrl,
              hint: _t('اختياري...', 'Optionnel...')),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _loading ? null : _submit,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: _loading
                    ? AppColors.primary.withOpacity(0.7)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(_t('تسجيل', 'Enregistrer'),
                        style: AppTextStyles.buttonText),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String hint = '', bool isNumber = false}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.txt(context))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
              color: AppColors.bg(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.bord(context))),
          child: TextField(
            controller: ctrl,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.txt(context)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.caption
                  .copyWith(color: AppColors.txtMuted(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ]);
}