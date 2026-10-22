/// Desktop-first building blocks for the Choose Flowers page.
///
/// These only own presentation: the colors, copy and behaviour mirror the
/// mobile screen exactly. Sizing uses fixed logical pixels (not
/// `flutter_screenutil`) because on the web the app pins the design size, so
/// these values render 1:1 on any monitor — the same convention as the other
/// web pages.
library;

export 'web_flower_catalog_message.dart';
export 'web_flower_category_tabs.dart';
export 'web_flower_grid_card.dart';
export 'web_flower_search_bar.dart';
export 'web_view_bouquet_bar.dart';
