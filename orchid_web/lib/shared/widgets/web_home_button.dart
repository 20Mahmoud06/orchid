import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../core/app_keys.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_routes.dart';

/// Tracks the name of the top-most route so [WebHomeButtonLayer] knows which
/// screen the shopper is on. Registered in `main.dart` next to the app's other
/// observers.
class WebHomeRouteObserver extends NavigatorObserver {
  WebHomeRouteObserver._();

  static final WebHomeRouteObserver instance = WebHomeRouteObserver._();

  /// Route name of the top-most route; null before the first push or while an
  /// anonymous route (e.g. a dialog) sits on top.
  final ValueNotifier<String?> currentRoute = ValueNotifier<String?>(null);

  final List<Route<dynamic>> _stack = <Route<dynamic>>[];

  void _sync() {
    currentRoute.value = _stack.isEmpty ? null : _stack.last.settings.name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _sync();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _sync();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _sync();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _stack.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) {
      _stack[index] = newRoute;
    } else if (newRoute != null) {
      _stack.add(newRoute);
    }
    _sync();
  }

  /// Clears the tracked stack; only for tests.
  @visibleForTesting
  void reset() {
    _stack.clear();
    currentRoute.value = null;
  }
}

/// Web-only layer that floats a home shortcut above every screen except the
/// home itself and the auth flow, so a shopper can always get back to the
/// storefront even when the browser's back button misbehaves.
///
/// Wrapped around the whole app in `main.dart` (web builds only); the button
/// appears above the Navigator, so it is also reachable while a dialog is open.
class WebHomeButtonLayer extends StatelessWidget {
  final Widget child;

  const WebHomeButtonLayer({super.key, required this.child});

  /// Screens where a home shortcut makes no sense: already home, or mid
  /// sign-in where the storefront is not reachable yet.
  static const hiddenRoutes = <String>{
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.signup,
    AppRoutes.forgotPassword,
    AppRoutes.completeProfile,
    AppRoutes.mainNav,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,
        ValueListenableBuilder<String?>(
          valueListenable: WebHomeRouteObserver.instance.currentRoute,
          builder: (context, route, _) {
            if (route == null || hiddenRoutes.contains(route)) {
              return const SizedBox.shrink();
            }
            return const Positioned(
              right: 20,
              bottom: 20,
              child: WebHomeButton(),
            );
          },
        ),
      ],
    );
  }
}

/// Floating "go home" shortcut (bottom-right). Clears the navigation stack and
/// lands on the storefront home.
class WebHomeButton extends StatelessWidget {
  const WebHomeButton({super.key});

  void _goHome() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.mainNav,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Home',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _goHome,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Ionicons.home_outline,
              size: 22,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
