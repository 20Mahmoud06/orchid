import 'dart:io';

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/constants/app_skeleton.dart';

/// Where a [SkeletonImage] reads its picture from.
enum SkeletonImageSource { auto, asset, network, file }

enum _SkeletonImageStatus { loading, loaded, error }

/// A drop-in replacement for `Image.asset` / `Image.network` / `Image.file`
/// that paints a shimmering skeleton bone while the picture is being resolved
/// and then fades the real image in.
///
/// It resolves the [ImageProvider] itself so the loading state is known before
/// the first frame arrives, which means a flower or bouquet photo never flashes
/// as an empty grey box.
class SkeletonImage extends StatefulWidget {
  /// Asset path, network URL or file path, depending on [source].
  final String path;

  /// Where [path] should be read from. Defaults to [SkeletonImageSource.auto]:
  /// `http(s)` URLs load over the network, everything else as a bundled asset.
  final SkeletonImageSource source;

  final BoxFit fit;
  final Alignment alignment;

  /// Optional explicit width. When null the available width is used.
  final double? width;

  /// Optional explicit height. When null the available height is used.
  final double? height;

  /// Clips the skeleton and the picture with this radius.
  final BorderRadiusGeometry? borderRadius;

  /// Color of the box drawn when the picture cannot be loaded and no
  /// [errorWidget] was given. The loading bone itself is painted by
  /// `Skeletonizer` from the app wide [AppSkeleton] theme.
  final Color? placeholderColor;

  /// Size used to draw the loading bone when the surrounding layout is
  /// unbounded (for example inside a scroll view) and no explicit
  /// [width]/[height] was given. Without it the bone collapses to zero height.
  final Size? placeholderSize;

  /// Replaces the plain colored box when the picture fails to load.
  final Widget? errorWidget;

  /// How long the resolved picture takes to fade in over the skeleton.
  final Duration fadeDuration;

  final String? semanticLabel;

  const SkeletonImage({
    super.key,
    required this.path,
    this.source = SkeletonImageSource.auto,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholderColor,
    this.placeholderSize,
    this.errorWidget,
    this.fadeDuration = AppSkeleton.fadeDuration,
    this.semanticLabel,
  });

  @override
  State<SkeletonImage> createState() => _SkeletonImageState();
}

class _SkeletonImageState extends State<SkeletonImage> {
  ImageProvider<Object>? _provider;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  _SkeletonImageStatus _status = _SkeletonImageStatus.loading;

