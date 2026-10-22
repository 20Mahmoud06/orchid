import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_keys.dart';
import '../../core/router/app_routes.dart';
import '../../shared/widgets/app_snack_bar.dart';
import 'view/screens/forgot_password_screen.dart';

/// App-lifetime handler for password reset deep links.
///
/// Initialized once from `main()` so the app keeps reacting to
/// `passwordRecovery` auth events no matter which screen is on top. Navigation
/// happens through the global [navigatorKey].
class RecoveryLinkHandler {
  RecoveryLinkHandler._();

  static final RecoveryLinkHandler instance = RecoveryLinkHandler._();

  StreamSubscription<AuthState>? _subscription;

  /// Guards against duplicate navigation when more than one
  /// `passwordRecovery` event is emitted for the same session.
  bool _active = false;

  /// Starts listening for auth events. Safe to call multiple times.
  void init() {
    _subscription ??= Supabase.instance.client.auth.onAuthStateChange.listen(
      _onAuthStateChange,
      onError: _onAuthError,
    );
  }

  void _onAuthStateChange(AuthState state) {
    if (state.event == AuthChangeEvent.signedOut) {
      // Recovery (or any other) flow is finished; allow the next link to work.
      _active = false;
      return;
    }

    if (state.event != AuthChangeEvent.passwordRecovery || _active) return;

    _active = true;
    _pushRecoveryScreen();
  }

  void _onAuthError(Object error, StackTrace stackTrace) {
    if (error is AuthException && error is! AuthRetryableFetchException) {
      _showMessage(
        'this reset link is invalid or has expired, please request a new one',
        isError: true,
      );
      return;
    }
  }

  void _pushRecoveryScreen() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _pushRecoveryScreen(),
      );
      return;
    }
    navigator.pushNamed(
      AppRoutes.forgotPassword,
      arguments: const ForgotPasswordScreenArgs(recoveryMode: true),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showMessage(message, isError: isError),
      );
      return;
    }
    showAppSnackBarWith(messenger, message, isError: isError);
  }
}
