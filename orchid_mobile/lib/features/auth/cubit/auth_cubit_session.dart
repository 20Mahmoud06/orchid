part of 'auth_cubit.dart';

mixin _AuthSessionOps on _AuthCubitBase {
  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Starts listening to Supabase auth state changes.
  /// Call this once from the app root.
  void initAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = _supabase.auth.onAuthStateChange.listen(
      _onAuthStateChange,
      onError: _onAuthError,
    );
  }

  void _onAuthStateChange(AuthState state) {
    final event = state.event;

    if (event == AuthChangeEvent.passwordRecovery) {
      _updateStatus(AuthStatus.passwordRecovery);
      return;
    }

    if (event == AuthChangeEvent.signedIn) {
      _fetchUserProfile();
      return;
    }

    if (event == AuthChangeEvent.signedOut) {
      _userProfile = null;
      _updateStatus(AuthStatus.unauthenticated);
      return;
    }

    if (event == AuthChangeEvent.tokenRefreshed) {
      // Session is still valid; no status change needed.
      return;
    }
  }

  void _onAuthError(Object error, StackTrace stackTrace) {
    if (error is AuthException && error is! AuthRetryableFetchException) {
      _updateStatus(AuthStatus.error);
    }
  }

  // ---------------------------------------------------------------------------
  // Session check (called at app startup)
  // ---------------------------------------------------------------------------

  /// Checks for an existing Supabase session and determines the correct
  /// initial route. Returns:
  ///   - 'login'         if not remembered or no session
  ///   - 'home'          if remembered session + profile complete
  ///   - 'completeProfile' if remembered session + profile incomplete
  ///   - 'forgotPassword' if in password recovery mode
  ///
  /// "Remember me" is checked against local storage first: when the flag is
  /// off the user always lands on the login screen regardless of any silently
  /// restored Supabase session.
  ///
  /// A remembered session with an unreachable profile (transient
  /// network/backend failure) is treated as logged-in and routed to 'home' —
  /// never demoted to 'completeProfile', otherwise an already-complete user is
  /// wrongly forced through the profile completion flow just because a fetch
  /// glitched.
  Future<String> checkInitialAuthState() async {
    final rememberValue = await AppPrefs.instance.getBool(
      AppPrefKeys.rememberMe,
    );
    final session = _supabase.auth.currentSession;

    // remember_me was never explicitly set (null) and a valid session exists —
    // this is a legacy / pre-feature user. Respect the existing session.
    if (rememberValue == null && session != null) {
      _rememberMe = true;
    } else {
      _rememberMe = rememberValue ?? false;
    }

    if (!_rememberMe) {
      _updateStatus(AuthStatus.unauthenticated);
      return 'login';
    }

    if (session == null) {
      _updateStatus(AuthStatus.unauthenticated);
      return 'login';
    }

    _updateStatus(AuthStatus.loading);
    try {
      // Short timeout: on this network PostgREST calls can hang forever. A
      // hung profile fetch must never demote a remembered, authenticated user
      // to the login screen — fall back to home instead.
      await _fetchUserProfile(
        throwOnError: true,
      ).timeout(const Duration(seconds: 3));
      if (_userProfile == null) {
        // Profile row missing — treat as incomplete
        _updateStatus(AuthStatus.profileIncomplete);
        return 'completeProfile';
      }
      if (_userProfile!.isProfileComplete) {
        _updateStatus(AuthStatus.profileComplete);
        return 'home';
      } else {
        _updateStatus(AuthStatus.profileIncomplete);
        return 'completeProfile';
      }
    } catch (error) {
      debugPrint(
        '[checkInitialAuthState] profile resolution failed/hung (error: $error) '
        '- keeping the session and routing home',
      );
      _updateStatus(AuthStatus.profileComplete);
      return 'home';
    }
  }

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  /// Signs the user out and clears local state.
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Local session is cleared regardless.
    }
    _userProfile = null;
    _rememberMe = false;
    await AppPrefs.instance.remove(AppPrefKeys.rememberMe);
    _updateStatus(AuthStatus.unauthenticated);
  }

  /// Permanently deletes the signed-in user's account by invoking the
  /// `delete_account` Supabase Edge Function, then clears all local session
  /// state. Returns `null` on success, or a user-friendly error message on
  /// failure (in which case the account is left untouched).
  Future<String?> deleteAccount() async {
    try {
      final response = await _supabase.functions.invoke('dynamic-endpoint');
      final data = response.data;
      if (data is Map && data['error'] != null) {
        return '${data['error']}';
      }
    } on FunctionException catch (error) {
      final details = error.details;
      debugPrint('[deleteAccount] edge function failed: $error');
      if (details is Map) {
        final message = details['error'] ?? details['message'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
      return AppStrings.genericError;
    } catch (_) {
      return AppStrings.networkError;
    }

    // The account was deleted server-side; the bearer session is now invalid,
    // so clear local state. Call signOut to wipe the persisted session.
    try {
      await _supabase.auth.signOut();
    } catch (_) {
      // Local session is cleared regardless.
    }
    _userProfile = null;
    _rememberMe = false;
    await AppPrefs.instance.remove(AppPrefKeys.rememberMe);
    _updateStatus(AuthStatus.unauthenticated);
    return null;
  }

  /// Updates the persisted "remember me" preference.
  Future<void> setRememberMe(bool value) async {
    _rememberMe = value;
    await AppPrefs.instance.saveBool(AppPrefKeys.rememberMe, value);
  }
}
