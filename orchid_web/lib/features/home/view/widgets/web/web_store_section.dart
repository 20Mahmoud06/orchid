import 'package:flutter/material.dart';

/// Centered content section wrapper with responsive horizontal padding and
/// a max width constraint of 1240 logical pixels.
class WebStoreSection extends StatelessWidget {
  final Widget child;
  final double verticalPadding;

  const WebStoreSection({
    super.key,
    required this.child,
    this.verticalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 1024 ? 48.0 : 20.0;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
