import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

enum LoadState { idle, loading, loaded, error }

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String? brand;
  final double quantity;
  final String unit;
  final double? minStockLevel;
  final double? pricePerUnit;
  final String? supplier;
  final String? expiryDate;
  final String? notes;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    this.brand,
    required this.quantity,
    required this.unit,
    this.minStockLevel,
    this.pricePerUnit,
    this.supplier,
    this.expiryDate,
    this.notes,
  });

  String get statusLabel {
    if (minStockLevel == null) return 'متوفر';
    if (quantity <= minStockLevel!) return 'مخزون منخفض';
    if (quantity <= minStockLevel! * 1.5) return 'متوسط';
    return 'متوفر';
  }

  String get categoryLabel {
    switch (category) {
      case 'fertilizer': return 'الأسمدة';
      case 'pesticide': return 'المبيدات';
      case 'seed': return 'البذور';
      case 'equipment': return 'المعدات';
      case 'fuel': return 'الوقود';
      default: return 'أخرى';
    }
  }

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
    id: j['id'],
    name: j['name'],
    category: j['category'] ?? 'other',
    brand: j['brand'],
    quantity: (j['quantity'] as num).toDouble(),
    unit: j['unit'] ?? 'كغ',
    minStockLevel: j['minStockLevel'] != null ? (j['minStockLevel'] as num).toDouble() : null,
    pricePerUnit: j['pricePerUnit'] != null ? (j['pricePerUnit'] as num).toDouble() : null,
    supplier: j['supplier'],
    expiryDate: j['expiryDate'],
    notes: j['notes'],
  );
}

class InventoryProvider extends ChangeNotifier {
  final ApiClient _api;
  InventoryProvider(this._api);

  LoadState _state = LoadState.idle;
  List<InventoryItem> _items = [];
  String? _errorMessage;
  int _total = 0;

  LoadState get state => _state;
  List<InventoryItem> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;
  int get total => _total;

  Future<void> load({String? category}) async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final path = category != null ? '/inventory?category=$category&limit=50' : '/inventory?limit=50';
      final res = await _api.get(path);
      final data = res['data'] as List? ?? res as List? ?? [];
      _items = (data).map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
      _total = res['total'] ?? _items.length;
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _state = LoadState.error;
      _errorMessage = e.message;
    } catch (_) {
      _state = LoadState.error;
      _errorMessage = 'حدث خطأ غير متوقع';
    }
    notifyListeners();
  }

  Future<bool> addItem(Map<String, dynamic> dto) async {
    try {
      await _api.post('/inventory', dto);
      await load();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> adjustQuantity(String id, double delta) async {
    try {
      await _api.patch('/inventory/$id/adjust', {'delta': delta});
      // Update local state optimistically
      final idx = _items.indexWhere((i) => i.id == id);
      if (idx != -1) {
        final old = _items[idx];
        final updated = InventoryItem(
          id: old.id, name: old.name, category: old.category,
          brand: old.brand, quantity: (old.quantity + delta).clamp(0, double.infinity),
          unit: old.unit, minStockLevel: old.minStockLevel,
          pricePerUnit: old.pricePerUnit, supplier: old.supplier,
          expiryDate: old.expiryDate, notes: old.notes,
        );
        _items = List.from(_items)..[idx] = updated;
        notifyListeners();
      }
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _api.delete('/inventory/$id');
      _items = _items.where((i) => i.id != id).toList();
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
