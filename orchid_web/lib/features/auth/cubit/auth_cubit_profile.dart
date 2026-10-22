part of 'auth_cubit.dart';

mixin _AuthProfileOps on _AuthCubitBase {
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

      // A 10-second timeout turns a hung PostgREST UPDATE into a catchable
      // failure instead of a silent, permanent hang.
      try {
        await _supabase
            .from('profiles')
            .update(payload)
            .eq('id', userId)
            .timeout(const Duration(seconds: 10));
      } on PostgrestException {
        _errorMessage = 'failed to save your profile, please try again';
        _updateStatus(AuthStatus.error);
        return CompleteProfileResult.failure(_errorMessage!);
      } on TimeoutException {
        _errorMessage = 'failed to save your profile, please try again';
        _updateStatus(AuthStatus.error);
        return CompleteProfileResult.failure(_errorMessage!);
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
  /// (10s timeouts so a hanging PostgREST call can't freeze the UI, singleton
  /// refresh, and a sealed result), but performs a straight UPDATE of the
  /// current user's row without touching auth state.
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

  /// Uploads the selected profile image to the `profile-images` storage
  /// bucket using the `profile-images/{USER_ID}/profile.jpg` path convention.
  /// Returns the storage path on success.
  Future<String> uploadProfileImage({
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) => _profileImages.upload(bytes: bytes, contentType: contentType);

  /// Deletes an uploaded profile image. Best-effort cleanup for an upload that
  /// was orphaned because the profile row update failed afterwards.
  Future<void> deleteProfileImage(String path) => _profileImages.delete(path);

  // ---------------------------------------------------------------------------
  // Profile fetching
  // ---------------------------------------------------------------------------

  /// Public wrapper around the private profile fetch. Screens (e.g. the
  /// profile screen) call this on mount so the UI always reflects the latest
  /// row in Supabase, not a possibly stale in-memory copy.
  Future<void> refreshProfile() => _fetchUserProfile();

  /// Builds the public URL for a profile image stored in the `profile-images`
  /// bucket, or `null` when [path] is empty/missing.
  String? getProfileImageUrl(String? path) => _profileImages.publicUrl(path);

  /// Fetches the current user's profile from the `profiles` table.
  ///
  /// When [throwOnError] is true, I/O failures are rethrown so callers (like
  /// the initial auth check) can distinguish "profile missing" from "profile
  /// unreachable". Otherwise failures are swallowed and the current status is
  /// kept.
  @override
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
}
