
import 'package:flutter/material.dart';
import '../../shared/universal_image.dart';

class EntryImagePicker extends StatelessWidget {
  final List<String> existingImages;
  final List<String> existingRemoteUrls;
  final List<String> newImages;
  final int? favoriteIndex;
  final Function(String) onPickImage;
  final Function(int) onRemoveExisting;
  final Function(int) onRemoveNew;
  final Function(int) onSetFavorite;

  const EntryImagePicker({
    super.key,
    required this.existingImages,
    this.existingRemoteUrls = const [],
    required this.newImages,
    this.favoriteIndex,
    required this.onPickImage,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onSetFavorite,
  });

  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  onPickImage('gallery');
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  onPickImage('camera');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isFavorite(int index) {
    if (favoriteIndex == null) return index == 0;
    return index == favoriteIndex;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalExisting = existingImages.length;

    return Card(
      color: colorScheme.surfaceContainerLowest,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Galería de Imágenes"),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Existing Images
                  ...List.generate(existingImages.length, (index) {
                    return _buildImageItem(
                      context,
                      index: index,
                      imagePath: existingImages[index],
                      remoteImageUrl: index < existingRemoteUrls.length
                          ? existingRemoteUrls[index]
                          : null,
                      onRemove: () => onRemoveExisting(index),
                      isFavorite: _isFavorite(index),
                      onSetFavorite: () => onSetFavorite(index),
                    );
                  }),

                  // New Images (local files)
                  ...newImages.asMap().entries.map((entry) {
                    final index = totalExisting + entry.key;
                    return _buildImageItem(
                      context,
                      index: index,
                      imagePath: entry.value,
                      onRemove: () => onRemoveNew(entry.key),
                      isFavorite: _isFavorite(index),
                      onSetFavorite: () => onSetFavorite(index),
                    );
                  }),

                  // Add Button
                  GestureDetector(
                    onTap: () => _showImageSourceSheet(context),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            color: colorScheme.primary,
                            size: 30,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Añadir",
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(
    BuildContext context, {
    required int index,
    required String imagePath,
    String? remoteImageUrl,
    required VoidCallback onRemove,
    required VoidCallback onSetFavorite,
    bool isFavorite = false,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: isFavorite
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    )
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: remoteImageUrl?.isNotEmpty == true
                  ? UniversalImage(
                      imagePath,
                      remoteImageUrl: remoteImageUrl,
                      fit: BoxFit.cover,
                    )
                  : UniversalImage(imagePath, fit: BoxFit.cover),
            ),
          ),
          // Favorite badge
          if (isFavorite)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 16),
              ),
            ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          // Set as favorite button
          if (!isFavorite)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: onSetFavorite,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star_border,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
