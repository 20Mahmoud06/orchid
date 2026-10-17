import 'package:flutter/material.dart';

/// A calm cross-fade used for web navigation.
///
/// Instead of sliding/zooming a whole new screen in (Flutter's default), the
/// incoming screen gently fades over the outgoing one with a tiny upward
/// drift. Because every screen shares the same background, this reads as the
/// page *content* changing in place - closer to how large browser apps
/// navigate - rather than pushing a new page into view.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.015),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
