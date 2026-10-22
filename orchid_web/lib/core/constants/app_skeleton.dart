import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Centralized skeleton (shimmer) styling for the whole app.
///
/// [configData] is installed once at the app root (see `main.dart`) through
/// `SkeletonizerConfig`, so every skeleton in Orchid shares the same soft pink
/// shimmer and every `SkeletonImage` fades in with the same curve — without
/// repeating the effect at each call site.
abstract class AppSkeleton {
  /// Dim color of the shimmer sweep.
  static const Color baseColor = Color(0xFFF1E2E9);

  /// Bright color of the shimmer sweep.
  static const Color highlightColor = Color(0xFFFBF4F7);

  /// Color used for containers that stand in for real content while loading.
  static const Color containerColor = Color(0xFFF6EAF0);

  /// Color used when a picture cannot be loaded at all.
  static const Color fallbackColor = Color(0xFFF5E4EB);

  static const PaintingEffect _effect = ShimmerEffect(
    baseColor: baseColor,
    highlightColor: highlightColor,
    duration: Duration(milliseconds: 1500),
  );

  static PaintingEffect _resolveEffect(Brightness brightness) => _effect;

  /// Duration used to fade a resolved picture in over its skeleton.
  static const Duration fadeDuration = Duration(milliseconds: 220);

  /// App-wide skeleton theme applied through `SkeletonizerConfig`.
  static const SkeletonizerConfigData configData = SkeletonizerConfigData(
    effectResolver: _resolveEffect,
    containersColor: containerColor,
  );
}
