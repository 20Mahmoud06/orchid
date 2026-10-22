part of 'auth_cubit.dart';

mixin _AuthFlowsOps on _AuthCubitBase {
  // ---------------------------------------------------------------------------
  // Sign Up
  // ---------------------------------------------------------------------------

  /// Signs up a new user with email and password.
  /// Returns a [SignUpResult] indicating success or a specific failure.
  Future<SignUpResult> signUp({
    required String email,
    required String password,
  }) async {
    _clearError();
    _updateStatus(AuthStatus.authenticatingSignup);

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        _updateStatus(AuthStatus.error);
        return SignUpResult.failure(
          'account creation failed, please try again',
        );
      }

      // Wait briefly for the database trigger to create the profile row.
      await Future.delayed(const Duration(seconds: 1));

      await _fetchUserProfile();
      _updateStatus(AuthStatus.signupSuccess);
      return SignUpResult.success();
    } on AuthException catch (e) {
      final message = _resolveAuthError(e);
      _errorMessage = message;
      _updateStatus(AuthStatus.error);
      return SignUpResult.failure(message);
    } catch (_) {
      _errorMessage = AppStrings.networkError;
      _updateStatus(AuthStatus.error);
      return SignUpResult.failure(AppStrings.networkError);
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

  /// Signs in an existing user with email and password.
  /// Returns a [LoginResult] indicating success, incomplete profile, or failure.
  /// When [rememberMe] is true the app skips login on subsequent launches.
  Future<LoginResult> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _clearError();
    _updateStatus(AuthStatus.authenticating);

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        _updateStatus(AuthStatus.error);
        return LoginResult.failure('login failed, please try again');
      }

      await _fetchUserProfile();

      await AppPrefs.instance.saveBool(AppPrefKeys.rememberMe, rememberMe);
      _rememberMe = rememberMe;

      if (_userProfile == null || !_userProfile!.isProfileComplete) {
        _updateStatus(AuthStatus.profileIncomplete);
        return LoginResult.incompleteProfile();
      }

      _updateStatus(AuthStatus.profileComplete);
      return LoginResult.success();
    } on AuthException catch (e) {
      final message = await _resolveLoginError(e, email);
      _errorMessage = message;
      _updateStatus(AuthStatus.error);
      return LoginResult.failure(message);
    } catch (_) {
      _errorMessage = AppStrings.networkError;
      _updateStatus(AuthStatus.error);
      return LoginResult.failure(AppStrings.networkError);
    }
  }
}
