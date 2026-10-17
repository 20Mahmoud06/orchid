import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/supabase/app_env.dart';
import 'core/time/egypt_time.dart';
import 'features/auth/data/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initTimeZones();

  if (!AppEnv.isConfigured) {
    throw StateError(
      'Supabase is not configured. Run with:\n'
      'flutter run -d chrome '
      '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }

  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    publishableKey: AppEnv.supabaseAnonKey,
  );
  await AuthService.restoreSession();

  runApp(const OrchidAdminApp());
}
