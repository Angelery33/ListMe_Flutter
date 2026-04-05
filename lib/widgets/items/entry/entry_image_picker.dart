import 'dart:io';
import 'package:flutter/material.dart';
import '../../shared/universal_image.dart';

class EntryImagePicker extends StatelessWidget {
  final List<String> existingImages;
  final List<String> newImages;
  final Function(String) onPickImage;
  final Function(int) onRemoveExisting;
  final Function(int) onRemoveNew;

  const EntryImagePicker({
    super.key,
    required this.existingImages,
    required this.newImages,
    required this.onPickImage,
    required this.onRemoveExisting,
    required this.onRemoveNew,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  ...existingImages.asMap().entries.map((entry) {
                    return _buildImageItem(
                      context,
                      imagePath: entry.value,
                      onRemove: () => onRemoveExisting(entry.key),
                      isNetwork: entry.value.startsWith('http'),
                    );
                  }),

                  // New Images (local files)
                  ...newImages.asMap().entries.map((entry) {
                    return _buildImageItem(
                      context,
                      imagePath: entry.value,
                      onRemove: () => onRemoveNew(entry.key),
                      isLocalFile: true,
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
    required String imagePath,
    required VoidCallback onRemove,
    bool isNetwork = false,
    bool isLocalFile = false,
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
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: isLocalFile
                  ? Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      width: 100,
                      height: 120,
                    )
                  : UniversalImage(imagePath, fit: BoxFit.cover),
            ),
          ),
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
