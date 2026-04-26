import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/dashboard_response.dart';
import 'inventory_detail_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  int _selCat = 0;
  final _cats = const ['جميع العناصر', 'الأسمدة', 'البذور', 'المبيد'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<DashboardProvider>();
      if (p.data == null) p.load();
    });
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          return SafeArea(child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.textSecondary)),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('المخزون', style: AppTextStyles.titleLarge),
                Text('إدارة مستلزمات مزرعتك', style: AppTextStyles.caption),
              ]),
            ])),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6), child: Container(
              height: 46,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Row(children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, size: 20, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Text('ابحث عن البذور أو الأسمدة...', style: AppTextStyles.bodySmall),
              ]),
            )),
            SizedBox(height: 44, child: ListView.builder(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _cats.length,
              itemBuilder: (_, i) {
                final sel = i == _selCat;
                return GestureDetector(onTap: () => setState(() => _selCat = i), child: Container(
                  margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: sel ? AppColors.primary : AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: sel ? AppColors.primary : AppColors.border)),
                  child: Text(_cats[i], style: AppTextStyles.bodySmall.copyWith(color: sel ? Colors.white : AppColors.textSecondary))));
              },
            )),
            const SizedBox(height: 8),
            Expanded(child: _body(provider)),
          ]));
        },
      ),
    ),
  );

  Widget _body(DashboardProvider provider) {
    if (provider.isLoading && provider.data == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (provider.state == LoadState.error && provider.data == null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'تعذر التحميل', style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(label: 'إعادة المحاولة', onTap: () => provider.load()),
      ]));
    }
    final items = provider.data?.storage ?? [];
    if (items.isEmpty) {
      return Center(child: Text('لا توجد عناصر في المخزون', style: AppTextStyles.bodySmall));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _inventoryCard(items[i]),
      ),
    );
  }

  Widget _inventoryCard(RemoteStorageItem item) {
    final color = item.status == 'available' ? AppColors.primary
        : item.status == 'low' ? AppColors.error : AppColors.warning;
    final bg = item.status == 'available' ? AppColors.primaryLight
        : item.status == 'low' ? const Color(0xFFFEF2F2) : AppColors.orangeLight;
    final label = item.status == 'available' ? 'متوفر'
        : item.status == 'low' ? 'مخزون منخفض' : 'متوسط';

    return CardShell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InventoryDetailPage(item: item))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatusBadge(label: label, color: color, bg: bg),
            const SizedBox(height: 8),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                child: Text('إعادة تعبئة', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary))),
              const SizedBox(width: 8),
              Text('${item.currentKg.toInt()} / ${item.capacityKg.toInt()} ${item.unit}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            ]),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(item.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
            Text(item.lastUpdatedLabel, style: AppTextStyles.caption),
          ])),
          const SizedBox(width: 12),
          Container(width: 50, height: 50, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 28)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(
            value: item.percentage, backgroundColor: AppColors.surfaceAlt,
            valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6)),
        const SizedBox(height: 4),
        Text('${(item.percentage * 100).toInt()}%', style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
