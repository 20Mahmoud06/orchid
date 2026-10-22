import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import 'auth_brand_header.dart';

/// Centered, scrollable page shell with a soft botanical background.
///
/// Vertically centers [card] on tall screens and lets it scroll naturally when
/// the viewport is short (e.g. a laptop with the browser chrome open). The
/// [leading] widget (typically a back button) is pinned to the top-left of the
/// viewport, outside the centered column.
class AuthWebScaffold extends StatelessWidget {
  final Widget card;
  final Widget? leading;
  final double maxWidth;

  const AuthWebScaffold({
    super.key,
    required this.card,
    this.leading,
    this.maxWidth = 460,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackground()),
          if (leading != null)
            SafeArea(
              child: Padding(padding: const EdgeInsets.all(20), child: leading),
            ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 480;
                final outerPadding = compact ? 20.0 : 32.0;
                final minHeight = math.max(
                  0.0,
                  constraints.maxHeight - outerPadding * 2,
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: outerPadding,
                    vertical: outerPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthBrandHeader(),
                            SizedBox(height: compact ? 26 : 34),
                            card,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          const Positioned(
            top: -130,
            left: -110,
            child: _Glow(color: Colors.white, size: 380, opacity: 0.75),
          ),
          const Positioned(
            bottom: -150,
            right: -120,
            child: _Glow(color: Colors.white, size: 460, opacity: 0.7),
          ),
          Positioned(
            bottom: -70,
            right: -60,
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                AppAssets.bigFlowerSplash,
                width: 340,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Glow({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
