import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/inventory_provider.dart';
import '../providers/settings_provider.dart';

class InventoryDetailPage extends StatefulWidget {
  final InventoryItem item;
  const InventoryDetailPage({super.key, required this.item});
  @override
  State<InventoryDetailPage> createState() => _InventoryDetailPageState();
}

class _InventoryDetailPageState extends State<InventoryDetailPage> {
  late InventoryItem _item;
  bool _adjusting = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  String _t(String ar, String fr) =>
      context.read<SettingsProvider>().settings.language == 'fr' ? fr : ar;

  Future<void> _adjust(int delta) async {
    setState(() => _adjusting = true);
    try {
      final provider = context.read<InventoryProvider>();
      await provider.adjustStock(_item.id, delta);
      // Refresh item from provider
      final updated = provider.items.firstWhere(
          (i) => i.id == _item.id,
          orElse: () => _item);
      setState(() => _item = updated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error));
      }
    }
    if (mounted) setState(() => _adjusting = false);
  }

  void _showEditSheet() {
    final nameCtrl   = TextEditingController(text: _item.name);
    final minCtrl    = TextEditingController(text: _item.minStockLevel?.toString() ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20,
            MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: AppColors.bord(context),
                  borderRadius: BorderRadius.circular(2))),
          Text(_t('تعديل العنصر', 'Modifier l\'article'),
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
          const SizedBox(height: 20),
          _field(nameCtrl, _t('الاسم', 'Nom'), Icons.label_outline_rounded),
          const SizedBox(height: 12),
          _field(minCtrl, _t('الحد الأدنى للمخزون', 'Stock minimum'),
              Icons.warning_amber_rounded, isNumber: true),
          const SizedBox(height: 20),
          GreenButton(
            label: _t('حفظ التغييرات', 'Enregistrer'),
            onTap: () async {
              Navigator.pop(context);
              try {
                await context.read<InventoryProvider>().updateItem(
                  _item.id,
                  name: nameCtrl.text.isNotEmpty ? nameCtrl.text : null,
                  minStockLevel: double.tryParse(minCtrl.text),
                );
              } catch (_) {}
            },
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool isNumber = false}) =>
      Container(
        decoration: BoxDecoration(color: AppColors.surfAlt(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bord(context))),
        child: TextField(
          controller: ctrl,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.txt(context)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context)),
            prefixIcon: Icon(icon, size: 18, color: AppColors.txtMuted(context)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: context.watch<SettingsProvider>().settings.language == 'fr'
        ? TextDirection.ltr : TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.bg(context),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: GreenButton(
            label: _t('تعديل العنصر', "Modifier l'article"),
            icon: Icons.edit_rounded,
            onTap: _showEditSheet),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            PageHeader(title: _t('التفاصيل', 'Détails'), subtitle: _item.name),
            const SizedBox(height: 16),

            // Header card
            CardShell(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                StatusBadge(
                  label: _item.category.isNotEmpty ? _item.category : _t('مخزون', 'Stock'),
                  color: AppColors.primary, bg: AppColors.primaryLight,
                ),
                Text(_item.name, style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.txt(context))),
              ]),
              const SizedBox(height: 4),
              Text('',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context))),
            ])),
            const SizedBox(height: 14),

            // Quantity card with +/- adjust
            CardShell(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                StatusBadge(
                  label: (_item.statusLabel == 'متوفر')
                      ? '● ${_t('متوفر', 'Disponible')}'
                      : (_item.statusLabel == 'مخزون منخفض')
                          ? '⚠ ${_t('منخفض', 'Bas')}'
                          : '● ${_t('متوسط', 'Moyen')}',
                  color: (_item.statusLabel == 'متوفر') ? AppColors.primary
                      : (_item.statusLabel == 'مخزون منخفض') ? AppColors.error : AppColors.warning,
                  bg: (_item.statusLabel == 'متوفر') ? AppColors.primaryLight
                      : (_item.statusLabel == 'مخزون منخفض') ? const Color(0xFFFEF2F2) : AppColors.orangeLight,
                ),
                Text(_t('الكمية المتبقية', 'Quantité restante'),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context))),
              ]),
              const SizedBox(height: 10),
              // Big quantity display
              Center(child: Text(
                '${_item.quantity.toInt()} ${_item.unit}',
                style: AppTextStyles.headlineLarge.copyWith(
                    fontSize: 36, fontWeight: FontWeight.w900,
                    color: (_item.statusLabel == 'مخزون منخفض') ? AppColors.error : AppColors.txt(context)),
              )),
              const SizedBox(height: 12),
              // +/- adjust buttons
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _adjustBtn(context, -10, '−10', AppColors.error),
                const SizedBox(width: 8),
                _adjustBtn(context, -1,  '−1',  AppColors.error),
                const SizedBox(width: 16),
                if (_adjusting)
                  const SizedBox(width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 16),
                _adjustBtn(context,  1,  '+1',  AppColors.primary),
                const SizedBox(width: 8),
                _adjustBtn(context, 10, '+10', AppColors.primary),
              ]),
              const SizedBox(height: 12),
              // Progress bar
              ClipRRect(borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (_item.minStockLevel != null && _item.minStockLevel! > 0 ? (_item.quantity / (_item.minStockLevel! * 3)).clamp(0.0, 1.0) : 0.5),
                  backgroundColor: AppColors.surfAlt(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      (_item.statusLabel == 'متوفر') ? AppColors.primary
                          : (_item.statusLabel == 'مخزون منخفض') ? AppColors.error : AppColors.warning),
                  minHeight: 10,
                )),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('${((_item.minStockLevel != null && _item.minStockLevel! > 0 ? (_item.quantity / (_item.minStockLevel! * 3)).clamp(0.0, 1.0) : 0.5) * 100).toInt()}%',
                    style: AppTextStyles.caption),
                Text('${_t('السعة القصوى', 'Capacité max')}: '
                    '${(_item.minStockLevel != null ? _item.minStockLevel! * 3 : _item.quantity * 2).toInt()} ${_item.unit}',
                    style: AppTextStyles.caption),
              ]),
              if (_item.minStockLevel != null) ...[
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('${_t('الحد الأدنى', 'Seuil min')}: '
                      '${_item.minStockLevel!.toInt()} ${_item.unit}',
                      style: AppTextStyles.caption.copyWith(
                          color: _item.quantity <= _item.minStockLevel!
                              ? AppColors.error : AppColors.txtMuted(context))),
                ]),
              ],
            ])),
            const SizedBox(height: 80),
          ]),
        ),
      ),
    ),
  );

  Widget _adjustBtn(BuildContext context, int delta, String label, Color color) =>
      GestureDetector(
        onTap: _adjusting ? null : () => _adjust(delta),
        child: Container(
          width: 52, height: 44,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.4))),
          child: Center(child: Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15))),
        ),
      );
}
