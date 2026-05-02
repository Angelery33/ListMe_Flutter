import 'package:flutter/material.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/items/item_image_model.dart';
import '../../../../widgets/shared/universal_image.dart';
import 'full_screen_image_viewer.dart';

class DetailImageCarousel extends StatefulWidget {
  final ItemModel item;
  final List<ItemImageModel> images;
  final VoidCallback? onImageUpdated;

  const DetailImageCarousel({
    super.key,
    required this.item,
    required this.images,
    this.onImageUpdated,
  });

  @override
  State<DetailImageCarousel> createState() => _DetailImageCarouselState();
}

class _DetailImageCarouselState extends State<DetailImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<String> get _imagePaths {
    final List<String> paths = [];
    final Set<String> addedPaths = {};

    String? getUniquePath(String? remoteUrl, String? localPath) {
      if (remoteUrl != null && remoteUrl.isNotEmpty) {
        if (!addedPaths.contains(remoteUrl)) {
          addedPaths.add(remoteUrl);
          return remoteUrl;
        }
      }
      if (localPath != null &&
          localPath.isNotEmpty &&
          !localPath.startsWith('http') &&
          !localPath.startsWith('blob:')) {
        if (!addedPaths.contains(localPath)) {
          addedPaths.add(localPath);
          return localPath;
        }
      }
      return null;
    }

    final favoriteImages = widget.images
        .where((img) => img.isFavorite == true)
        .toList();
    final otherImages = widget.images
        .where((img) => img.isFavorite != true)
        .toList();

    for (final img in favoriteImages) {
      final path = getUniquePath(img.remoteImageUrl, img.imageUri);
      if (path != null) paths.add(path);
    }

    for (final img in otherImages) {
      final path = getUniquePath(img.remoteImageUrl, img.imageUri);
      if (path != null) paths.add(path);
    }

    // Only use the item's direct fields as fallback when there are no gallery images
    if (widget.images.isEmpty) {
      final mainPath = getUniquePath(
        widget.item.remoteImageUrl,
        widget.item.imagePath,
      );
      if (mainPath != null) paths.add(mainPath);
    }

    return paths;
  }

  void _showFullScreenImage(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          imagePaths: _imagePaths,
          initialIndex: index,
          onDismiss: () => Navigator.pop(context),
          onSetMain: (path) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Funcionalidad de portada en desarrollo"),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paths = _imagePaths;

    if (paths.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Center(
            child: Icon(
              Icons.image_not_supported,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: paths.length,
            onPageChanged: (idx) => setState(() => _currentIndex = idx),
            itemBuilder: (context, index) {
              final path = paths[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, index),
                child: Hero(
                  tag: index == 0
                      ? 'item_image_${widget.item.id}'
                      : 'item_gallery_$index',
                  child: UniversalImage(path, fit: BoxFit.cover),
                ),
              );
            },
          ),
          if (paths.length > 1)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  paths.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.2, 0.6, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
