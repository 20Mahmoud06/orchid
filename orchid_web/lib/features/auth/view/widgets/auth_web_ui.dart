/// Reusable, desktop-first building blocks for the Orchid web authentication
/// pages (Login, Sign-up, Forgot password).
///
/// These widgets only own presentation. All authentication logic stays in
/// [AuthCubit]/the screens — nothing here talks to Supabase.
///
/// Sizing uses fixed logical pixels (not `flutter_screenutil`) because on the
/// web the app pins the design size, so these values render 1:1 on any monitor.
library;

export 'web/auth_brand_header.dart';
export 'web/auth_card.dart';
export 'web/auth_error_text.dart';
export 'web/auth_heading.dart';
export 'web/auth_inline_prompt.dart';
export 'web/auth_link.dart';
export 'web/auth_primary_button.dart';
export 'web/auth_text_field.dart';
export 'web/auth_web_scaffold.dart';
