import 'package:flutter/material.dart';
import 'package:slim_cached_network_image/slim_cached_network_image.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Optional: Set default configuration for the cache manager
  SlimCacheManager.setDefaultConfig(SlimCachedImageConfig(
    maxNrOfCacheObjects: 150, // Default max objects
    stalePeriod: const Duration(days: 10), // Default stale period
    maxMemWidth: 600, // Default max width for disk cache
    maxMemHeight: 600, // Default max height for disk cache
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SlimCachedNetworkImage Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SlimCachedNetworkImage Example'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Using SlimCachedNetworkImage (Default Config):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: SlimCachedNetworkImage(
                // Using a random image URL from picsum.photos
                imageUrl: "https://picsum.photos/seed/picsum1/300/200",
                placeholder: (context, url) => const SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Using SlimCachedNetworkImage (Specific Config):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: SlimCachedNetworkImage(
                imageUrl: "https://picsum.photos/seed/picsum2/1200/600",
                // Override global config for this specific image
                placeholder: (context, url) => const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.orange),
                width: 1200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Using SlimCachedNetworkImageProvider:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: const SlimCachedNetworkImageProvider(
                      "https://picsum.photos/seed/picsum3/150/150",
                      // Optionally provide config here too
                      // cacheConfig: SlimCacheConfig(maxWidth: 150, maxHeight: 150),
                    ),
                    fit: BoxFit.cover,
                    // Optional: Add error builder for DecorationImage
                    onError: (exception, stackTrace) {
                      // Handle error if needed
                    },
                  ),
                  border: Border.all(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(8),
                ),
                // You could add a child here to show loading/error state for the provider
                // but DecorationImage doesn't directly support placeholders like the widget.
              ),
            ),
          ],
        ),
      ),
    );
  }
}
