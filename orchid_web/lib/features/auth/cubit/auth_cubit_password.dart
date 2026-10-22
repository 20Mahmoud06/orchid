part of 'auth_cubit.dart';

mixin _AuthPasswordOps on _AuthCubitBase {
  /// Verifies the user's current password and then updates it to
  /// [newPassword].
  ///
  /// Returns `null` on success or a user-friendly error message. The session
  /// is left intact — the user stays signed in after changing their password.
  /// Handled edge cases: missing session, wrong current password, new password
  /// too weak, and a new password identical to the existing one.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final email = _supabase.auth.currentUser?.email;
    if (email == null) {
      return 'session expired, please login again';
    }

    // Re-authenticate with the current password to prove the user actually
    // knows it before allowing a change.
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: currentPassword,
      );
    } on AuthException {
      return 'current password is incorrect';
    } catch (_) {
      return AppStrings.networkError;
    }

    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      if (e.code == 'same_password') {
        return 'your new password must be different from your current password';
      }
      if (e.code == 'weak_password') {
        return 'password must be at least 6 characters';
      }
      return _resolveResetPasswordError(e);
    } catch (_) {
      return AppStrings.networkError;
    }
  }

  // ---------------------------------------------------------------------------
  // Forgot Password
  // ---------------------------------------------------------------------------

  /// Sends a password reset email. The caller may first use [emailExists] to
  /// tailor the confirmation message.
  Future<void> sendPasswordResetEmail(String email) async {
    _clearError();
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'com.example.orchid://reset-password/',
      );
    } on AuthException catch (e) {
      throw _resolveAuthError(e);
    } catch (_) {
      throw AppStrings.networkError;
    }
  }

  /// Updates the user's password during a password recovery session.
  Future<void> resetPassword(String newPassword) async {
    _clearError();
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw _resolveResetPasswordError(e);
    } catch (_) {
      throw AppStrings.networkError;
    }
  }

  /// Signs out after a successful password reset and returns to login.
  Future<void> finishPasswordReset() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Local session is cleared regardless of server errors.
    }
    _userProfile = null;
    _updateStatus(AuthStatus.unauthenticated);
  }

  // ---------------------------------------------------------------------------
  // Account lookup
  // ---------------------------------------------------------------------------

  /// Returns `true` when an account exists for [email], `false` when the
  /// account is definitely missing, and `null` when it could not be determined
  /// (edge function not deployed, no network, ...).
  ///
  /// Callers must treat `null` as "unknown" and fall back to the generic flow
  /// so a deployment or network problem never blocks login or password reset.
  Future<bool?> emailExists(String email) => _accounts.emailExists(email);
}
