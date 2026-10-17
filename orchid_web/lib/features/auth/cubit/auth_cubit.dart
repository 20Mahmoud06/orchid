import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_keys.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/user/user_profile.dart';
import '../data/models/user_profile_model.dart';
import 'auth_state.dart';

/// Central cubit for all Supabase Auth operations and auth state management.
///
/// Screens listen to this cubit for state changes and call its methods to
/// perform auth operations.
class AuthCubit extends Cubit<AuthFlowState> {
  AuthCubit() : super(const AuthFlowState());

  static final AuthCubit instance = AuthCubit();

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthStatus _status = AuthStatus.initial;
  UserProfileModel? _userProfile;
  String? _errorMessage;
  StreamSubscription<AuthState>? _authSubscription;
  bool _rememberMe = false;

  AuthStatus get status => _status;
  UserProfileModel? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated ||
      _status == AuthStatus.profileIncomplete ||
      _status == AuthStatus.profileComplete;
  bool get isProfileComplete => _status == AuthStatus.profileComplete;

  void _emit() {
    emit(
      AuthFlowState(
        status: _status,
        userProfile: _userProfile,
        errorMessage: _errorMessage,
        rememberMe: _rememberMe,
      ),
    );
  }

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

  // ---------------------------------------------------------------------------
  // Complete Profile
  // ---------------------------------------------------------------------------

  /// Updates the user's profile row and sets `is_profile_complete = true`
  /// when all required fields are filled.
  Future<CompleteProfileResult> completeProfile({
    required String username,
    required String phone,
    String? whatsapp,
    required String address,
    String? profileImagePath,
  }) async {
    _clearError();
    _updateStatus(AuthStatus.loading);

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'session expired, please login again';
      _updateStatus(AuthStatus.unauthenticated);
      return CompleteProfileResult.failure(_errorMessage!);
    }

