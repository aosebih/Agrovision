import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/load_state.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/fields_provider.dart';
import '../providers/settings_provider.dart';
import 'field_detail_page.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

// ── Full-screen map location picker ──────────────────────────────────────────
class _MapPickerPage extends StatefulWidget {
  final LatLng? initial;
  const _MapPickerPage({this.initial});
  @override
  State<_MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<_MapPickerPage> {
  LatLng? _picked;
  final MapController _ctrl = MapController();

  static const _defaultCenter = LatLng(28.0339, 1.6596); // Algeria center

  @override
  void initState() {
    super.initState();
    _picked = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    return Scaffold(
      body: Stack(children: [
        FlutterMap(
          mapController: _ctrl,
          options: MapOptions(
            initialCenter: _picked ?? widget.initial ?? _defaultCenter,
            initialZoom: _picked != null ? 14 : 5,
            onTap: (_, pos) => setState(() => _picked = pos),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_application_1',
            ),
            if (_picked != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _picked!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin,
                        color: AppColors.primary, size: 40),
                  ),
                ],
              ),
          ],
        ),
        // Top bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6)
                        ]),
                    child: const Icon(Icons.close_rounded, size: 20),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 6)
                        ]),
                    child: Text(
                      _t(lang, 'اضغط على الخريطة لتحديد الموقع',
                          'Appuyez sur la carte pour choisir l\'emplacement'),
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
        // Confirm button
        if (_picked != null)
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, _picked),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text(
                    _t(lang, '✓  تأكيد الموقع', '✓  Confirmer l\'emplacement'),
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

// ── Fields page ───────────────────────────────────────────────────────────────
class FieldsPage extends StatefulWidget {
  const FieldsPage({super.key});
  @override
  State<FieldsPage> createState() => _FieldsPageState();
}

class _FieldsPageState extends State<FieldsPage> {
  String _lang = 'ar';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FieldsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    final lang = _lang;
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Consumer<FieldsProvider>(
        builder: (context, provider, _) => SafeArea(
          child: Column(children: [
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
                        border: Border.all(color: AppColors.bord(context))),
                    child: const Icon(Icons.map_outlined,
                        size: 20, color: AppColors.primary),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                    Text(_t(lang, 'حقولي', 'Mes champs'),
                        style: AppTextStyles.titleLarge),
                    Text(
                        _t(lang, 'إدارة حقول مزرعتك',
                            'Gérer vos champs'),
                        style: AppTextStyles.caption),
                  ]),
                ],
              ),
            ),
            Expanded(child: _body(provider)),
          ]),
        ),
      ),
    );
  }

  Widget _body(FieldsProvider provider) {
    if (provider.isLoading && provider.fields.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (provider.state == LoadState.error && provider.fields.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded,
              color: AppColors.txtMuted(context), size: 48),
          const SizedBox(height: 12),
          Text(
              provider.errorMessage ??
                  _t(_lang, 'تعذر التحميل', 'Erreur de chargement'),
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          GreenButton(
              label: _t(_lang, 'إعادة المحاولة', 'Réessayer'),
              onTap: () => provider.load()),
        ]),
      );
    }
    if (provider.fields.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.landscape_outlined,
              color: AppColors.txtMuted(context), size: 56),
          const SizedBox(height: 12),
          Text(_t(_lang, 'لا توجد حقول بعد', 'Aucun champ encore'),
              style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          Text(
              _t(_lang, 'أضف حقلك الأول للبدء',
                  'Ajoutez votre premier champ'),
              style: AppTextStyles.bodySmall),
          const SizedBox(height: 20),
          GreenButton(
              label: _t(_lang, 'إضافة حقل جديد', 'Ajouter un champ'),
              icon: Icons.add_rounded,
              onTap: () => _showAddSheet(context)),
        ]),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: provider.fields.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _FieldCard(
          field: provider.fields[i],
          provider: provider,
          lang: _lang,
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: _AddFieldSheet(
          onAdded: () => context.read<FieldsProvider>().load(),
          lang: context.read<SettingsProvider>().settings.language,
        ),
      ),
    );
  }
}

