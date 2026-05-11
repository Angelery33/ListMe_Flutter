import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/items/item_image_model.dart';
import '../../../../widgets/shared/universal_image.dart';
import '../../../../providers/items/item_details_provider.dart';
import 'full_screen_image_viewer.dart';

class _ImageData {
  final String imagePath;
  final String? remoteUrl;
  final int? imageId;

  _ImageData({
    required this.imagePath,
    required this.remoteUrl,
    this.imageId,
  });
}

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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  _ImageData _getImageAtIndex(int index) {
    final allImages = <_ImageData>[];

    final favoriteImages = widget.images
        .where((img) => img.isFavorite == true)
        .toList();
    final otherImages = widget.images
        .where((img) => img.isFavorite != true)
        .toList();

    final seen = <String>{};

    for (final img in favoriteImages) {
      if (img.remoteImageUrl?.isNotEmpty == true) {
        if (!seen.contains(img.remoteImageUrl)) {
          seen.add(img.remoteImageUrl!);
          allImages.add(_ImageData(
            imagePath: img.imageUri ?? '',
            remoteUrl: img.remoteImageUrl,
            imageId: img.id,
          ));
        }
      }
    }

    for (final img in otherImages) {
      if (img.remoteImageUrl?.isNotEmpty == true) {
        if (!seen.contains(img.remoteImageUrl)) {
          seen.add(img.remoteImageUrl!);
          allImages.add(_ImageData(
            imagePath: img.imageUri ?? '',
            remoteUrl: img.remoteImageUrl,
            imageId: img.id,
          ));
        }
      }
    }

    if (widget.images.isEmpty) {
      if (widget.item.remoteImageUrl?.isNotEmpty == true) {
        allImages.add(_ImageData(
          imagePath: widget.item.imagePath ?? '',
          remoteUrl: widget.item.remoteImageUrl,
          imageId: null,
        ));
      }
    }

    return allImages.isNotEmpty && index < allImages.length
        ? allImages[index]
        : _ImageData(imagePath: '', remoteUrl: null);
  }

  void _showFullScreenImage(BuildContext context, int index) {
    final img = _getImageAtIndex(index);

    // En web: modal con tamaño A4 en el centro
    // En móvil: pantalla completa
    if (MediaQuery.of(context).size.width > 840) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          child: Container(
            width: 595,
            height: 842,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                UniversalImage(
                  img.imagePath,
                  remoteImageUrl: img.remoteUrl,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imagePaths: _imagePaths,
            initialIndex: index,
            currentImageId: img.imageId,
            onDismiss: () => Navigator.pop(context),
            onSetFavorite: img.imageId != null
                ? (imageId) => context.read<ItemDetailsProvider>().setFavoriteImage(imageId)
                : null,
          ),
        ),
      );
    }
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: PageView.builder(
              controller: _pageController,
              itemCount: paths.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                final img = _getImageAtIndex(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => _showFullScreenImage(context, index),
                    child: Hero(
                      tag: index == 0
                          ? 'item_image_${widget.item.id}'
                          : 'item_gallery_$index',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: UniversalImage(
                          img.imagePath,
                          remoteImageUrl: img.remoteUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
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
