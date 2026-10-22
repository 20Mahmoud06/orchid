import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../cubit/auth_cubit.dart';
import '../widgets/auth_web_ui.dart';

/// Web replacement for the (mobile) splash screen: immediately resolves the
/// remembered session and routes exactly once to login / main navigation /
/// profile completion — so a returning user stays logged in after a refresh,
/// and a new visitor lands straight on the auth screen with no splash.
class WebStartupGate extends StatefulWidget {
  const WebStartupGate({super.key});

  @override
  State<WebStartupGate> createState() => _WebStartupGateState();
}

class _WebStartupGateState extends State<WebStartupGate> {
  @override
  void initState() {
    super.initState();
    _resolveRoute();
  }

  Future<void> _resolveRoute() async {
    String authRoute;
    try {
      authRoute = await AuthCubit.instance.checkInitialAuthState().timeout(
        const Duration(seconds: 8),
      );
    } catch (_) {
      authRoute = 'login';
    }
    if (!mounted) return;

    final route = switch (authRoute) {
      'home' => AppRoutes.mainNav,
      'completeProfile' => AppRoutes.completeProfile,
      'forgotPassword' => AppRoutes.forgotPassword,
      _ => AppRoutes.login,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Minimal Orchid-branded loading view shown only while the remembered
    // session is being resolved — never the mobile splash animation.
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthBrandHeader(),
            SizedBox(height: 30),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
