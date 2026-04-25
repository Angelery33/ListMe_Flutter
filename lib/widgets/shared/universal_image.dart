import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String imagePath;
  final String? remoteImageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const UniversalImage(
    this.imagePath, {
    super.key,
    this.remoteImageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    String url = _getBestUrl();

    if (url.isEmpty) {
      return _placeholder(context);
    }

    if (url.startsWith('http') || url.startsWith('blob:')) {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    // Archivo local
    if (kIsWeb) return _placeholder(context);

    final file = File(url);
    if (file.existsSync()) {
      return Image.file(file, fit: fit);
    }
    return _placeholder(context);
  }

  String _getBestUrl() {
    // Web: usar remote si está disponible
    if (kIsWeb) {
      if (remoteImageUrl?.isNotEmpty == true) {
        return remoteImageUrl!;
      }
      if (imagePath.startsWith('blob:')) return imagePath;
      // Si es ruta local en web, no sirve
      if (imagePath.startsWith('/data') || imagePath.startsWith('assets/')) {
        return '';
      }
      return imagePath;
    }
    // Móvil: preferir local
    if (imagePath.isNotEmpty) return imagePath;
    return remoteImageUrl ?? '';
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(Icons.broken_image_rounded, color: Colors.white24),
      ),
    );
  }
}