// ── Field card ────────────────────────────────────────────────────────────────
class _FieldCard extends StatelessWidget {
  final Field field;
  final FieldsProvider provider;
  final String lang;
  const _FieldCard(
      {required this.field, required this.provider, required this.lang});

  Color get _statusColor {
    switch (field.status) {
      case 'active':    return AppColors.primary;
      case 'fallow':    return AppColors.warning;
      case 'harvested': return AppColors.info;
      default:          return AppColors.textMuted;
    }
  }

  Color get _statusBg {
    switch (field.status) {
      case 'active':    return AppColors.primaryLight;
      case 'fallow':    return AppColors.orangeLight;
      case 'harvested': return AppColors.blueLight;
      default:          return AppColors.surfaceAlt;
    }
  }

  Future<void> _openInMaps() async {
    final lat = field.latitude;
    final lng = field.longitude;
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) => CardShell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FieldDetailPage(field: field)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            // Delete button
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete_outline_rounded,
                    size: 16, color: AppColors.error),
              ),
            ),
            // Open in Maps button (only shown if coords exist)
            if (field.latitude != null && field.longitude != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: _openInMaps,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.map_rounded,
                      size: 16, color: AppColors.primary),
                ),
              ),
            ],
            const Spacer(),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(field.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.txt(context),
                      fontWeight: FontWeight.w600)),
              if (field.location != null)
                Text(field.location!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.txtMuted(context))),
              if (field.latitude != null && field.longitude != null)
                Text(
                  '${field.latitude!.toStringAsFixed(5)}, ${field.longitude!.toStringAsFixed(5)}',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary.withOpacity(0.7),
                      fontSize: 10),
                ),
            ]),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: AppColors.primLight(context),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.landscape_rounded,
                  color: AppColors.primary, size: 26),
            ),
          ]),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            StatusBadge(
                label: field.statusLabel,
                color: _statusColor,
                bg: _statusBg),
            Row(children: [
              if (field.areaHectares != null) ...[
                Text('${field.areaHectares!.toStringAsFixed(1)} هكتار',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.txtSec(context),
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
              ],
              if (field.soilType != null)
                Text('تربة: ${field.soilType!}',
                    style: AppTextStyles.caption),
            ]),
          ]),
        ]),
      );

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('حذف ${field.name}؟',
              style: AppTextStyles.headlineMedium),
          content: Text('سيتم حذف هذا الحقل نهائياً',
              style: AppTextStyles.bodySmall),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            TextButton(
              onPressed: () async {
                final p = provider;
                final id = field.id;
                Navigator.pop(context);
                await p.deleteField(id);
              },
              child: Text('حذف',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add field sheet ───────────────────────────────────────────────────────────
class _AddFieldSheet extends StatefulWidget {
  final VoidCallback onAdded;
  final String lang;
  const _AddFieldSheet({required this.onAdded, required this.lang});
  @override
  State<_AddFieldSheet> createState() => _AddFieldSheetState();
}

class _AddFieldSheetState extends State<_AddFieldSheet> {
  final _nameCtrl     = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _areaCtrl     = TextEditingController();
  final _soilCtrl     = TextEditingController();
  String _status = 'active';
  bool _loading = false;
  String? _error;
  LatLng? _pickedLocation;

  String get _lang => widget.lang;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _areaCtrl.dispose();
    _soilCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _MapPickerPage(initial: _pickedLocation),
      ),
    );
    if (result != null) {
      setState(() {
        _pickedLocation = result;
        if (_locationCtrl.text.trim().isEmpty) {
          _locationCtrl.text =
              '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
        }
      });
    }
  }

  void _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = _t(_lang, 'يرجى إدخال اسم الحقل',
          'Veuillez entrer un nom de champ'));
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<FieldsProvider>();
    final ok = await provider.addField({
      'name': _nameCtrl.text.trim(),
      if (_locationCtrl.text.trim().isNotEmpty)
        'location': _locationCtrl.text.trim(),
      if (_pickedLocation != null) 'latitude': _pickedLocation!.latitude,
      if (_pickedLocation != null) 'longitude': _pickedLocation!.longitude,
      if (_areaCtrl.text.trim().isNotEmpty)
        'areaHectares': double.tryParse(_areaCtrl.text.trim()),
      if (_soilCtrl.text.trim().isNotEmpty)
        'soilType': _soilCtrl.text.trim(),
      'status': _status,
    });

    if (mounted) {
      setState(() => _loading = false);
      if (ok) {
        widget.onAdded();
        Navigator.pop(context);
      } else {
        setState(() => _error =
            provider.errorMessage ?? _t(_lang, 'حدث خطأ', 'Une erreur est survenue'));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24))),
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
            const SizedBox(height: 20),
            Text(
                _t(_lang, 'إضافة حقل جديد', 'Ajouter un champ'),
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 20),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.error.withOpacity(0.3))),
                child: Text(_error!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.error)),
              ),
            ],
            _SheetField(
                label: _t(_lang, 'اسم الحقل *', 'Nom du champ *'),
                controller: _nameCtrl,
                hint: _t(_lang, 'الحقل الشمالي', 'Champ Nord')),
            const SizedBox(height: 12),

            // Location text field + map picker button
            Text(
              _t(_lang, 'الموقع', 'Localisation'),
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.txt(context),
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.bg(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.bord(context))),
                  child: TextField(
                    controller: _locationCtrl,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.txt(context)),
                    decoration: InputDecoration(
                      hintText: _t(_lang, 'جيجل، الجزائر', 'Jijel, Algérie'),
                      hintStyle: AppTextStyles.caption
                          .copyWith(color: AppColors.txtMuted(context)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Map pin button
              GestureDetector(
                onTap: _pickOnMap,
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: _pickedLocation != null
                        ? AppColors.primary
                        : AppColors.surfAlt(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _pickedLocation != null
                            ? AppColors.primary
                            : AppColors.bord(context)),
                  ),
                  child: Icon(
                    Icons.pin_drop_rounded,
                    size: 20,
                    color: _pickedLocation != null
                        ? Colors.white
                        : AppColors.txtMuted(context),
                  ),
                ),
              ),
            ]),
            // Coordinates preview
            if (_pickedLocation != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ]),
              ),

            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _SheetField(
                      label: _t(_lang, 'المساحة (هكتار)', 'Surface (ha)'),
                      controller: _areaCtrl,
                      hint: '5.0',
                      isNumber: true)),
              const SizedBox(width: 12),
              Expanded(
                  child: _SheetField(
                      label: _t(_lang, 'نوع التربة', 'Type de sol'),
                      controller: _soilCtrl,
                      hint: _t(_lang, 'طينية', 'Argileux'))),
            ]),
            const SizedBox(height: 12),
            Text(
                _t(_lang, 'الحالة', 'Statut'),
                style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.txt(context))),
            const SizedBox(height: 8),
            Row(children: [
              _StatusChip(
                  label: _t(_lang, 'نشط', 'Actif'),
                  value: 'active',
                  selected: _status,
                  onTap: (v) => setState(() => _status = v)),
              const SizedBox(width: 8),
              _StatusChip(
                  label: _t(_lang, 'بور', 'En jachère'),
                  value: 'fallow',
                  selected: _status,
                  onTap: (v) => setState(() => _status = v)),
              const SizedBox(width: 8),
              _StatusChip(
                  label: _t(_lang, 'محصود', 'Récolté'),
                  value: 'harvested',
                  selected: _status,
                  onTap: (v) => setState(() => _status = v)),
            ]),
            const SizedBox(height: 24),
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
                        : Text(
                            _t(_lang, 'إضافة الحقل', 'Ajouter le champ'),
                            style: AppTextStyles.buttonText)),
              ),
            ),
          ]),
        ),
      );
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final bool isNumber;
  const _SheetField(
      {required this.label,
      required this.controller,
      required this.hint,
      this.isNumber = false});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(
                color: AppColors.txt(context),
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
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

class _StatusChip extends StatelessWidget {
  final String label, value, selected;
  final ValueChanged<String> onTap;
  const _StatusChip(
      {required this.label,
      required this.value,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final sel = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary : AppColors.surfAlt(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color:
                  sel ? AppColors.primary : AppColors.bord(context)),
        ),
        child: Text(label,
            style: AppTextStyles.caption.copyWith(
                color:
                    sel ? Colors.white : AppColors.txtSec(context))),
      ),
    );
  }
}
