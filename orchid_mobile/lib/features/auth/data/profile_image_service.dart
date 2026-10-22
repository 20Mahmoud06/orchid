import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Uploads, deletes, and resolves URLs for profile images in the
/// `profile-images` storage bucket.
class ProfileImageService {
  ProfileImageService(this._supabase);

  final SupabaseClient _supabase;

  /// Uploads the selected profile image to the `profile-images` storage
  /// bucket using the `profile-images/{USER_ID}/profile.jpg` path convention.
  /// Returns the storage path on success.
  Future<String> upload({
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
  Future<void> delete(String path) async {
    try {
      await _supabase.storage.from('profile-images').remove([path]);
    } catch (_) {
      // Best-effort: the orphaned file is harmless if removal fails.
    }
  }

  /// Builds the public URL for a profile image stored in the `profile-images`
  /// bucket, or `null` when [path] is empty/missing.
  String? publicUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    return _supabase.storage.from('profile-images').getPublicUrl(path.trim());
  }
}
