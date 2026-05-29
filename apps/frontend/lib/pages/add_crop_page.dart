import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../services/api_client.dart';
import '../providers/fields_provider.dart';
import '../providers/settings_provider.dart';
import '../models/remote/crop_model.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class AddCropPage extends StatefulWidget {
  const AddCropPage({super.key});
  @override
  State<AddCropPage> createState() => _AddCropPageState();
}

class _AddCropPageState extends State<AddCropPage> {
  String _lang = 'ar';

  // ── form fields ────────────────────────────────────────────────────────────
  String _cropName = RemoteCrop.cropNamePairs.first.$1; // Arabic key
  final _varietyCtrl   = TextEditingController();
  final _notesCtrl     = TextEditingController();
  String _status       = 'planted';
  String? _fieldId;
  DateTime _plantedDate        = DateTime.now();
  DateTime? _expectedHarvestDate;

  bool   _loading = false;
  String? _error;

  // ── status options ─────────────────────────────────────────────────────────
  static const _statuses = ['planted', 'growing', 'ready_to_harvest', 'harvested'];

  String _statusLabel(String s) {
    switch (s) {
      case 'planted':          return _t(_lang, 'مزروع',        'Planté');
      case 'growing':          return _t(_lang, 'ينمو',          'En croissance');
      case 'ready_to_harvest': return _t(_lang, 'جاهز للحصاد',  'Prêt à récolter');
      case 'harvested':        return _t(_lang, 'تم الحصاد',    'Récolté');
      default:                 return s;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'planted':          return Icons.grass_rounded;
      case 'growing':          return Icons.energy_savings_leaf_rounded;
      case 'ready_to_harvest': return Icons.agriculture_rounded;
      case 'harvested':        return Icons.inventory_2_rounded;
      default:                 return Icons.eco_rounded;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ── submit ─────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = context.read<ApiClient>();
      final body = <String, dynamic>{
        'name':        _cropName,
        'status':      _status,
        'plantedDate': _plantedDate.toIso8601String(),
        if (_expectedHarvestDate != null) 'expectedHarvestDate': _expectedHarvestDate!.toIso8601String(),
        if (_varietyCtrl.text.trim().isNotEmpty) 'variety': _varietyCtrl.text.trim(),
        if (_notesCtrl.text.trim().isNotEmpty)   'notes':   _notesCtrl.text.trim(),
        if (_fieldId != null)                    'fieldId': _fieldId,
      };
      await api.post('/crops', body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_t(_lang, 'تمت إضافة المحصول بنجاح', 'Culture ajoutée avec succès'))));
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() { _loading = false; _error = e.message; });
    } catch (_) {
      setState(() { _loading = false; _error = _t(_lang, 'حدث خطأ', 'Erreur'); });
    }
  }

  @override
  void dispose() {
    _varietyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    _lang = context.watch<SettingsProvider>().settings.language;
    final fields = context.watch<FieldsProvider>().fields;

    return Directionality(
      textDirection: _lang == 'fr' ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        body: SafeArea(
          child: Column(children: [
            // ── header ──────────────────────────────────────────────────────
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
                            border: Border.all(color: AppColors.bord(context))),
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            size: 18, color: AppColors.txtSec(context)),
                      ),
                    ),
                    Text(
                        _t(_lang, 'إضافة محصول', 'Ajouter une culture'),
                        style: AppTextStyles.titleLarge),
                  ]),
            ),

            // ── body ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: _lang == 'fr'
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                  const SizedBox(height: 8),

                  // ── crop name picker ────────────────────────────────────
                  Text(_t(_lang, 'نوع المحصول', 'Type de culture'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bord(context))),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _cropName,
                        isExpanded: true,
                        dropdownColor: AppColors.surf(context),
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.txt(context)),
                        items: RemoteCrop.cropNamePairs.map((pair) {
                          final label = _lang == 'fr' ? pair.$2 : pair.$1;
                          return DropdownMenuItem(
                              value: pair.$1,
                              child: Text(label));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _cropName = v);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── variety (optional) ───────────────────────────────────
                  Text(_t(_lang, 'الصنف (اختياري)', 'Variété (optionnel)'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bord(context))),
                    child: TextField(
                      controller: _varietyCtrl,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _t(_lang, 'مثال: طماطم ريو غراند', 'Ex: Tomate Rio Grande'),
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.txtMuted(context)),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── status ───────────────────────────────────────────────
                  Text(_t(_lang, 'الحالة', 'État'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statuses.map((s) {
                      final sel = s == _status;
                      return GestureDetector(
                        onTap: () => setState(() => _status = s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surf(context),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.bord(context),
                                width: sel ? 1.5 : 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(_statusIcon(s),
                                size: 16,
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.txtSec(context)),
                            const SizedBox(width: 6),
                            Text(_statusLabel(s),
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: sel
                                        ? AppColors.primary
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

                  // ── planted date ─────────────────────────────────────────
                  Text(_t(_lang, 'تاريخ الزراعة', 'Date de plantation'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _plantedDate,
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() {
                        _plantedDate = picked;
                        // Clear harvest date if it's no longer after the new planted date
                        if (_expectedHarvestDate != null &&
                            !_expectedHarvestDate!.isAfter(picked)) {
                          _expectedHarvestDate = null;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppColors.surf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.bord(context))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.txtSec(context)),
                            Text(_formatDate(_plantedDate),
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.txt(context))),
                          ]),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── expected harvest date ────────────────────────────────
                  Text(_t(_lang, 'تاريخ الحصاد المتوقع (اختياري)', 'Date de récolte prévue (optionnel)'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _expectedHarvestDate ?? _plantedDate.add(const Duration(days: 90)),
                        firstDate: _plantedDate.add(const Duration(days: 1)),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _expectedHarvestDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppColors.surf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.bord(context))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.event_rounded,
                                size: 18,
                                color: _expectedHarvestDate != null
                                    ? AppColors.primary
                                    : AppColors.txtSec(context)),
                            _expectedHarvestDate != null
                                ? Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text(_formatDate(_expectedHarvestDate!),
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(color: AppColors.txt(context))),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => setState(() => _expectedHarvestDate = null),
                                      child: Icon(Icons.close_rounded,
                                          size: 16, color: AppColors.txtSec(context)),
                                    ),
                                  ])
                                : Text(
                                    _t(_lang, 'اختر تاريخاً', 'Choisir une date'),
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: AppColors.txtMuted(context))),
                          ]),
                    ),
                  ),

                  // ── field picker (optional) ──────────────────────────────
                  if (fields.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(_t(_lang, 'الحقل (اختياري)', 'Champ (optionnel)'),
                        style: AppTextStyles.headlineMedium),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          color: AppColors.surf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.bord(context))),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _fieldId,
                          isExpanded: true,
                          dropdownColor: AppColors.surf(context),
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.txt(context)),
                          hint: Text(
                              _t(_lang, 'اختر حقلاً', 'Choisir un champ'),
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.txtMuted(context))),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text(_t(_lang, 'بدون حقل', 'Sans champ'),
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.txtSec(context))),
                            ),
                            ...fields.map((f) => DropdownMenuItem<String?>(
                                value: f.id, child: Text(f.name))),
                          ],
                          onChanged: (v) => setState(() => _fieldId = v),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── notes ────────────────────────────────────────────────
                  Text(_t(_lang, 'ملاحظات (اختياري)', 'Notes (optionnel)'),
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surf(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bord(context))),
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _t(_lang, 'أضف ملاحظة...', 'Ajouter une note...'),
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.txtMuted(context)),
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

                  // ── submit ───────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _loading ? null : _submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)
                              : Text(
                                  _t(_lang, '✓  حفظ المحصول',
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