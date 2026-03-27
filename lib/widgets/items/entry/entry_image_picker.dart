import 'dart:io';
import 'package:flutter/material.dart';
import '../../shared/universal_image.dart';

class EntryImagePicker extends StatelessWidget {
  final List<String> existingImages;
  final List<String> newImages;
  final VoidCallback onPickImage;
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Galería de Imágenes"),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Botón Añadir
              GestureDetector(
                onTap: onPickImage,
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(Icons.add_a_photo_rounded, color: colorScheme.primary, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              
              // Imágenes Existentes (URLs o paths previos)
              ...existingImages.asMap().entries.map((entry) {
                return _buildImageItem(
                  context,
                  imagePath: entry.value,
                  onRemove: () => onRemoveExisting(entry.key),
                );
              }),

              // Nuevas Imágenes (Archivos locales temporales)
              ...newImages.asMap().entries.map((entry) {
                return _buildImageItem(
                  context,
                  imagePath: entry.value,
                  isLocalFile: true,
                  onRemove: () => onRemoveNew(entry.key),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(BuildContext context, {
    required String imagePath,
    required VoidCallback onRemove,
    bool isLocalFile = false,
  }) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: isLocalFile 
                ? Image.file(File(imagePath), fit: BoxFit.cover, width: 100, height: 120)
                : UniversalImage(imagePath, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
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
