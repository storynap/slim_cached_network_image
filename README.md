# Slim Cached Network Image

A Flutter package that wraps `cached_network_image` to provide a customizable cache manager for potentially better RAM consumption control and default configuration options.

## Features

*   Wraps `CachedNetworkImage` and `CachedNetworkImageProvider`.
*   Provides `SlimCacheManager` with configurable cache settings (max objects, stale period, image dimensions for caching).
*   Allows setting global default cache configurations via `SlimCacheManager.setDefaultConfig`.
*   Allows overriding global configuration per widget instance.

## Getting started

Add the dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  slim_cached_network_image: ^0.0.1 # Use the latest version
  # Or point to the path if developing locally
  # slim_cached_network_image:
  #   path: ../path/to/slim_cached_network_image
```

Then, run `flutter pub get`.

## Usage

### 1. Set Default Configuration (Optional)

You can set global default cache settings, typically in your `main.dart` before running the app. **Important:** Ensure Flutter bindings are initialized before setting the configuration by calling `WidgetsFlutterBinding.ensureInitialized();`.

```dart
import 'package:flutter/material.dart';
import 'package:slim_cached_network_image/slim_cached_network_image.dart';

void main() {
  // Ensure Flutter bindings are initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Configure the default cache settings
  SlimCacheManager.setDefaultConfig(SlimCachedImageConfig( // Use SlimCachedImageConfig
    maxNrOfCacheObjects: 200, // Cache up to 200 images
    stalePeriod: const Duration(days: 14), // Keep images for 14 days
    maxMemWidth: 500, // Cache images with a max width of 500 pixels (disk cache)
    maxMemHeight: 500, // Cache images with a max height of 500 pixels (disk cache)
  ));

  runApp(const MyApp());
}

// ... rest of your app
```

### 2. Using the Widget

Use `SlimCachedNetworkImage` similarly to `CachedNetworkImage`. It will use the global configuration by default.

```dart
import 'package:flutter/material.dart';
import 'package:slim_cached_network_image/slim_cached_network_image.dart';

class MyImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SlimCachedNetworkImage(
      imageUrl: "https://via.placeholder.com/350x150",
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      width: 350,
      height: 150,
      fit: BoxFit.cover,
    );
  }
}
```

### 3. Overriding Configuration Per Widget

You can provide a specific `SlimCacheConfig` to an individual widget instance.

```dart
SlimCachedNetworkImage(
  imageUrl: "https://via.placeholder.com/200",
  cacheConfig: SlimCacheConfig(
    maxWidth: 200, // Specific config for this image
    maxHeight: 200,
    stalePeriod: const Duration(days: 1), // Shorter cache duration
  ),
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  width: 200,
  height: 200,
)
```

### 4. Using the Image Provider

Use `SlimCachedNetworkImageProvider` where an `ImageProvider` is needed, for example, with `Image` or `DecorationImage`.

```dart
Image(
  image: SlimCachedNetworkImageProvider(
    "https://via.placeholder.com/100",
    // Optional: Provide specific config for this provider instance
    // cacheConfig: SlimCacheConfig(maxWidth: 100, maxHeight: 100),
  ),
)

// Or in a BoxDecoration
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: SlimCachedNetworkImageProvider("https://via.placeholder.com/400"),
      fit: BoxFit.cover,
    ),
  ),
)
```
