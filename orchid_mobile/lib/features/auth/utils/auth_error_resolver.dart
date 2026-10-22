import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';

/// Maps Supabase auth errors to user-friendly Orchid-style messages.
class AuthErrorResolver {
  AuthErrorResolver({required this.emailExists});

  final Future<bool?> Function(String email) emailExists;

  /// Maps [AuthException] codes/messages to user-friendly messages for
  /// sign-up and login errors.
  String resolveAuthError(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid email or password')) {
      return 'invalid email or password';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'this email is already registered';
    }
    if (msg.contains('email') && msg.contains('valid')) {
      return 'please enter a valid email address';
    }
    if (msg.contains('password') &&
        (msg.contains('short') || msg.contains('at least'))) {
      return 'password must be at least 6 characters';
    }
    if (msg.contains('rate limit') || msg.contains('too many')) {
      return 'too many attempts, please try again later';
    }
    if (msg.contains('network') || msg.contains('socket')) {
      return AppStrings.networkError;
    }

    // Fall through to a generic safe message.
    return AppStrings.genericError;
  }

  /// Resolves a login [AuthException]. For login rejections it asks the
  /// `super-worker` edge function whether the address is registered so the
  /// message can distinguish a missing account from a wrong password. When the
  /// check is unavailable it falls back to the generic message.
  Future<String> resolveLoginError(AuthException e, String email) async {
    final msg = e.message.toLowerCase();
    debugPrint(
      '[login] auth error -> statusCode=${e.statusCode} code=${e.code} '
      'message="$msg"',
    );

    // Detect a rejected login by the HTTP status/error code in addition to the
    // message, because the message wording varies across GoTrue versions.
    final isLoginRejection =
        e.statusCode == '400' || e.statusCode == '401' || e.statusCode == '403';

    if (!isLoginRejection &&
        !msg.contains('invalid login credentials') &&
        !msg.contains('invalid email or password')) {
      return resolveAuthError(e);
    }

    final exists = await emailExists(email);
    if (exists == false) {
      return 'no account found with this email address, please sign up';
    }
    if (exists == true) {
      return 'incorrect password, please try again';
    }
    return 'invalid email or password';
  }

  /// Maps [AuthException] for password reset/update operations.
  String resolveResetPasswordError(AuthException e) {
    if (e.code == 'same_password') {
      return 'your new password must be different from your current password';
    }
    if (e.code == 'weak_password') {
      return 'password must be at least 6 characters';
    }

    final statusCode = e.statusCode;
    if (statusCode == '400' || statusCode == '401' || statusCode == '403') {
      return 'this reset link is invalid or has expired, please request a new one';
    }

    return resolveAuthError(e);
  }
}
