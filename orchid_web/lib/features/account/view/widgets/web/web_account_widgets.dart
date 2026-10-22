/// Desktop-first building blocks for the static account pages
/// (About App, Privacy Policy, Terms & Conditions).
///
/// These only own presentation: the colors, copy and content mirror the mobile
/// screens exactly. Sizing uses fixed logical pixels (not `flutter_screenutil`)
/// because on the web the app pins the design size, so these values render 1:1
/// on any monitor — the same convention as the other web pages.
library;

export 'account_web_card_grid.dart';
export 'account_web_scaffold.dart';
export 'web_about_footer.dart';
export 'web_about_info_row.dart';
export 'web_account_footer.dart';
export 'web_account_header_card.dart';
export 'web_orchid_brand.dart';
export 'web_privacy_info_card.dart';
