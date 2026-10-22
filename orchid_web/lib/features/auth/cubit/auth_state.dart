import 'package:equatable/equatable.dart';

import '../data/models/user_profile_model.dart';

/// Possible states for the authentication flow.
enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  authenticating,
  authenticated,
  authenticatingSignup,
  signupSuccess,
  profileIncomplete,
  profileComplete,
  error,
}

/// Snapshot of the auth flow.
class AuthFlowState extends Equatable {
  const AuthFlowState({
    this.status = AuthStatus.initial,
    this.userProfile,
    this.errorMessage,
    this.rememberMe = false,
  });

  final AuthStatus status;
  final UserProfileModel? userProfile;
  final String? errorMessage;
  final bool rememberMe;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated ||
      status == AuthStatus.profileIncomplete ||
      status == AuthStatus.profileComplete;

  bool get isProfileComplete => status == AuthStatus.profileComplete;

  @override
  List<Object?> get props => <Object?>[
    status,
    userProfile,
    errorMessage,
    rememberMe,
  ];
}
