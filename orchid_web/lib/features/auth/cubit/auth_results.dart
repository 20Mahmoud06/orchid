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
  const factory EditProfileResult.failure(String message) = EditProfileFailure;
}

class EditProfileSuccess extends EditProfileResult {
  const EditProfileSuccess();
}

class EditProfileFailure extends EditProfileResult {
  final String message;
  const EditProfileFailure(this.message);
}
