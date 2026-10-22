import 'package:supabase_flutter/supabase_flutter.dart';

/// Account lookup operations backed by Supabase Edge Functions.
class AuthAccountService {
  AuthAccountService(this._supabase);

  final SupabaseClient _supabase;

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
          .invoke('super-worker', body: {'email': trimmed})
          .timeout(const Duration(seconds: 8));
      final data = response.data;
      if (data is Map && data['exists'] is bool) {
        return data['exists'] as bool;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
