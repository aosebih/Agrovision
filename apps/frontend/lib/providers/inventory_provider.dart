import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

import 'load_state.dart';

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

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static double? _toDoubleOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
    id: j['id'],
    name: j['name'],
    category: j['category'] ?? 'other',
    brand: j['brand'],
    quantity: _toDouble(j['quantity']),
    unit: j['unit'] ?? 'كغ',
    minStockLevel: _toDoubleOrNull(j['minStockLevel']),
    pricePerUnit: _toDoubleOrNull(j['pricePerUnit']),
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

  Future<void> load({String? category, String? search}) async {
    _state = LoadState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final params = <String>['limit=50'];
      if (category != null) params.add('category=\$category');
      if (search != null && search.isNotEmpty) params.add('search=\${Uri.encodeComponent(search)}');
      final res = await _api.get('/inventory?\${params.join("&")}');
      final raw = res is Map ? (res['items'] ?? res['data'] ?? []) : res;
      final data = raw is List ? raw : <dynamic>[];
      _items = data.map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)).toList();
      _total = (res is Map ? res['total'] : null) ?? _items.length;
      _state = LoadState.loaded;
    } on ApiException catch (e) {
      _state = LoadState.error;
      _errorMessage = e.message;
    } catch (e) {
      _state = LoadState.error;
      _errorMessage = e.toString();
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
  // ── Adjust stock +/- ──────────────────────────────────────────────────────
  Future<void> adjustStock(String id, int delta) async {
    try {
      final res = await _api.patch('/inventory/$id/adjust', {'delta': delta});
      final updated = InventoryItem.fromJson(res as Map<String, dynamic>);
      _items = _items.map((i) => i.id == id ? updated : i).toList();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      rethrow;
    }
  }

  // ── Update item fields ────────────────────────────────────────────────────
  Future<void> updateItem(String id, {String? name, double? minStockLevel}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (minStockLevel != null) body['minStockLevel'] = minStockLevel;
    if (body.isEmpty) return;
    try {
      final res = await _api.patch('/inventory/$id', body);
      final updated = InventoryItem.fromJson(res as Map<String, dynamic>);
      _items = _items.map((i) => i.id == id ? updated : i).toList();
      notifyListeners();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }
}