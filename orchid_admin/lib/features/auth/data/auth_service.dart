import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase.dart';

class AuthService {
  AuthService._();

  static String? _adminName;

  static bool get isSignedIn =>
      supabase.auth.currentSession != null && _adminName != null;

  static String get adminName => _adminName ?? 'Admin';

  static String get adminFirstName {
    final parts = adminName.trim().split(RegExp(r'\s+'));
    return parts.first;
  }

  static String get adminInitials {
    final parts = adminName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    return parts.isEmpty ? 'A' : parts;
  }

  /// Restores the signed-in admin profile after an app restart.
  /// Signs out if the account is not an admin.
  static Future<void> restoreSession() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await _loadProfile(user.id, user.email);
    } catch (_) {
      await signOut();
    }
  }

  static Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw const AuthFailure('Email and password are required.');
    }
    if (!trimmedEmail.contains('@') || trimmedEmail.contains(' ')) {
      throw const AuthFailure('Please enter a valid email address.');
    }

    try {
      final response = await supabase.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('Sign in failed. Please try again.');
      }
      try {
        await _loadProfile(user.id, user.email);
      } catch (_) {
        // Never leave a non-admin session active.
        await signOut();
        rethrow;
      }
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyAuthMessage(error));
    } catch (_) {
      throw const AuthFailure(
        'Something went wrong. Check your internet connection and try again.',
      );
    }
  }

  static Future<void> _loadProfile(String userId, String? email) async {
    Map<String, dynamic>? profile;
    try {
      profile = await supabase
          .from('profiles')
          .select('username, phone, role')
          .eq('id', userId)
          .maybeSingle();
    } catch (_) {
      throw const AuthFailure(
        'We could not load your account details. Please try again.',
      );
    }

    if (profile == null) {
      _adminName = null;
      throw const AuthFailure(
        'This account has no profile yet. Ask the store owner to set it up.',
      );
    }

    final role = profile['role'] as String?;
    if (role != 'admin') {
      _adminName = null;
      throw const AuthFailure(
        "This email doesn't have admin access. Use an admin account to sign in.",
      );
    }

    final username = (profile['username'] as String?)?.trim();
    _adminName = (username != null && username.isNotEmpty)
        ? username
        : (email ?? 'Admin');
  }

  /// Translates raw Supabase auth errors into messages a person can act on.
  static String _friendlyAuthMessage(AuthException error) {
    final code = error.code ?? '';
    final message = error.message.toLowerCase();

    if (error is AuthRetryableFetchException) {
      return 'Cannot reach the server. Check your internet connection and try again.';
    }

    // Supabase returns the same code/message whether the email is unknown or
    // the password is wrong (it hides account existence on purpose).
    if (code == 'user_not_found' ||
        code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return 'Invalid email or password. Check your details and try again.';
    }

    if (code == 'email_not_confirmed' || message.contains('email not confirmed')) {
      return 'Please confirm your email address before signing in.';
    }

    if (code == 'user_banned' || message.contains('banned')) {
      return 'This account has been suspended. Contact the store owner.';
    }

    if (code.contains('rate_limit') ||
        error.statusCode == '429' ||
        message.contains('rate limit') ||
        message.contains('too many request')) {
      return 'Too many attempts. Please wait a minute and try again.';
    }

    if (message.contains('password') &&
        (message.contains('at least') || message.contains('characters'))) {
      return 'Password must be at least 6 characters.';
    }

    if (message.contains('invalid') && message.contains('email')) {
      return 'Please enter a valid email address.';
    }

    if (code == 'session_expired' || message.contains('refresh token')) {
      return 'Your session expired. Please sign in again.';
    }

    return 'Sign in failed. Please check your details and try again.';
  }

  static Future<void> signOut() async {
    _adminName = null;
    try {
      await supabase.auth.signOut();
    } catch (_) {
      // Ignore network errors on sign-out; the local session is cleared anyway.
    }
  }
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
