import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';

class AddCropPage extends StatefulWidget {
  const AddCropPage({super.key});
  @override
  State<AddCropPage> createState() => _AddCropPageState();
}

class _AddCropPageState extends State<AddCropPage> {
  String? _selectedCrop;
  final _varieties = ['قمح', 'ذرة', 'فول الصويا', 'أرز', 'شعير'];

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: GreenButton(
                  label: '✓  حفظ سجل المحصول',
                  onTap: () => Navigator.pop(context))),
          body: SafeArea(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const PageHeader(title: 'إضافة محصول جديد'),
              const SizedBox(height: 20),
              // Hero illustration
              CardShell(
                  child: Column(children: [
                Container(
                    height: 110,
                    decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12)),
                    child: Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                              color: AppColors.primary, shape: BoxShape.circle),
                          child: const Icon(Icons.eco_rounded,
                              color: Colors.white, size: 26)),
                      const SizedBox(height: 8),
                      Text('بدء دورة زراعية جديدة',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primaryDark)),
                    ]))),
              ])),
              const SizedBox(height: 20),
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
                    Text('اختر نوع المحصول', style: AppTextStyles.bodySmall)
                  ]),
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  borderRadius: BorderRadius.circular(14),
                  items: _varieties
                      .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v, style: AppTextStyles.bodyMedium)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCrop = v),
                )),
              ),
              const SizedBox(height: 16),
              Text('الصنف / النوع', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 10),
              Container(
                height: 50,
                decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(children: [
                  const Icon(Icons.label_outline_rounded,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Text('مثال: جيزة 171',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted))
                ]),
              ),
              const SizedBox(height: 16),
              Text('متى تمت الزراعة؟', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now()),
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
                        Text('mm/dd/yyyy',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted)),
                      ]),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  const Icon(Icons.gps_fixed_rounded,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('استخدام GPS',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ]),
                Text('موقع الحقل', style: AppTextStyles.headlineMedium),
              ]),
              const SizedBox(height: 10),
              GestureDetector(
                  onTap: () {},
                  child: CardShell(
                      child: Row(children: [
                    const Icon(Icons.chevron_left_rounded,
                        size: 18, color: AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                          Text('الحقل الشمالي - القطاع 4',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textPrimary)),
                          Text('34.0522° N, 118.2437° W',
                              style: AppTextStyles.caption),
                        ])),
                    const SizedBox(width: 12),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                            'lib/compenent/images/Satellite view of agricultural fields from above.png',
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 52,
                                height: 52,
                                color: const Color(0xFF2D6A4F),
                                child: const Icon(Icons.map_outlined,
                                    color: Colors.white, size: 28)))),
                  ]))),
              const SizedBox(height: 80),
            ]),
          )),
        ),
      );
}
