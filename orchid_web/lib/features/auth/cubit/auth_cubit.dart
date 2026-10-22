import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_keys.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/user/user_profile.dart';
import '../data/auth_account_service.dart';
import '../data/models/user_profile_model.dart';
import '../data/profile_image_service.dart';
import '../utils/auth_error_resolver.dart';
import 'auth_results.dart';
import 'auth_state.dart';

export 'auth_results.dart';

part 'auth_cubit_authentication.dart';
part 'auth_cubit_password.dart';
part 'auth_cubit_profile.dart';
part 'auth_cubit_session.dart';

/// Shared state and helpers for [AuthCubit].
///
/// Operations are split into responsibility mixins in part files, keeping the
/// public API and runtime behavior identical.
abstract class _AuthCubitBase extends Cubit<AuthFlowState> {
  _AuthCubitBase() : super(const AuthFlowState());

  final SupabaseClient _supabase = Supabase.instance.client;

  AuthStatus _status = AuthStatus.initial;
  UserProfileModel? _userProfile;
  String? _errorMessage;
  bool _rememberMe = false;

  late final AuthAccountService _accounts = AuthAccountService(_supabase);
  late final ProfileImageService _profileImages = ProfileImageService(
    _supabase,
  );
  late final AuthErrorResolver _errorResolver = AuthErrorResolver(
    emailExists: _accounts.emailExists,
  );

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
  // Profile fetching (implemented in _AuthProfileOps)
  // ---------------------------------------------------------------------------

  Future<void> _fetchUserProfile({bool throwOnError = false});

  // ---------------------------------------------------------------------------
  // Error resolution
  // ---------------------------------------------------------------------------

  String _resolveAuthError(AuthException e) =>
      _errorResolver.resolveAuthError(e);

  Future<String> _resolveLoginError(AuthException e, String email) =>
      _errorResolver.resolveLoginError(e, email);

  String _resolveResetPasswordError(AuthException e) =>
      _errorResolver.resolveResetPasswordError(e);

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
}

/// Central cubit for all Supabase Auth operations and auth state management.
///
/// Screens listen to this cubit for state changes and call its methods to
/// perform auth operations.
class AuthCubit extends _AuthCubitBase
    with _AuthSessionOps, _AuthFlowsOps, _AuthProfileOps, _AuthPasswordOps {
  AuthCubit();

  static final AuthCubit instance = AuthCubit();
}
