import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/responsive_provider.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/items/item_image_model.dart';
import '../../../../widgets/shared/universal_image.dart';
import '../../../../providers/items/item_details_provider.dart';
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

  /// Builds a deduplicated, ordered list of ViewerImageData from gallery images.
  /// Favorites first, then the rest. Falls back to item fields if no gallery images.
  List<ViewerImageData> _buildViewerImages() {
    if (widget.images.isEmpty) {
      final remoteUrl = widget.item.remoteImageUrl;
      final localPath = widget.item.imagePath;
      final path = (remoteUrl?.isNotEmpty == true) ? remoteUrl! : (localPath ?? '');
      if (path.isEmpty) return [];
      return [ViewerImageData(path: path, remoteUrl: remoteUrl, isFavorite: true)];
    }

    final seen = <String>{};
    final result = <ViewerImageData>[];

    void addImage(ItemImageModel img) {
      final remoteUrl = img.remoteImageUrl;
      final localPath = img.imageUri;
      final key = remoteUrl?.isNotEmpty == true ? remoteUrl! : (localPath ?? '');
      if (key.isEmpty || seen.contains(key)) return;
      seen.add(key);
      result.add(ViewerImageData(
        path: localPath ?? '',
        remoteUrl: remoteUrl,
        imageId: img.id,
        isFavorite: img.isFavorite,
      ));
    }

    // Favorites first
    for (final img in widget.images.where((i) => i.isFavorite)) {
      addImage(img);
    }
    for (final img in widget.images.where((i) => !i.isFavorite)) {
      addImage(img);
    }

    return result;
  }

  void _showFullScreenImage(BuildContext context, int index) {
    final viewerImages = _buildViewerImages();
    if (viewerImages.isEmpty) return;

    if (MediaQuery.of(context).size.width > 840) {
      _showWebModal(context, viewerImages, index);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            images: viewerImages,
            initialIndex: index,
            onDismiss: () => Navigator.pop(context),
            onSetFavorite: (imageId) =>
                context.read<ItemDetailsProvider>().setFavoriteImage(imageId),
          ),
        ),
      );
    }
  }

  void _showWebModal(
      BuildContext context, List<ViewerImageData> viewerImages, int index) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          width: 595,
          height: 842,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: FullScreenImageViewer(
            images: viewerImages,
            initialIndex: index,
            onDismiss: () => Navigator.pop(ctx),
            onSetFavorite: (imageId) =>
                context.read<ItemDetailsProvider>().setFavoriteImage(imageId),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewerImages = _buildViewerImages();
    final responsive = context.watch<ResponsiveProvider>();

    if (viewerImages.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.5),
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

    if (!responsive.isCompact) {
      return _buildVerticalGallery(context, viewerImages);
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: PageView.builder(
              controller: _pageController,
              itemCount: viewerImages.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                final img = viewerImages[index];
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
                          img.path,
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
          if (viewerImages.length > 1)
            Positioned(
              bottom: 110,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  viewerImages.length,
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
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.8),
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

  Widget _buildVerticalGallery(
      BuildContext context, List<ViewerImageData> viewerImages) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        children: List.generate(viewerImages.length, (index) {
          final img = viewerImages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: GestureDetector(
              onTap: () => _showFullScreenImage(context, index),
              child: Hero(
                tag: index == 0
                    ? 'item_image_${widget.item.id}'
                    : 'item_gallery_$index',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 0.8,
                    child: UniversalImage(
                      img.path,
                      remoteImageUrl: img.remoteUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
