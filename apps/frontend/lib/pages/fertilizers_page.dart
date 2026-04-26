import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../providers/dashboard_provider.dart';
import '../models/remote/dashboard_response.dart';
import 'inventory_detail_page.dart';
import 'inventory_page.dart';

class FertilizersPage extends StatefulWidget {
  const FertilizersPage({super.key});
  @override
  State<FertilizersPage> createState() => _FertilizersPageState();
}

class _FertilizersPageState extends State<FertilizersPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) => SafeArea(
            child: Column(children: [
          _header(),
          _searchBar(),
          _categoryChips(),
          Expanded(child: _body(context, provider)),
        ])),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border)),
              child: const Icon(Icons.filter_list_rounded,
                  size: 20, color: AppColors.textSecondary)),
          Text('الأسمدة والمستلزمات', style: AppTextStyles.titleLarge),
        ]),
      );

  Widget _searchBar() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
            height: 46,
            decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border)),
            child: Row(children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded,
                  size: 20, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Text('ابحث عن البذور أو الأسمدة...',
                  style: AppTextStyles.bodySmall)
            ])),
      );

  Widget _categoryChips() => SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _cats.length,
        itemBuilder: (_, i) {
          final sel = i == _selCat;
          return GestureDetector(
              onTap: () => setState(() => _selCat = i),
              child: Container(
                  margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border)),
                  child: Text(_cats[i],
                      style: AppTextStyles.bodySmall.copyWith(
                          color:
                              sel ? Colors.white : AppColors.textSecondary))));
        },
      ));

  Widget _body(BuildContext context, DashboardProvider provider) {
    if (provider.isLoading && provider.data == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (provider.state == LoadState.error && provider.data == null) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded,
            color: AppColors.textMuted, size: 48),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'تعذر التحميل',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        GreenButton(label: 'إعادة المحاولة', onTap: () => provider.load()),
      ]));
    }
    final items = provider.data?.storage ?? [];
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.load(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Row(children: [
            Expanded(
                child: _quickCard(
                    Icons.inventory_2_outlined,
                    'المخزون',
                    AppColors.orange,
                    AppColors.orangeLight,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const InventoryPage())))),
            const SizedBox(width: 12),
            Expanded(
                child: _quickCard(
                    Icons.add_circle_outline_rounded,
                    'إضافة منتج',
                    AppColors.primary,
                    AppColors.primaryLight,
                    () {})),
          ]),
          const SizedBox(height: 16),
          const SectionHeader(title: 'المستلزمات المتاحة'),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Center(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child:
                        Text('لا توجد بيانات', style: AppTextStyles.bodySmall)))
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _productCard(context, item),
                )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _quickCard(IconData icon, String label, Color color, Color bg,
          VoidCallback onTap) =>
      GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.2))),
            child: Row(children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Text(label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: color, fontWeight: FontWeight.w600))
            ]),
          ));

  Widget _productCard(BuildContext context, RemoteStorageItem item) {
    final color = item.status == 'available'
        ? AppColors.primaryDark
        : item.status == 'low'
            ? AppColors.error
            : AppColors.warning;
    final bg = item.status == 'available'
        ? AppColors.primaryLight
        : item.status == 'low'
            ? const Color(0xFFFEF2F2)
            : AppColors.orangeLight;
    final label = item.status == 'available'
        ? 'متوفر'
        : item.status == 'low'
            ? 'مخزون منخفض'
            : 'متوسط';

    return CardShell(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => InventoryDetailPage(item: item))),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GreenButton(label: 'إضافة', onTap: () {}),
          const SizedBox(height: 6),
          Text('${item.currentKg.toInt()} ${item.unit}',
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusBadge(label: label, color: color, bg: bg),
          const SizedBox(height: 4),
          Text(item.name,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(item.lastUpdatedLabel, style: AppTextStyles.caption),
        ])),
        const SizedBox(width: 10),
        Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.eco_rounded,
                color: AppColors.primary, size: 28)),
      ]),
    );
  }
}
