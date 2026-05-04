import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../services/api_client.dart';

class AddCropPage extends StatefulWidget {
  const AddCropPage({super.key});
  @override
  State<AddCropPage> createState() => _AddCropPageState();
}

class _AddCropPageState extends State<AddCropPage> {
  String? _selectedCrop;
  String? _selectedFieldId;
  List<Map<String, dynamic>> _fields = [];
  final _varietyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _plantedAt;
  DateTime? _expectedHarvest;
  bool _loading = false;
  bool _loadingFields = true;
  String? _error;

  static const _cropTypes = [
    'قمح', 'ذرة', 'فول الصويا', 'أرز', 'شعير',
    'طماطم', 'بطاطس', 'بصل', 'ثوم', 'جزر',
    'فلفل', 'خيار', 'باذنجان', 'كوسة', 'بطيخ',
    'عنب', 'زيتون', 'تمر', 'ليمون', 'برتقال',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFields();
  }

  @override
  void dispose() {
    _varietyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchFields() async {
    try {
      final api = context.read<ApiClient>();
      final res = await api.get('/fields');
      final list = res['data'] as List? ?? res as List? ?? [];
      setState(() {
        _fields = List<Map<String, dynamic>>.from(list);
        _loadingFields = false;
      });
    } catch (_) {
      setState(() => _loadingFields = false);
    }
  }

  Future<void> _pickDate({required bool isPlanted}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isPlanted
          ? (_plantedAt ?? now)
          : (_expectedHarvest ?? now.add(const Duration(days: 90))),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isPlanted) {
          _plantedAt = picked;
        } else {
          _expectedHarvest = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'اختر تاريخ';
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  void _submit() async {
    if (_selectedCrop == null) {
      setState(() => _error = 'يرجى اختيار نوع المحصول');
      return;
    }
    if (_plantedAt == null) {
      setState(() => _error = 'يرجى تحديد تاريخ الزراعة');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiClient>();
      await api.post('/crops', {
        'name': _selectedCrop!,
        if (_selectedFieldId != null) 'fieldId': _selectedFieldId!,
        if (_varietyCtrl.text.trim().isNotEmpty) 'variety': _varietyCtrl.text.trim(),
        'plantedDate': _plantedAt!.toIso8601String(),
        if (_expectedHarvest != null)
          'expectedHarvestDate': _expectedHarvest!.toIso8601String(),
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة المحصول بنجاح'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'حدث خطأ غير متوقع';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 30),
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : GreenButton(
                    label: '✓  حفظ سجل المحصول',
                    onTap: _submit,
                  ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const PageHeader(title: 'إضافة محصول جديد'),
                  const SizedBox(height: 20),

                  // Hero
                  CardShell(
                      child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.eco_rounded,
                              color: Colors.white, size: 26)),
                      const SizedBox(height: 8),
                      Text('بدء دورة زراعية جديدة',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primaryDark)),
                    ])),
                  )),
                  const SizedBox(height: 20),

                  // Error
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              // ignore: deprecated_member_use
                              color: AppColors.error.withOpacity(0.3))),
                      child: Text(_error!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error)),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Crop type
                  Text('ماذا تزرع؟', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                      value: _selectedCrop,
                      hint: Row(children: [
                        const SizedBox(width: 14),
                        const Icon(Icons.eco_rounded,
                            size: 18, color: AppColors.textMuted),
                        const SizedBox(width: 10),
                        Text('اختر نوع المحصول',
                            style: AppTextStyles.bodySmall),
                      ]),
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      borderRadius: BorderRadius.circular(14),
                      items: _cropTypes
                          .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v, style: AppTextStyles.bodyMedium)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCrop = v),
                    )),
                  ),
                  const SizedBox(height: 16),

                  // Field selector (optional)
                  Text('الحقل (اختياري)', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  _loadingFields
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary))
                      : Container(
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.border)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedFieldId,
                              hint: Row(children: [
                                const SizedBox(width: 14),
                                const Icon(Icons.map_outlined,
                                    size: 18, color: AppColors.textMuted),
                                const SizedBox(width: 10),
                                Text('اختر الحقل (اختياري)',
                                    style: AppTextStyles.bodySmall),
                              ]),
                              isExpanded: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              borderRadius: BorderRadius.circular(14),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('بدون حقل',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textMuted)),
                                ),
                                ..._fields.map((f) => DropdownMenuItem<String?>(
                                      value: f['id'] as String,
                                      child: Text(f['name'] as String? ?? '',
                                          style: AppTextStyles.bodyMedium),
                                    )),
                              ],
                              onChanged: (v) =>
                                  setState(() => _selectedFieldId = v),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),

                  // Variety
                  Text('الصنف / النوع', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: TextField(
                      controller: _varietyCtrl,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'مثال: جيزة 171',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.label_outline_rounded,
                            size: 18, color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Planted date
                  Text('متى تمت الزراعة؟',
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _pickDate(isPlanted: true),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 18, color: AppColors.textMuted),
                            Text(
                              _formatDate(_plantedAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: _plantedAt != null
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted),
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Expected harvest date
                  Text('تاريخ الحصاد المتوقع',
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _pickDate(isPlanted: false),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.event_available_rounded,
                                size: 18, color: AppColors.textMuted),
                            Text(
                              _formatDate(_expectedHarvest),
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: _expectedHarvest != null
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted),
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  Text('ملاحظات (اختياري)',
                      style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border)),
                    child: TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'أضف أي ملاحظات حول المحصول...',
                        hintStyle: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      );
}