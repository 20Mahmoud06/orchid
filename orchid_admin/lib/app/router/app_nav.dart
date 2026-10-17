import 'package:flutter/material.dart';

import 'app_router.dart';

/// Navigation entry points backed by [AppRouterDelegate].
///
/// Main sections use [go] (replaces the stack, one history entry per visit);
/// detail screens use [push] (stacked on their parent section); [pop] walks
/// back and keeps the browser history clean.
class AppNav {
  AppNav._();

  static void go(BuildContext context, String location) {
    AppRouterDelegate.instance?.go(location);
  }

  static void push(BuildContext context, String location) {
    AppRouterDelegate.instance?.push(location);
  }

  /// Navigates without creating a browser history entry (used for login
  /// completion and logout, where going "back" would re-enter a dead state).
  static void replace(BuildContext context, String location) {
    final delegate = AppRouterDelegate.instance;
    if (delegate == null) return;
    Router.neglect(context, () => delegate.go(location));
  }

  static void pop(BuildContext context) {
    AppRouterDelegate.instance?.pop(context);
  }

  static void completeLogin(BuildContext context) {
    final delegate = AppRouterDelegate.instance;
    if (delegate == null) return;
    Router.neglect(context, delegate.onLoginSuccess);
  }
}
