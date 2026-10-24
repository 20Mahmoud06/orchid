import '../../../../core/supabase/supabase.dart';
import '../../../orders/data/repositories/orders_repository.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../products/data/repositories/products_repository.dart';
import '../../../../core/time/date_range.dart';
import '../../domain/models/dashboard_metrics.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.overview,
    required this.recentOrders,
    required this.productCount,
  });

  final DashboardOverview overview;
  final List<Order> recentOrders;
  final int productCount;
}

/// Data access for the dashboard.
///
/// Order totals and trend buckets are aggregated by the
/// `dashboard_order_buckets` RPC so All Time never downloads the full order
/// history. Recent orders are a separate, limited page and the product count
/// is a HEAD count.
class DashboardRepository {
  DashboardRepository({
    OrdersRepository? ordersRepository,
    ProductsRepository? productsRepository,
  }) : _ordersRepository = ordersRepository ?? OrdersRepository(),
       _productsRepository = productsRepository ?? ProductsRepository();

  final OrdersRepository _ordersRepository;
  final ProductsRepository _productsRepository;

  Future<DashboardSnapshot> load(DateRange range, {int recentLimit = 5}) async {
    final results = await Future.wait<Object>([
      _loadOverview(range),
      _ordersRepository.getRecentOrders(
        startUtc: range.startUtc,
        endUtc: range.endUtc,
        limit: recentLimit,
      ),
      _productsRepository.countProducts(),
    ]);

    return DashboardSnapshot(
      overview: results[0] as DashboardOverview,
      recentOrders: results[1] as List<Order>,
      productCount: results[2] as int,
    );
  }

  Future<List<Order>> loadMoreRecentOrders(
    DateRange range, {
    required int offset,
    int limit = 5,
  }) {
    return _ordersRepository.getRecentOrders(
      startUtc: range.startUtc,
      endUtc: range.endUtc,
      limit: limit,
      offset: offset,
    );
  }

  Future<DashboardOverview> _loadOverview(DateRange range) async {
    final params = <String, dynamic>{'p_bucket': range.grouping.dbValue};
    final startUtc = range.startUtc;
    final endUtc = range.endUtc;
    if (startUtc != null) {
      params['p_start'] = startUtc.toIso8601String();
    }
    if (endUtc != null) {
      params['p_end'] = endUtc.toIso8601String();
    }

    final response = await supabase.rpc(
      'dashboard_order_buckets',
      params: params,
    );
    final rows = response is List ? response : const <dynamic>[];
    return DashboardOverview.fromRows(rows, range: range);
  }
}
