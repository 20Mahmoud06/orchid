/// Desktop-first Cart widgets.
///
/// These only own presentation: the colors, copy and behaviour mirror the
/// mobile cart screen exactly; even the checkout navigation lives here so the
/// keyboard/pointer flow matches the mobile app 1:1. Sizing uses fixed logical
/// pixels (not `flutter_screenutil`) so these values render 1:1 on any
/// monitor — the same convention as the other web pages.
library;

export 'web_cart_button.dart';
export 'web_cart_empty_state.dart';
export 'web_cart_item_card.dart';
export 'web_checkout_summary.dart';
export 'web_clear_cart_dialog.dart';
export 'web_quantity_stepper.dart';
