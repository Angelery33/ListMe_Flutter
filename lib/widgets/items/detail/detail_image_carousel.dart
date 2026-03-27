import 'package:flutter/material.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/items/item_image_model.dart';

class DetailImageCarousel extends StatefulWidget {
  final ItemModel item;
  final List<ItemImageModel> images;

  const DetailImageCarousel({
    super.key,
    required this.item,
    required this.images,
  });

  @override
  State<DetailImageCarousel> createState() => _DetailImageCarouselState();
}

class _DetailImageCarouselState extends State<DetailImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // Collect all valid image paths
    final List<String> paths = [];
    if (widget.item.imagePath != null && widget.item.imagePath!.isNotEmpty) {
      paths.add(widget.item.imagePath!);
    } else if (widget.item.remoteImageUrl != null && widget.item.remoteImageUrl!.isNotEmpty) {
      paths.add(widget.item.remoteImageUrl!);
    }
    paths.addAll(widget.images.map((img) => img.imageUri).whereType<String>());

    if (paths.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          child: Center(
            child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
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
              return Hero(
                tag: index == 0 ? 'item_image_${widget.item.id}' : 'item_gallery_$index',
                child: Image.network(
                  path,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
                  ),
                ),
              );
            },
          ),
          
          if (paths.length > 1)
            Positioned(
              bottom: 16,
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
                      color: _currentIndex == index ? Colors.white : Colors.white.withValues(alpha: 0.4),
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
