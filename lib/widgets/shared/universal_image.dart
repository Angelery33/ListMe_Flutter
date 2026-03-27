import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Un widget de imagen que maneja automáticamente orígenes locales y remotos.
class UniversalImage extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final Alignment alignment;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const UniversalImage(
    this.imagePath, {
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildError(context);
    }

    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return Image.network(
        imagePath,
        fit: fit,
        alignment: alignment,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) => _buildError(context),
      );
    }

    // Para archivos locales
    if (!kIsWeb) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          alignment: alignment,
          errorBuilder: errorBuilder ?? (context, error, stackTrace) => _buildError(context),
        );
      }
    }

    // Por defecto, intentar como asset si no es URL ni archivo
    return Image.asset(
      imagePath,
      fit: fit,
      alignment: alignment,
      errorBuilder: errorBuilder ?? (context, error, stackTrace) => _buildError(context),
    );
  }

  Widget _buildError(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.white24),
      ),
    );
  }
}
