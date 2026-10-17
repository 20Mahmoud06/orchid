import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';

class OrchidAdminApp extends StatefulWidget {
  const OrchidAdminApp({super.key});

  @override
  State<OrchidAdminApp> createState() => _OrchidAdminAppState();
}

class _OrchidAdminAppState extends State<OrchidAdminApp> {
  late final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      // Never bounce back to login while already there — otherwise the
      // sign-out performed after a rejected login would wipe the error message.
      if (state.session == null && AppRouter.currentRoute != AppRoutes.login) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _routerDelegate.go(AppRoutes.login);
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _routerDelegate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Orchid Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerDelegate: _routerDelegate,
      routeInformationParser: AppRouteParser(),
    );
  }
}
