import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_client.dart';
import '../models/remote/expense_model.dart';
import 'load_state.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiClient _api;
  ExpenseProvider(this._api);

  static const _localKey = 'local_expenses';

  LoadState _state = LoadState.idle;
  List<RemoteExpense> _expenses = [];
  String? _errorMessage;
  bool _usingLocal = false; // true when backend not available

  LoadState get state => _state;
  List<RemoteExpense> get expenses => List.unmodifiable(_expenses);
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LoadState.loading;
  bool get usingLocal => _usingLocal;

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> load({String? type, int? month, int? year}) async {
    // Keep stale data visible while fetching — no flash-empty on filter switch.
    _state = LoadState.loading;
    _errorMessage = null;
    try {
      final params = <String>['limit=100'];
      if (type != null) params.add('type=$type');
      final res = await _api.get('/expenses?${params.join("&")}');
      final raw = res is Map ? (res['items'] ?? res['data'] ?? res) : res;
      final data = raw is List ? raw : <dynamic>[];
      _expenses = data
          .map((e) => RemoteExpense.fromJson(e as Map<String, dynamic>))
          .toList();
      _usingLocal = false;
      _state = LoadState.loaded;
    } catch (_) {
      // Backend not available — fall back to local storage
      await _loadLocal(type: type, month: month, year: year);
      _usingLocal = true;
      _state = LoadState.loaded;
    }
    notifyListeners();
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  Future<bool> add(Map<String, dynamic> dto) async {
    try {
      // Try backend first
      final res = await _api.post('/expenses', dto);
      final newItem = RemoteExpense.fromJson(res as Map<String, dynamic>);
      _expenses.insert(0, newItem);
      _usingLocal = false;
      notifyListeners();
      return true;
    } catch (_) {
      // Save locally
      final newItem = RemoteExpense(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        type: dto['type'] as String,
        category: dto['category'] as String,
        amount: (dto['amount'] as num).toDouble(),
        currency: dto['currency'] as String? ?? 'DZD',
        note: dto['note'] as String?,
        date: dto['date'] as String,
        createdAt: DateTime.now().toIso8601String(),
      );
      _expenses.insert(0, newItem);
      _usingLocal = true;
      await _saveLocal();
      notifyListeners();
      return true; // still return true so UI shows success
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<bool> delete(String id) async {
    _expenses = _expenses.where((e) => e.id != id).toList();
    notifyListeners();
    if (_usingLocal || id.startsWith('local_')) {
      await _saveLocal();
      return true;
    }
    try {
      await _api.delete('/expenses/$id');
      return true;
    } catch (_) {
      await _saveLocal();
      return true;
    }
  }

  // ── Local storage ─────────────────────────────────────────────────────────
  Future<void> _saveLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _expenses.map((e) => {
      'id': e.id,
      'type': e.type,
      'category': e.category,
      'amount': e.amount,
      'currency': e.currency,
      'note': e.note,
      'date': e.date,
      'createdAt': e.createdAt,
    }).toList();
    await prefs.setString(_localKey, jsonEncode(json));
  }

  Future<void> _loadLocal({String? type, int? month, int? year}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localKey);
    if (raw == null) { _expenses = []; return; }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _expenses = list
          .map((e) => RemoteExpense.fromJson(e as Map<String, dynamic>))
          .where((e) {
            if (type != null && e.type != type) return false;
            if (month != null || year != null) {
              try {
                final d = DateTime.parse(e.date);
                if (month != null && d.month != month) return false;
                if (year != null && d.year != year) return false;
              } catch (_) {}
            }
            return true;
          })
          .toList();
    } catch (_) {
      _expenses = [];
    }
  }

  // ── Computed totals ───────────────────────────────────────────────────────
  double get totalIncome => _expenses
      .where((e) => e.isIncome)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpenses => _expenses
      .where((e) => e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get balance => totalIncome - totalExpenses;

  Map<String, List<RemoteExpense>> get groupedByDate {
    final map = <String, List<RemoteExpense>>{};
    for (final e in _expenses) {
      map.putIfAbsent(e.formattedDate, () => []).add(e);
    }
    return map;
  }
}