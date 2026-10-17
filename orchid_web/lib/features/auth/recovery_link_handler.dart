import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_keys.dart';
import '../../core/router/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../../shared/widgets/app_snack_bar.dart';
import 'view/screens/forgot_password_screen.dart';

/// App-lifetime handler for password reset deep links.
///
/// Initialized once from `main()` so the app keeps reacting to
/// `passwordRecovery` auth events even after the splash screen — and with it
/// the startup navigation logic — is gone. Navigation happens through the
/// global [navigatorKey], so it works no matter which screen is on top.
class RecoveryLinkHandler {
  RecoveryLinkHandler._();

  static final RecoveryLinkHandler instance = RecoveryLinkHandler._();

  StreamSubscription<AuthState>? _subscription;
  VoidCallback? _onRecoveryActive;

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

  /// Whether a password recovery session is currently active.
  bool get isRecoveryActive => _active;

  /// Lets the splash screen hook into recovery activation so it can suppress
  /// its own auto-navigation and avoid racing the recovery route.
  void setRecoveryCallback(VoidCallback? callback) {
    _onRecoveryActive = callback;
  }

  void _onAuthStateChange(AuthState state) {
    debugPrint('[RecoveryLinkHandler] event: ${state.event}');
    if (state.event == AuthChangeEvent.signedOut) {
      // Recovery (or any other) flow is finished; allow the next link to work.
      _active = false;
      _clearPersistedRecovery();
      return;
    }

    if (state.event != AuthChangeEvent.passwordRecovery || _active) return;

    _active = true;
    _persistRecoveryActive();
    _onRecoveryActive?.call();
    _pushRecoveryScreen();
  }

  /// Persists that a password recovery session is active so a restart while it
  /// is unfinished (app closed on the recovery screen) can be detected and
  /// resolved back to the login screen, since the one-time reset session
  /// expires.
  void _persistRecoveryActive() {
    unawaited(
      AppPrefs.instance.saveBool(AppPrefKeys.passwordRecoveryActive, true),
    );
  }

  void _clearPersistedRecovery() {
    unawaited(
      AppPrefs.instance.remove(AppPrefKeys.passwordRecoveryActive),
    );
  }

  /// Called when the recovery screen is left without finishing the reset
  /// (back navigation). Clears the persisted flag and signs out the leftover
  /// recovery session so it is never resurrected on a later app launch.
  void markRecoveryAbandoned() {
    _active = false;
    _clearPersistedRecovery();
    unawaited(
      Supabase.instance.client.auth.signOut().catchError((Object _) {}),
    );
  }

  void _onAuthError(Object error, StackTrace stackTrace) {
    if (error is AuthException && error is! AuthRetryableFetchException) {
      _showMessage(
        'this reset link is invalid or has expired, please request a new one',
        isError: true,
      );
      return;
    }
    debugPrint('Auth state error: $error');
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