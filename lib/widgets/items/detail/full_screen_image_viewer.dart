import 'package:flutter/material.dart';
import '../../shared/universal_image.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;
  final VoidCallback? onDismiss;
  final Function(String)? onSetMain;

  const FullScreenImageViewer({
    super.key,
    required this.imagePaths,
    required this.initialIndex,
    this.onDismiss,
    this.onSetMain,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final path = widget.imagePaths[index];
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: UniversalImage(
                    path,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.imagePaths.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_currentIndex + 1} / ${widget.imagePaths.length}",
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
                if (widget.onSetMain != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton(
                      icon: Icon(
                        widget.imagePaths[_currentIndex].isNotEmpty
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 30,
                      ),
                      tooltip: "Establecer como portada",
                      onPressed: () {
                        widget.onSetMain!(widget.imagePaths[_currentIndex]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Portada actualizada")),
                        );
                      },
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed:
                      widget.onDismiss ?? () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
