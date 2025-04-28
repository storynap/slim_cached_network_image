library slim_cached_network_image;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Default configuration values
const String _defaultCacheKey = 'slimCachedImageData';
const int _defaultMaxCacheObjects = 100;
const Duration _defaultStalePeriod = Duration(days: 1);
const int _defaultMaxMemWidth = 800;
const int _defaultMaxMemHeight = 800;
const int? _defaultMaxDiskWidth = null;
const int? _defaultMaxDiskHeight = null;

/// Custom Cache Manager configuration
class SlimCachedImageConfig {
  final String cacheKey;
  final int maxNrOfCacheObjects;
  final Duration stalePeriod;
  final int? maxMemWidth;
  final int? maxMemHeight;
  final int? maxDiskWidth;
  final int? maxDiskHeight;

  SlimCachedImageConfig({
    this.cacheKey = _defaultCacheKey,
    this.maxNrOfCacheObjects = _defaultMaxCacheObjects,
    this.stalePeriod = _defaultStalePeriod,
    this.maxMemWidth = _defaultMaxMemWidth,
    this.maxMemHeight = _defaultMaxMemHeight,
    this.maxDiskWidth = _defaultMaxDiskWidth,
    this.maxDiskHeight = _defaultMaxDiskHeight,
  });
}

/// Global instance of the custom cache manager configuration
SlimCachedImageConfig _globalCacheConfig = SlimCachedImageConfig();

/// Custom Cache Manager
class SlimCacheManager extends CacheManager with ImageCacheManager {
  static const key = _defaultCacheKey; // Use default initially
  static SlimCacheManager instance = makeSlimCacheManager();

  SlimCacheManager._internal(super.config);

  static makeSlimCacheManager({SlimCachedImageConfig? config}) {
    final effectiveConfig = config ?? _globalCacheConfig;
    late SlimCacheManager newInstance;

    // Compare only core Config properties for instance reuse
    if (instance.config.cacheKey != effectiveConfig.cacheKey ||
        instance.config.maxNrOfCacheObjects != effectiveConfig.maxNrOfCacheObjects ||
        instance.config.stalePeriod != effectiveConfig.stalePeriod) {
      newInstance = SlimCacheManager._internal(
        Config(
          effectiveConfig.cacheKey,
          stalePeriod: effectiveConfig.stalePeriod,
          maxNrOfCacheObjects: effectiveConfig.maxNrOfCacheObjects,
          repo: JsonCacheInfoRepository(databaseName: effectiveConfig.cacheKey),
          fileService: HttpFileService(),
          fileSystem: IOFileSystem(effectiveConfig.cacheKey),
        ),
      );
    }
    return newInstance;
  }

  // Expose effective config for consumers if needed (read-only)
  static SlimCachedImageConfig get currentConfig =>
      _globalCacheConfig; // Or potentially track per-instance config if factory logic changes

  /// Sets the default configuration for the SlimCacheManager.
  /// This should be called once, preferably at app startup.
  static void setDefaultConfig(SlimCachedImageConfig config) {
    _globalCacheConfig = config;
    instance = makeSlimCacheManager(config: config);
  }

  static Future<void> clearCache() async {
    await instance.emptyCache();
  }
}

/// A widget that wraps [CachedNetworkImage] using a custom [SlimCacheManager].
class SlimCachedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BaseCacheManager? cacheManager; // Optional per-widget config
  final Widget Function(BuildContext, ImageProvider)? imageBuilder;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, DownloadProgress)? progressIndicatorBuilder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;
  final Duration? fadeOutDuration;
  final Curve fadeOutCurve;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final Map<String, String>? httpHeaders;
  final bool useOldImageOnUrlChange;
  final Color? color;
  final BlendMode? colorBlendMode;
  final FilterQuality filterQuality;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const SlimCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.cacheManager,
    this.httpHeaders,
    this.imageBuilder,
    this.placeholder,
    this.progressIndicatorBuilder,
    this.errorWidget,
    this.fadeOutDuration = const Duration(milliseconds: 1000),
    this.fadeOutCurve = Curves.easeOut,
    this.fadeInDuration = const Duration(milliseconds: 500),
    this.fadeInCurve = Curves.easeIn,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.useOldImageOnUrlChange = false,
    this.color,
    this.colorBlendMode,
    this.filterQuality = FilterQuality.low,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      cacheManager: cacheManager ?? SlimCacheManager.instance,
      imageUrl: imageUrl,
      httpHeaders: httpHeaders,
      imageBuilder: imageBuilder,
      placeholder: placeholder,
      progressIndicatorBuilder: progressIndicatorBuilder,
      errorWidget: errorWidget,
      fadeOutDuration: fadeOutDuration,
      fadeOutCurve: fadeOutCurve,
      fadeInDuration: fadeInDuration,
      fadeInCurve: fadeInCurve,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      memCacheWidth: memCacheWidth ?? SlimCacheManager.currentConfig.maxMemWidth,
      memCacheHeight: memCacheHeight ?? SlimCacheManager.currentConfig.maxMemHeight,
      maxWidthDiskCache: SlimCacheManager.currentConfig.maxDiskWidth,
      maxHeightDiskCache: SlimCacheManager.currentConfig.maxDiskHeight,
    );
  }
}