  /// True while a listener is being attached. An already cached picture (or a
  /// cached failure) is reported synchronously from inside `addListener`, which
  /// `didChangeDependencies` runs during build, so the status is assigned
  /// directly instead of scheduling a frame.
  bool _isResolving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveProvider();
  }

  @override
  void didUpdateWidget(covariant SkeletonImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path || oldWidget.source != widget.source) {
      _resolveProvider();
    }
  }

  @override
  void dispose() {
    _detachStream();
    super.dispose();
  }

  /// Resolves [SkeletonImageSource.auto] against the concrete path: `http(s)`
  /// URLs are loaded over the network, anything else as a bundled asset.
  SkeletonImageSource _effectiveSource(String path) {
    if (widget.source != SkeletonImageSource.auto) return widget.source;
    return path.startsWith('http://') || path.startsWith('https://')
        ? SkeletonImageSource.network
        : SkeletonImageSource.asset;
  }

  void _resolveProvider() {
    final path = widget.path.trim();
    if (path.isEmpty) {
      _detachStream();
      _provider = null;
      _status = _SkeletonImageStatus.error;
      return;
    }

    final ImageProvider<Object> provider = switch (_effectiveSource(path)) {
      SkeletonImageSource.asset || SkeletonImageSource.auto => AssetImage(path),
      SkeletonImageSource.network => NetworkImage(path),
      SkeletonImageSource.file => FileImage(File(path)),
    };

    // `didChangeDependencies` also fires on unrelated rebuilds, so the stream is
    // only rebuilt when the picture itself changed — otherwise the shimmer
    // would restart on every rotation or keyboard toggle. Keys are compared by
    // value: every `AssetImage(path)` allocates a fresh key object, so an
    // identity check would never match and would re-shimmer cached pictures.
    final stream = provider.resolve(createLocalImageConfiguration(context));
    if (stream.key == _stream?.key) return;

    _detachStream();
    _provider = provider;
    _stream = stream;
    _status = _SkeletonImageStatus.loading;
    _listener = ImageStreamListener(_onImage, onError: _onError);
    _isResolving = true;
    try {
      stream.addListener(_listener!);
    } finally {
      _isResolving = false;
    }
  }

  void _detachStream() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  void _onImage(ImageInfo image, bool synchronousCall) => _applyStatus(
        _SkeletonImageStatus.loaded,
      );

  void _onError(Object error, StackTrace? stackTrace) =>
      _applyStatus(_SkeletonImageStatus.error);

  void _applyStatus(_SkeletonImageStatus status) {
    if (!mounted || _status == status) return;
    if (_isResolving) {
      _status = status;
      return;
    }
    setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = LayoutBuilder(
      builder: (context, constraints) => switch (_status) {
        _SkeletonImageStatus.loading => _buildBone(constraints),
        _SkeletonImageStatus.loaded => _buildPicture(constraints),
        _SkeletonImageStatus.error => _buildFallback(constraints),
      },
    );

    final borderRadius = widget.borderRadius;
    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius, child: child);
    }
    return child;
  }

  Widget _buildPicture(BoxConstraints constraints) {
    final provider = _provider;
    if (provider == null) return _buildFallback(constraints);

    // The stream already delivered this picture, so `Image` picks it up from
    // the cache synchronously and never re-enters a loading state.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: widget.fadeDuration,
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Image(
        image: provider,
        fit: widget.fit,
        alignment: widget.alignment,
        width: widget.width,
        height: widget.height,
        semanticLabel: widget.semanticLabel,
        gaplessPlayback: true,
        errorBuilder: (context, _, _) => _buildFallback(constraints),
      ),
    );
  }

  Widget _buildBone(BoxConstraints constraints) {
    final size = _boxSize(constraints);
    return Skeletonizer(
      child: Bone(width: size.width, height: size.height),
    );
  }

  Widget _buildFallback(BoxConstraints constraints) {
    // A caller supplied fallback lays itself out against the incoming
    // constraints, so it is handed back untouched (a nested SizedBox would
    // collapse it to zero inside an unbounded scroll view).
    final errorWidget = widget.errorWidget;
    if (errorWidget != null) return errorWidget;

    final size = _boxSize(constraints);
    return Container(
      width: size.width,
      height: size.height,
      color: widget.placeholderColor ?? AppSkeleton.fallbackColor,
    );
  }

  /// Resolves the concrete box the skeleton/fallback should occupy.
  ///
  /// The incoming size wins when it is finite so the bone lines up exactly with
  /// the eventual picture; otherwise the explicit size — or the caller supplied
  /// [SkeletonImage.placeholderSize] — is used, because a bone laid out inside
  /// an unbounded scroll view would otherwise collapse to nothing.
  Size _boxSize(BoxConstraints constraints) {
    final fallback = widget.placeholderSize ?? Size.zero;
    return Size(
      widget.width ??
          (constraints.hasBoundedWidth ? constraints.maxWidth : fallback.width),
      widget.height ??
          (constraints.hasBoundedHeight ? constraints.maxHeight : fallback.height),
    );
  }
}

/// A flat colored box used in place of a picture that could not be loaded.
///
/// It fills the space the parent offers so it never collapses to zero, and
/// falls back to `0` on an unbounded axis instead of asking for an infinite
/// size.
class SkeletonFallbackBox extends StatelessWidget {
  final Color? color;

  const SkeletonFallbackBox({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        width: constraints.hasBoundedWidth ? constraints.maxWidth : 0,
        height: constraints.hasBoundedHeight ? constraints.maxHeight : 0,
        color: color ?? AppSkeleton.fallbackColor,
      ),
    );
  }
}