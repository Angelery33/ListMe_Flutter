import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../shared/universal_image.dart';

class ViewerImageData {
  final String path;
  final String? remoteUrl;
  final int? imageId;
  final bool isFavorite;

  const ViewerImageData({
    required this.path,
    this.remoteUrl,
    this.imageId,
    this.isFavorite = false,
  });
}

class FullScreenImageViewer extends StatefulWidget {
  final List<ViewerImageData> images;
  final int initialIndex;
  final VoidCallback? onDismiss;
  final Future<bool> Function(int imageId)? onSetFavorite;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.onDismiss,
    this.onSetFavorite,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  late List<ViewerImageData> _images;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _images = List.of(widget.images);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _currentIsFavorite =>
      _images.isNotEmpty && _images[_currentIndex].isFavorite;

  int? get _currentImageId =>
      _images.isNotEmpty ? _images[_currentIndex].imageId : null;

  void _onSetFavorite() async {
    final imageId = _currentImageId;
    if (imageId == null || widget.onSetFavorite == null) return;

    setState(() {
      _images = _images
          .map((img) => ViewerImageData(
                path: img.path,
                remoteUrl: img.remoteUrl,
                imageId: img.imageId,
                isFavorite: img.imageId == imageId,
              ))
          .toList();
    });

    final success = await widget.onSetFavorite!(imageId);
    if (!success && mounted) {
      setState(() => _images = List.of(widget.images));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final img = _images[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: UniversalImage(
                    img.path,
                    remoteImageUrl: img.remoteUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          if (_images.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${_images.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Row(
              children: [
                if (widget.onSetFavorite != null && _currentImageId != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Icon(
                        _currentIsFavorite ? Icons.star : Icons.star_border,
                        color: _currentIsFavorite ? Colors.amber : Colors.white,
                        size: 30,
                      ),
                      tooltip: context.l10n.imageMarkFavorite,
                      onPressed: _onSetFavorite,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: widget.onDismiss ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