    try {
      // Debug logging (safe — no tokens/passwords). Confirms the exact state
      // before the UPDATE so failures can be root-caused from the console.
      debugPrint(
        '[completeProfile] session present: ${_supabase.auth.currentSession != null} '
        '| userId: $userId',
      );

      // Does a profile row already exist for this user?
      // IMPORTANT: This query, like every Supabase call in this flow, used to
      // run WITHOUT a timeout. On this network a PostgREST call can hang
      // forever, which is why the flow silently stopped right here (before the
      // log below ever ran). A 10s timeout converts that permanent hang into a
      // catchable, logged failure below.
      Object? existsError;
      bool rowExists = false;
      try {
        final existing = await _supabase
            .from('profiles')
            .select('id')
            .eq('id', userId)
            .maybeSingle()
            .timeout(const Duration(seconds: 10));
        rowExists = existing != null;
      } catch (error) {
        existsError = error;
      }
      debugPrint(
        '[completeProfile] checkProfileExists => rowExists=$rowExists '
        '| error=$existsError',
      );
      if (existsError != null) {
        debugPrint(
          '[completeProfile] checkProfileExists FAILED - exception type: '
          '${existsError.runtimeType}',
        );
        if (existsError is PostgrestException) {
          debugPrint(
            '[completeProfile]   code=${existsError.code} '
            '| message=${existsError.message} '
            '| details=${existsError.details} '
            '| hint=${existsError.hint}',
          );
        } else if (existsError is TimeoutException) {
          debugPrint(
            '[completeProfile]   → TIMEOUT after 10s (network/backend hang)',
          );
        } else {
          debugPrint('[completeProfile]   message=${existsError.toString()}');
        }
      } else {
        debugPrint(
          '[completeProfile] checkProfileExists OK - row exists: $rowExists',
        );
      }

      final payload = <String, dynamic>{
        'username': username.trim(),
        'phone': phone.trim(),
        if (whatsapp != null && whatsapp.trim().isNotEmpty)
          'whatsapp': whatsapp.trim(),
        'address': address.trim(),
        if (profileImagePath != null && profileImagePath.isNotEmpty)
          'profile_image': profileImagePath,
        'is_profile_complete': true,
      };
      debugPrint(
        '[completeProfile] UPDATE payload keys: ${payload.keys.toList()} '
        '| is_profile_complete=true: ${payload['is_profile_complete'] == true} '
        '| role included: ${payload.containsKey('role')}',
      );

      // Confirm this is an UPDATE (not INSERT) on the user's own row.
      final t0 = DateTime.now();
      debugPrint(
        '[completeProfile] BEFORE profiles UPDATE '
        '| timestamp=${t0.toIso8601String()}',
      );

      // A 10-second timeout turns a hung PostgREST UPDATE into a caught,
      // logged failure instead of a silent, permanent hang. This is the
      // operation the checklist says to isolate — so if the app still stops
      // without reaching AFTER below, the hang is NOT in this UPDATE.
      try {
        await _supabase
            .from('profiles')
            .update(payload)
            .eq('id', userId)
            .timeout(const Duration(seconds: 10));
        debugPrint(
          '[completeProfile] AFTER profiles UPDATE | '
          'timestamp=${DateTime.now().toIso8601String()}',
        );
      } on PostgrestException catch (error) {
        debugPrint(
          '[completeProfile] UPDATE FAILED (PostgrestException) '
          '| timestamp=${DateTime.now().toIso8601String()} '
          '| code=${error.code} '
          '| message=${error.message} '
          '| details=${error.details} '
          '| hint=${error.hint}',
        );
        _errorMessage = 'failed to save your profile, please try again';
        _updateStatus(AuthStatus.error);
        return CompleteProfileResult.failure(_errorMessage!);
      } on TimeoutException catch (error) {
        debugPrint(
          '[completeProfile] UPDATE FAILED (TimeoutException after 10s) '
          '| timestamp=${DateTime.now().toIso8601String()} '
          '| runtimeType=${error.runtimeType}',
        );
        _errorMessage = 'failed to save your profile, please try again';
        _updateStatus(AuthStatus.error);
        return CompleteProfileResult.failure(_errorMessage!);
      } catch (error) {
        debugPrint(
          '[completeProfile] UPDATE FAILED (UNEXPECTED) '
          '| timestamp=${DateTime.now().toIso8601String()} '
          '| runtimeType=${error.runtimeType} '
          '| error=$error',
        );
        rethrow;
      }

      await _fetchUserProfile();

      // Update the global UserProfile singleton.
      if (_userProfile?.username != null) {
        UserProfile.instance.setUsername(_userProfile!.username!);
      }

      _updateStatus(AuthStatus.profileComplete);
      return CompleteProfileResult.success();
    } catch (_) {
      _errorMessage = 'failed to save profile, please try again';
      _updateStatus(AuthStatus.error);
      return CompleteProfileResult.failure(_errorMessage!);
    }
  }

  // ---------------------------------------------------------------------------
  // Edit Profile
  // ---------------------------------------------------------------------------

  /// Persists changes made on the Edit Profile screen to the `profiles` row.
  ///
  /// Unlike the signup-flow endpoints, editing your own profile must NEVER tear
  /// down the live session: a signed-in user editing their details stays
  /// logged in and lands back on the profile screen — no forced logout, no
  /// redirect to login. This mirrors [completeProfile]'s defensive conventions
  /// (10s timeouts so a hanging PostgREST call can't freeze the UI, explicit
  /// error logging, singleton refresh, and a sealed result), but performs a
  /// straight UPDATE of the current user's row without touching auth state.
  Future<EditProfileResult> editProfile({
    required String username,
    required String phone,
    required String whatsapp,
    required String address,
    String? profileImagePath,
  }) async {
    _clearError();
    _updateStatus(AuthStatus.loading);

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'session expired, please login again';
      _updateStatus(AuthStatus.unauthenticated);
      return EditProfileResult.failure(_errorMessage!);
    }

    try {
      debugPrint(
        '[editProfile] session present: ${_supabase.auth.currentSession != null} '
        '| userId: $userId',
      );

      final payload = <String, dynamic>{
        'username': username.trim(),
        // Store phone numbers in canonical digit form — the input formatter
        // adds spaces for display, but the DB keeps clean digits.
        'phone': phone.replaceAll(RegExp(r'[^0-9]'), ''),
        'whatsapp': whatsapp.replaceAll(RegExp(r'[^0-9]'), ''),
        'address': address.trim(),
        if (profileImagePath != null && profileImagePath.isNotEmpty)
          'profile_image': profileImagePath,
      };

      await _supabase
          .from('profiles')
          .update(payload)
          .eq('id', userId)
          .timeout(const Duration(seconds: 10));

      // Refresh the in-memory profile so the profile screen shows the new
      // values immediately after returning to it.
      await _fetchUserProfile();

      // Keep the global singleton in sync.
      if (_userProfile?.username != null) {
        UserProfile.instance.setUsername(_userProfile!.username!);
      }

      // _fetchUserProfile only emits when the status changes, which is not
      // the case here (the user stays on profileComplete). Emit explicitly so
      // listeners (the profile screen) rerender with the fresh row.
      _emit();

      _updateStatus(AuthStatus.profileComplete);
      return EditProfileResult.success();
    } catch (_) {
      _errorMessage = 'failed to save your changes, please try again';
      _updateStatus(AuthStatus.error);
      return EditProfileResult.failure(_errorMessage!);
    }
  }

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
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
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

  /// Uploads the selected profile image to the `profile-images` storage
  /// bucket using the `profile-images/{USER_ID}/profile.jpg` path convention.
  /// Returns the storage path on success.
  Future<String> uploadProfileImage({
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw 'session expired, please login again';
    }

    try {
      final path = '$userId/profile.jpg';
      await _supabase.storage
          .from('profile-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          )
          .timeout(const Duration(seconds: 10));
      return path;
    } on TimeoutException catch (error) {
      debugPrint(
        '[uploadProfileImage] TIMEOUT after 10s | runtimeType=${error.runtimeType}',
      );
      throw 'failed to upload your profile picture, please try again';
    } on StorageException catch (error) {
      debugPrint(
        '[uploadProfileImage] StorageException | '
        'statusCode=${error.statusCode} | message=${error.message}',
      );
      throw 'failed to upload your profile picture, please try again';
    } catch (error) {
      debugPrint(
        '[uploadProfileImage] UNEXPECTED | runtimeType=${error.runtimeType}',
      );
      throw 'failed to upload your profile picture, please try again';
    }
  }

  /// Deletes an uploaded profile image. Best-effort cleanup for an upload that
  /// was orphaned because the profile row update failed afterwards.
  Future<void> deleteProfileImage(String path) async {
    try {
      await _supabase.storage.from('profile-images').remove([path]);
    } catch (_) {
      // Best-effort: the orphaned file is harmless if removal fails.
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
    await AppPrefs.instance.remove(AppPrefKeys.passwordRecoveryActive);
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
  Future<bool?> emailExists(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return null;

    try {
      final response = await _supabase.functions
          .invoke(
            'super-worker',
            body: {'email': trimmed},
          )
          .timeout(const Duration(seconds: 8));
      final data = response.data;
      if (data is Map && data['exists'] is bool) {
        return data['exists'] as bool;
      }
      return null;
    } catch (error) {
      debugPrint('[emailExists] check-email failed: $error');
      return null;
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

  // ---------------------------------------------------------------------------
  // Profile fetching
  // ---------------------------------------------------------------------------

  /// Public wrapper around the private profile fetch. Screens (e.g. the
  /// profile screen) call this on mount so the UI always reflects the latest
  /// row in Supabase, not a possibly stale in-memory copy.
  Future<void> refreshProfile() => _fetchUserProfile();

  /// Builds the public URL for a profile image stored in the `profile-images`
  /// bucket, or `null` when [path] is empty/missing.
  String? getProfileImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    return _supabase.storage.from('profile-images').getPublicUrl(path.trim());
  }

  /// Fetches the current user's profile from the `profiles` table.
  ///
  /// When [throwOnError] is true, I/O failures are rethrown so callers (like
  /// the initial auth check) can distinguish "profile missing" from "profile
  /// unreachable". Otherwise failures are swallowed and the current status is
  /// kept.
  Future<void> _fetchUserProfile({bool throwOnError = false}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        _userProfile = UserProfileModel.fromJson(data);

        // Keep the global singleton in sync.
        if (_userProfile!.username != null &&
            _userProfile!.username!.isNotEmpty) {
          UserProfile.instance.setUsername(_userProfile!.username!);
        }

        if (_userProfile!.isProfileComplete) {
          _updateStatus(AuthStatus.profileComplete);
        } else {
          _updateStatus(AuthStatus.profileIncomplete);
        }
      } else {
        _userProfile = null;
        _updateStatus(AuthStatus.profileIncomplete);
      }
      _emit();
    } catch (_) {
      // Network or table error — keep the current status.
      if (throwOnError) rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Error resolution
  // ---------------------------------------------------------------------------

  /// Maps [AuthException] codes/messages to user-friendly Orchid-style messages
  /// for sign-up and login errors.
  String _resolveAuthError(AuthException e) {
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
  Future<String> _resolveLoginError(AuthException e, String email) async {
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
      return _resolveAuthError(e);
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
  String _resolveResetPasswordError(AuthException e) {
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

    return _resolveAuthError(e);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _updateStatus(AuthStatus newStatus) {
    if (_status == newStatus) return;
    _status = newStatus;
    _emit();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    _emit();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}

// ---------------------------------------------------------------------------
// Result types — clean return values that screens can pattern-match on.
// ---------------------------------------------------------------------------

/// Result of a sign-up attempt.
sealed class SignUpResult {
  const SignUpResult();

  const factory SignUpResult.success() = SignUpSuccess;
  const factory SignUpResult.failure(String message) = SignUpFailure;
}

class SignUpSuccess extends SignUpResult {
  const SignUpSuccess();
}

class SignUpFailure extends SignUpResult {
  final String message;
  const SignUpFailure(this.message);
}

/// Result of a login attempt.
sealed class LoginResult {
  const LoginResult();

  const factory LoginResult.success() = LoginSuccess;
  const factory LoginResult.incompleteProfile() = LoginIncompleteProfile;
  const factory LoginResult.failure(String message) = LoginFailure;
}

class LoginSuccess extends LoginResult {
  const LoginSuccess();
}

class LoginIncompleteProfile extends LoginResult {
  const LoginIncompleteProfile();
}

class LoginFailure extends LoginResult {
  final String message;
  const LoginFailure(this.message);
}

/// Result of a complete-profile attempt.
sealed class CompleteProfileResult {
  const CompleteProfileResult();

  const factory CompleteProfileResult.success() = CompleteProfileSuccess;
  const factory CompleteProfileResult.failure(String message) =
      CompleteProfileFailure;
}

class CompleteProfileSuccess extends CompleteProfileResult {
  const CompleteProfileSuccess();
}

class CompleteProfileFailure extends CompleteProfileResult {
  final String message;
  const CompleteProfileFailure(this.message);
}

/// Result of an edit-profile attempt.
sealed class EditProfileResult {
  const EditProfileResult();

  const factory EditProfileResult.success() = EditProfileSuccess;
  const factory EditProfileResult.failure(String message) =
      EditProfileFailure;
}

class EditProfileSuccess extends EditProfileResult {
  const EditProfileSuccess();
}

class EditProfileFailure extends EditProfileResult {
  final String message;
  const EditProfileFailure(this.message);
}
