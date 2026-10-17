import 'package:flutter/material.dart';
import 'slider_direction.dart';

class FadeSlideIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double distance;
  final SlideDirection direction;

  const FadeSlideIn({
    super.key,
    required this.animation,
    required this.child,
    this.distance = 40,
    this.direction = SlideDirection.leftToRight,
  });

  /// Starting offset (fully hidden) for the chosen direction.
  /// At the end of the animation the widget moves to Offset.zero.
  Offset get _startOffset {
    switch (direction) {
      case SlideDirection.leftToRight:
        return Offset(-distance, 0); // enters from the left
      case SlideDirection.rightToLeft:
        return Offset(distance, 0); // enters from the right
      case SlideDirection.topToBottom:
        return Offset(0, -distance); // enters from the top
      case SlideDirection.bottomToTop:
        return Offset(0, distance); // enters from the bottom
    }
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        final start = _startOffset;
        final t = curved.value; // 0 → hidden, 1 → final position

        return Opacity(
          opacity: t,
          child: Transform.translate(
            // Interpolate from start offset to zero.
            offset: Offset(
              start.dx * (1 - t),
              start.dy * (1 - t),
            ),
            child: child,
          ),
        );
      },
    );
  }
}