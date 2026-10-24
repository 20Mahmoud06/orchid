import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'browser_back.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text.dart';
import '../../features/auth/data/auth_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/inspiration/presentation/pages/add_inspiration_page.dart';
import '../../features/inspiration/presentation/pages/inspiration_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/presentation/pages/add_product_page.dart';
import '../../features/products/presentation/pages/edit_product_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../layout/admin_shell.dart';

class AppRouter {
  AppRouter._();

  static String currentRoute = '/';

  static String? parentOf(String location) {
    if (location.startsWith('${AppRoutes.products}/')) {
      return AppRoutes.products;
    }
    if (location.startsWith('${AppRoutes.orders}/')) {
      return AppRoutes.orders;
    }
    if (location.startsWith('${AppRoutes.inspiration}/')) {
      return AppRoutes.inspiration;
    }
    return null;
  }

  static bool isKnown(String location) {
    if (location == AppRoutes.login ||
        location == AppRoutes.dashboard ||
        location == AppRoutes.products ||
        location == AppRoutes.addProduct ||
        location == AppRoutes.orders ||
        location == AppRoutes.inspiration) {
      return true;
    }
    return parentOf(location) != null;
  }

  static String contentLocation(String location, {required bool signedIn}) {
    if (location == '/') {
      return signedIn ? AppRoutes.dashboard : AppRoutes.login;
    }
    return location;
  }
}

class AppRouteParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    final path = routeInformation.uri.path;
    return SynchronousFuture<String>(path.isEmpty ? '/' : path);
  }

  @override
  RouteInformation? restoreRouteInformation(String configuration) {
    return RouteInformation(uri: Uri.parse(configuration));
  }
}

/// Keeps a small stack of locations so browser back/forward and in-app
/// Back buttons stay in sync with the URL. Main sections replace the stack;
/// detail pages are pushed on top of their parent section.
class AppRouterDelegate extends RouterDelegate<String> with ChangeNotifier {
  AppRouterDelegate() {
    _instance = this;
    _stack = <String>['/'];
  }

  static AppRouterDelegate? _instance;

  static AppRouterDelegate? get instance => _instance;

  late final List<String> _stack;
  final Set<String> _appPushedEntries = <String>{};

  String get _location => _stack.last;

  @override
  String get currentConfiguration => _location;

  @override
  Future<void> setInitialRoutePath(String configuration) {
    _applyPlatform(configuration.isEmpty ? '/' : configuration);
    return SynchronousFuture<void>(null);
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    _applyPlatform(configuration.isEmpty ? '/' : configuration);
  }

  @override
  Future<bool> popRoute() async {
    if (_stack.length <= 1) return false;
    final top = _location;
    if (_appPushedEntries.remove(top) && browserBack()) return true;
    _popDirect();
    return true;
  }

  void go(String location) {
    if (_stack.length == 1 && _stack.first == location) return;
    _stack
      ..clear()
      ..add(location);
    _sync();
    notifyListeners();
  }

  void push(String location) {
    if (_location == location) return;
    final parent = AppRouter.parentOf(location);
    if (parent == null) {
      go(location);
      return;
    }
    _stack
      ..clear()
      ..addAll(<String>[parent, location]);
    _appPushedEntries.add(location);
    _sync();
    notifyListeners();
  }

  void pop(BuildContext context) {
    if (_stack.length <= 1) return;
    final top = _location;
    if (_appPushedEntries.remove(top) && browserBack()) return;
    Router.neglect(context, _popDirect);
  }

  void onLoginSuccess() {
    final top = _location;
    if (top == AppRoutes.login || !AppRouter.isKnown(top)) {
      go(AppRoutes.dashboard);
      return;
    }
    final parent = AppRouter.parentOf(top);
    _stack
      ..clear()
      ..addAll(parent == null ? <String>[top] : <String>[parent, top]);
    _sync();
    notifyListeners();
  }

  void _popDirect() {
    if (_stack.length <= 1) return;
    final removed = _stack.removeLast();
    _appPushedEntries.remove(removed);
    _sync();
    notifyListeners();
  }

  void _applyPlatform(String location) {
    if (_location == location) return;

    if (_stack.length > 1 && _stack[_stack.length - 2] == location) {
      _popDirect();
      return;
    }

    final parent = AppRouter.parentOf(location);
    if (parent == null) {
      _stack
        ..clear()
        ..add(location);
    } else {
      if (_location == parent) {
        _appPushedEntries.add(location);
      }
      _stack
        ..clear()
        ..addAll(<String>[parent, location]);
    }
    _sync();
    notifyListeners();
  }

  void _sync() {
    AppRouter.currentRoute = AppRouter.contentLocation(
      _location,
      signedIn: AuthService.isSignedIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final signedIn = AuthService.isSignedIn;
    final location = AppRouter.contentLocation(_location, signedIn: signedIn);

    final Widget child;
    if (!signedIn || location == AppRoutes.login) {
      child = const LoginPage();
    } else {
      child = AdminShell(currentRoute: location, child: _contentFor(location));
    }

    return Navigator(
      pages: <Page<Object?>>[
        MaterialPage<void>(key: const ValueKey<String>('root'), child: child),
      ],
      onDidRemovePage: (_) {},
    );
  }

  Widget _contentFor(String location) {
    if (location == AppRoutes.dashboard) return const DashboardPage();
    if (location == AppRoutes.products) return const ProductsPage();
    if (location == AppRoutes.addProduct) return const AddProductPage();
    if (location == AppRoutes.orders) return const OrdersPage();
    if (location == AppRoutes.inspiration) return const InspirationPage();
    if (location == AppRoutes.addInspiration) {
      return const AddInspirationPage();
    }

    final edit = RegExp(r'^/products/([^/]+)/edit$').firstMatch(location);
    if (edit != null) return EditProductPage(productId: edit.group(1));

    final order = RegExp(r'^/orders/(.+)$').firstMatch(location);
    if (order != null) return OrderDetailsPage(orderCode: order.group(1));

    return _NotFoundPage(location: location);
  }

  @override
  void dispose() {
    if (_instance == this) _instance = null;
    super.dispose();
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.explore_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            CustomText(
              text: 'Page not found: $location',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
