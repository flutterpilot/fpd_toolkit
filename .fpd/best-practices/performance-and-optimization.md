---
title: Performance and Optimization
description: This rule focuses on performance and optimization techniques for Flutter applications. It provides best practices for handling large lists efficiently with ListView.builder and infinite scrolling, managing memory through image caching and optimization, and improving build performance by using const constructors and separating widgets.
alwaysApply: false
globs:
  - '**/lib/**'
  - '**/pubspec.yaml'
  - '**/*.dart'
  - '**/analysis_options.yaml'
---
# Performance and Optimization

## Handling Large Lists

### ListView.builder with optimizations:
```dart
// widgets/optimized_list_view.dart
class OptimizedListView<T> extends StatefulWidget {
  const OptimizedListView({
    required this.items,
    required this.itemBuilder,
    this.separatorBuilder,
    this.onRefresh,
    this.onLoadMore,
    this.hasMoreData = false,
    super.key,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMoreData;

  @override
  State<OptimizedListView<T>> createState() => _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends State<OptimizedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        widget.hasMoreData &&
        !_isLoadingMore &&
        widget.onLoadMore != null) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    await widget.onLoadMore!();
    setState(() => _isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.separated(
      controller: _scrollController,
      itemCount: widget.items.length + (widget.hasMoreData ? 1 : 0),
      separatorBuilder: widget.separatorBuilder ?? 
          (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= widget.items.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

## Memory Management

### Image caching and optimization:
```dart
// utils/image_cache_manager.dart
class ImageCacheManager {
  static const int _maxCacheSize = 100;
  static final Map<String, ui.Image> _cache = <String, ui.Image>{};
  static final List<String> _cacheOrder = <String>[];

  static Future<ImageProvider> getOptimizedImage(String url) async {
    // For remote URLs, use CachedNetworkImage
    if (url.startsWith('http')) {
      return CachedNetworkImageProvider(
        url,
        cacheManager: DefaultCacheManager(),
        maxWidth: 800, // Limit resolution
        maxHeight: 600,
      );
    }

    // For local assets
    return AssetImage(url);
  }

  static void _addToCache(String key, ui.Image image) {
    if (_cache.length >= _maxCacheSize) {
      final oldestKey = _cacheOrder.removeAt(0);
      _cache.remove(oldestKey);
    }

    _cache[key] = image;
    _cacheOrder.add(key);
  }

  static void clearCache() {
    _cache.clear();
    _cacheOrder.clear();
  }
}

// widgets/optimized_image.dart
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => 
          placeholder ?? const CircularProgressIndicator(),
        errorWidget: (context, url, error) => 
          errorWidget ?? const Icon(Icons.error),
        memCacheWidth: width?.toInt(),
        memCacheHeight: height?.toInt(),
      );
    }

    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
    );
  }
}
```

## Build Optimization

### Const constructors and widget separation:
```dart
// ✅ Correct - Using const and separation
class UserCard extends StatelessWidget {
  const UserCard({
    required this.user,
    required this.onTap,
    super.key,
  });

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16), // const
          child: Row(
            children: [
              UserAvatar(user: user), // Separate widget
              const SizedBox(width: 16), // const
              Expanded(
                child: UserInfo(user: user), // Separate widget
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundImage: NetworkImage(user.avatarUrl),
    );
  }
}

class UserInfo extends StatelessWidget {
  const UserInfo({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
``` 