/// An [ImageProvider] that wraps [CachedNetworkImageProvider] using a custom [SlimCacheManager].
class SlimCachedNetworkImageProvider extends ImageProvider<SlimCachedNetworkImageProvider> {
  /// The URL from which the image will be fetched.
  final String url;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The HTTP headers that will be used with [http] to fetch image from network.
  final Map<String, String>? headers;

  /// The [CacheManager] that will be used to retrieve the image stream.
  /// Defaults to [SlimCacheManager].
  final BaseCacheManager? cacheManager;

  /// The target image width (pixels). The image will be resized to this width.
  final int? maxWidth;

  /// The target image height (pixels). The image will be resized to this height.
  final int? maxHeight;

  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments must not be null.
  const SlimCachedNetworkImageProvider(
    this.url, {
    this.scale = 1.0,
    this.headers,
    this.cacheManager,
    this.maxWidth,
    this.maxHeight,
  });

  // Internal helper to get the effective cache manager
  BaseCacheManager get _effectiveCacheManager => cacheManager ?? SlimCacheManager.instance;

  // Internal helper to get the effective config
  SlimCachedImageConfig get _effectiveConfig {
    return _globalCacheConfig; // Fallback to global if manager is not SlimCacheManager
  }

  // Internal helper to get effective dimensions
  int? get _effectiveMaxWidth => maxWidth ?? _effectiveConfig.maxMemWidth;
  int? get _effectiveMaxHeight => maxHeight ?? _effectiveConfig.maxMemHeight;

  @override
  Future<SlimCachedNetworkImageProvider> obtainKey(ImageConfiguration configuration) {
    // The key for this provider is simply itself, relying on the == and hashCode
    // implementation to differentiate between providers with different parameters.
    return SynchronousFuture<SlimCachedNetworkImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(SlimCachedNetworkImageProvider key, ImageDecoderCallback decode) {
    assert(key == this);

    // Create the delegate provider to handle loading
    final delegateProvider = CachedNetworkImageProvider(
      key.url,
      scale: key.scale,
      headers: key.headers,
      cacheManager: key._effectiveCacheManager,
      maxWidth: key._effectiveMaxWidth,
      maxHeight: key._effectiveMaxHeight,
    );

    // Delegate the actual loading to the CachedNetworkImageProvider
    // We need to obtain the key from the delegate first
    final ImageStreamCompleter completer = PaintingBinding.instance.imageCache.putIfAbsent(
      delegateProvider, // Use delegate provider as the key for the underlying cache
      () => delegateProvider.loadImage(delegateProvider, decode),
      onError: (exception, stackTrace) {
        // Handle errors appropriately, maybe rethrow or log
        throw exception; // Rethrow for now
      },
    )!;
    return completer;

    // The previous MultiFrameImageStreamCompleter approach is removed
    // as we delegate loading entirely.
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    // Compare all relevant properties for equality
    return other is SlimCachedNetworkImageProvider &&
        other.url == url &&
        other.scale == scale &&
        other.headers == headers && // Headers might need deep comparison if mutable
        other.cacheManager == cacheManager &&
        other.maxWidth == maxWidth &&
        other.maxHeight == maxHeight;
  }

  @override
  int get hashCode => Object.hash(
        url,
        scale,
        headers, // Hash code for map might vary
        cacheManager,
        maxWidth,
        maxHeight,
      );

  @override
  String toString() => '$runtimeType("$url", scale: $scale, maxWidth: $maxWidth, maxHeight: $maxHeight)';
}

// Re-export necessary types from cached_network_image for convenience
// (Consider if all these are needed or if users should import cached_network_image directly)
typedef ImageWidgetBuilder = Widget Function(BuildContext, ImageProvider);
typedef PlaceholderWidgetBuilder = Widget Function(BuildContext, String);
typedef ProgressIndicatorBuilder = Widget Function(BuildContext, String, DownloadProgress);
typedef LoadingErrorWidgetBuilder = Widget Function(BuildContext, String, dynamic);
