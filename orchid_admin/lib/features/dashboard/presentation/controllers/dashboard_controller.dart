import 'package:flutter/foundation.dart';

import '../../../../core/time/egypt_time.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../../core/time/date_range.dart';
import '../../domain/models/dashboard_metrics.dart';

/// Centralized dashboard filter and data state.
class DashboardController extends ChangeNotifier {
  DashboardController({
    DashboardRepository? repository,
    DateRange? initialRange,
  }) : _repository = repository ?? DashboardRepository(),
       _selectedRange =
           initialRange ??
           DateRange.resolve(DateRangePreset.last7Days, now: nowInEgypt());

  static const int recentPageSize = 5;

  final DashboardRepository _repository;

  DateRange _selectedRange;
  DashboardOverview? _overview;
  List<Order> _recentOrders = const <Order>[];
  int _productCount = 0;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _disposed = false;
  String? _error;
  int _requestId = 0;

  DateRange get selectedRange => _selectedRange;

  DashboardOverview? get overview => _overview;

  List<Order> get recentOrders => _recentOrders;

  int get productCount => _productCount;

  bool get isLoading => _isLoading;

  bool get isLoadingMore => _isLoadingMore;

  bool get hasMoreRecentOrders {
    final data = _overview;
    return data != null && _recentOrders.length < data.totalOrders;
  }

  String? get error => _error;

  Future<void> load() async {
    final requestId = ++_requestId;

    _isLoading = true;
    _isLoadingMore = false;
    _error = null;
    _overview = null;
    _recentOrders = const <Order>[];
    _productCount = 0;
    _safeNotify();

    try {
      final snapshot = await _repository.load(
        _selectedRange,
        recentLimit: recentPageSize,
      );
      if (_disposed || requestId != _requestId) return;

      _overview = snapshot.overview;
      _recentOrders = snapshot.recentOrders;
      _productCount = snapshot.productCount;
      _isLoading = false;
      _safeNotify();
    } catch (error) {
      if (_disposed || requestId != _requestId) return;

      _error = error.toString();
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> selectRange(DateRange range) async {
    if (range == _selectedRange) return;

    _selectedRange = range;
    await load();
  }

  /// Loads the next page of recent orders. Returns false when the request
  /// failed so the page can show a lightweight retry message.
  Future<bool> loadMoreRecentOrders() async {
    if (_isLoadingMore || !hasMoreRecentOrders) return true;

    final requestId = _requestId;
    _isLoadingMore = true;
    _safeNotify();

    try {
      final page = await _repository.loadMoreRecentOrders(
        _selectedRange,
        offset: _recentOrders.length,
        limit: recentPageSize,
      );
      if (_disposed || requestId != _requestId) return true;

      final knownIds = _recentOrders.map((order) => order.id).toSet();
      _recentOrders = [
        ..._recentOrders,
        ...page.where((order) => knownIds.add(order.id)),
      ];
      _isLoadingMore = false;
      _safeNotify();
      return true;
    } catch (_) {
      if (_disposed || requestId != _requestId) return true;

      _isLoadingMore = false;
      _safeNotify();
      return false;
    }
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _requestId++;
    super.dispose();
  }
}
