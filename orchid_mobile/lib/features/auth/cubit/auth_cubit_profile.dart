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
