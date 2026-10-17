import 'package:flutter/widgets.dart';

/// The real viewport width in logical pixels.
///
/// The web build pins `MediaQuery.size` to the phone design size so
/// `flutter_screenutil` stays 1:1 on large monitors (see `main.dart`). That
/// means `MediaQuery.sizeOf(context)` reports 375 even on a 1440px display, so
/// responsive decisions that cannot use a [LayoutBuilder] — modals in
/// particular — must read the real size from the underlying [FlutterView]
/// instead.
double viewportWidth(BuildContext context) {
  final view = View.of(context);
  return view.physicalSize.width / view.devicePixelRatio;
}

/// The real viewport height in logical pixels (see [viewportWidth]).
double viewportHeight(BuildContext context) {
  final view = View.of(context);
  return view.physicalSize.height / view.devicePixelRatio;
}

/// Whether the real viewport is wide enough for the desktop-first web layout.
///
/// Screens decide their layout from their own constraints; use this for
/// overlays and dialogs pushed above the pinned `MediaQuery`.
bool isWideViewport(BuildContext context) => viewportWidth(context) >= 768;
