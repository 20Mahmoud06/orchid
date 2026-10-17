import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/app_keys.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../features/auth/recovery_link_handler.dart';
import '../../../../shared/widgets/orchid_brand_widget.dart';

/// Splash Screen matching pixel-perfect Figma design specifications and automatic navigation.
///
/// Owns all startup navigation decisions (first time / logged in / incomplete
/// profile / password recovery deep links) so `main.dart` stays minimal.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin implements RouteAware {
late final AnimationController _flowerController;
late final Animation<double> _flowerAnimation;
  /// True once a password recovery deep link has been handled while the splash
  /// was resolving its initial route, so auto-navigation never races it.
  bool _enteredPasswordRecovery = false;
  bool _subscribedToRoute = false;

  @override
  void initState() {
    super.initState();
    RecoveryLinkHandler.instance.setRecoveryCallback(() {
      if (mounted) _enteredPasswordRecovery = true;
    });
    _resolveInitialRoute();

    _flowerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _flowerAnimation = CurvedAnimation(
      parent: _flowerController,
      curve: Curves.easeOutCubic,
    );

    _flowerController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_subscribedToRoute && route != null) {
      _subscribedToRoute = true;
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void didPopNext() {
    // The recovery screen pushed on top of us was abandoned (dismissed the
    // dialog and went back without resetting) — don't leave the user stranded
    // on the splash for ever. Send them to login instead.
    if (mounted && _enteredPasswordRecovery) {
      RecoveryLinkHandler.instance.markRecoveryAbandoned();
      _navigateToInitialRoute(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _flowerController.dispose();
    routeObserver.unsubscribe(this);
    RecoveryLinkHandler.instance.setRecoveryCallback(null);
    super.dispose();
  }

  /// Resolve the remembered (or missing) session and navigate exactly once:
  /// remembered login (home) -> main navigation (Home tab); session + missing
  /// profile -> complete profile screen; no remembered session / first open ->
  /// login page. A password recovery deep link that arrives while resolving
  /// takes priority and redirects to the recovery screen instead. A timeout
  /// only guards against a hung resolution so the splash can never leave the
  /// user stuck.
  Future<void> _resolveInitialRoute() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    // A password recovery that was left unfinished in a previous run (the app
    // was closed on the recovery screen) must not be resurrected: its one-time
    // session expires. Clear it and start clean on the login screen.
    final hadInterruptedRecovery = await _consumeInterruptedRecovery();

    String authRoute;
    try {
      authRoute = await AuthCubit.instance
          .checkInitialAuthState()
          .timeout(const Duration(seconds: 5));
    } catch (error) {
      debugPrint(
        '[splash] initial auth resolution failed/hung '
            '(error: $error) - falling back to login',
      );
      authRoute = 'login';
    }
    if (!mounted) return;

    if (_enteredPasswordRecovery) return;

    if (hadInterruptedRecovery) {
      debugPrint(
        '[splash] interrupted password recovery detected - starting at login',
      );
      _navigateToInitialRoute(AppRoutes.login);
      return;
    }

    final route = _mapAuthRoute(authRoute);
    debugPrint('[splash] resolved initial route: $route (authRoute: $authRoute)');

    _navigateToInitialRoute(route);
  }

  /// Detects a password recovery session persisted by a previous app run whose
  /// reset was never completed. When found, the stale recovery session is
  /// signed out and the persisted flag cleared so the app opens normally on the
  /// login screen. Returns `true` when such an interrupted recovery was found.
  ///
  /// A recovery activated during the current run is left untouched so the live
  /// reset flow keeps working.
  Future<bool> _consumeInterruptedRecovery() async {
    if (_enteredPasswordRecovery ||
        RecoveryLinkHandler.instance.isRecoveryActive) {
      return false;
    }

    final active = await AppPrefs.instance.getBool(
      AppPrefKeys.passwordRecoveryActive,
    );
    if (active != true) return false;

    await AppPrefs.instance.remove(AppPrefKeys.passwordRecoveryActive);
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {
      // The local session is cleared regardless of server errors.
    }
    return true;
  }

  String _mapAuthRoute(String authRoute) {
    switch (authRoute) {
      case 'home':
        return AppRoutes.mainNav;
      case 'completeProfile':
        return AppRoutes.completeProfile;
      case 'forgotPassword':
        return AppRoutes.forgotPassword;
      case 'login':
      default:
        return AppRoutes.login;
    }
  }

  void _navigateToInitialRoute(String route) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        top: false,
        child: Stack(
          children: [
            // 1. Bottom Right Big Tulip Flower (Rendered first so background layer is behind text)
            AnimatedBuilder(
              animation: _flowerAnimation,
              builder: (context, child) {
                final progress = _flowerAnimation.value;

                final scale = 0.35 + (0.65 * progress);

                final offsetX = 120.w * (1 - progress);
                final offsetY = 120.h * (1 - progress);

                return Positioned(
                  bottom: -offsetY,
                  right: -offsetX,
                  width: 316.w,
                  height: 457.h,
                  child: Transform.scale(
                    alignment: Alignment.bottomRight,
                    scale: scale,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                AppAssets.bigFlowerSplash,
                fit: BoxFit.contain,
                alignment: Alignment.bottomRight,
              ),
            ),

            // 2. Top Header Brand Logo (Rendered second so text and shadows stay on top)
            Positioned(
              top: 130.h,
              left: 0,
              right: 0,
              child: const OrchidBrandWidget(
                flowerSize: 80,
                orchidFontSize: 64,
                flowerShopFontSize: 24,
                spacing: 4,
                showShadow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}