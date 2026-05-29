import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../widgets/app_widgets.dart';
import '../services/api_client.dart';
import '../providers/settings_provider.dart';

class FieldGalleryPage extends StatefulWidget {
  final String fieldId;
  final String fieldName;
  const FieldGalleryPage({super.key, required this.fieldId, required this.fieldName});
  @override
  State<FieldGalleryPage> createState() => _FieldGalleryPageState();
}

class _FieldGalleryPageState extends State<FieldGalleryPage> {
  bool _loading = true;
  bool _uploading = false;
  List<Map<String, dynamic>> _photos = [];
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await context.read<ApiClient>().get('/fields/${widget.fieldId}/photos');
      final list = res is List ? res : ((res as Map)['items'] ?? res['data'] ?? []);
      setState(() { _photos = List<Map<String, dynamic>>.from(list as List); _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _pick() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final api = context.read<ApiClient>();
      await api.post('/fields/${widget.fieldId}/photos', {
        'url': picked.path,
        'caption': 'صورة ميدانية ${DateTime.now().toIso8601String().split('T').first}',
      });
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _delete(String photoId) async {
    try {
      await context.read<ApiClient>().delete('/fields/photos/$photoId');
      setState(() => _photos.removeWhere((p) => p['id'] == photoId));
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  String _t(String ar, String fr) =>
      context.read<SettingsProvider>().settings.language == 'fr' ? fr : ar;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: context.watch<SettingsProvider>().settings.language == 'fr'
        ? TextDirection.ltr : TextDirection.rtl,
    child: Scaffold(
      backgroundColor: AppColors.bg(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploading ? null : _pick,
        backgroundColor: AppColors.primary,
        child: _uploading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(children: [
          PageHeader(title: _t('معرض الصور', 'Galerie photos'), subtitle: widget.fieldName),
          if (_error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(10)),
              child: Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.error)),
            ),
          Expanded(child: _body(context)),
        ]),
      ),
    ),
  );

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_photos.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.photo_library_outlined, color: AppColors.txtMuted(context), size: 60),
      SizedBox(height: 12),
      Text(_t('لا توجد صور بعد', 'Aucune photo'),
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txtMuted(context))),
      SizedBox(height: 6),
      Text(_t('اضغط + لإضافة صورة', 'Appuyez + pour ajouter'),
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.txtMuted(context))),
    ]));

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
        itemCount: _photos.length,
        itemBuilder: (_, i) {
          final p = _photos[i];
          final url = p['url'] as String? ?? '';
          final caption = p['caption'] as String?;
          final date = (p['capturedAt'] as String?)?.split('T').first ?? '';
          return GestureDetector(
            onLongPress: () => _confirmDelete(context, p['id'] as String),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(fit: StackFit.expand, children: [
                url.startsWith('/') || url.startsWith('file://')
                    ? Image.file(File(url.replaceFirst('file://', '')), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ph(context))
                    : Image.network(url, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ph(context)),
                Positioned(bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black54],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
                      if (caption != null && caption.isNotEmpty)
                        Text(caption, style: const TextStyle(color: Colors.white, fontSize: 11),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(date, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    ]),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _ph(BuildContext context) => Container(
      color: AppColors.surfAlt(context),
      child: Icon(Icons.image_outlined, size: 40, color: AppColors.txtMuted(context)));

  void _confirmDelete(BuildContext context, String photoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surf(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_t('حذف الصورة؟', 'Supprimer la photo?'),
              style: AppTextStyles.headlineMedium.copyWith(color: AppColors.txt(context))),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: GreenButton(label: _t('إلغاء', 'Annuler'),
                onTap: () => Navigator.pop(context), outlined: true)),
            const SizedBox(width: 12),
            Expanded(child: GestureDetector(
              onTap: () { Navigator.pop(context); _delete(photoId); },
              child: Container(
                height: 52,
                decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(_t('حذف', 'Supprimer'),
                    style: AppTextStyles.buttonText.copyWith(color: Colors.white))),
              ),
            )),
          ]),
        ]),
      ),
    );
  }
}
