import 'package:flutter/material.dart';
import '../../../../data/items/item_model.dart';

import 'package:provider/provider.dart';
import '../../../../providers/items/item_details_provider.dart';
import '../../shared/universal_image.dart';
import 'full_screen_image_viewer.dart';

class DetailGallerySection extends StatelessWidget {
  final ItemModel item;

  const DetailGallerySection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final images = provider.images;

    if (images.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "GALERÍA",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _showImageFullScreen(context, img, index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: UniversalImage(
                              img.imageUri ?? '',
                              remoteImageUrl: img.remoteImageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => context.read<ItemDetailsProvider>().setFavoriteImage(img.id!),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              img.isFavorite == true ? Icons.star : Icons.star_border,
                              color: img.isFavorite == true
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showImageFullScreen(BuildContext context, dynamic img, int index) {
    final imagePath = img.imageUri ?? '';
    final remoteUrl = img.remoteImageUrl;

    // En web: modal con tamaño A4 en el centro
    // En móvil: pantalla completa
    if (MediaQuery.of(context).size.width > 840) {
      showDialog(
        context: context,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setState) => Dialog(
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
                    imagePath,
                    remoteImageUrl: remoteUrl,
                    fit: BoxFit.contain,
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            img.isFavorite == true ? Icons.star : Icons.star_border,
                            color: img.isFavorite == true
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.white,
                          ),
                          onPressed: () {
                            context.read<ItemDetailsProvider>().setFavoriteImage(img.id!);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            imagePaths: [remoteUrl ?? imagePath],
            initialIndex: 0,
            currentImageId: img.id,
            onDismiss: () => Navigator.pop(context),
            onSetFavorite: (imageId) => context.read<ItemDetailsProvider>().setFavoriteImage(imageId),
          ),
        ),
      );
    }
  }
}
