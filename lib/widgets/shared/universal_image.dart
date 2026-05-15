import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniversalImage extends StatelessWidget {
  final String imagePath;
  final String? remoteImageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? itemId;
  final int? imageId;

  const UniversalImage(
    this.imagePath, {
    super.key,
    this.remoteImageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.itemId,
    this.imageId,
  });

  @override
  Widget build(BuildContext context) {
    final url = _getBestUrl();

    if (url.isEmpty) return _placeholder(context);

    // On web, Firebase Storage URLs must go through the SDK to bypass CORS
    if (kIsWeb && _isFirebaseStorageUrl(url)) {
      return _WebFirebaseImage(
        url: url,
        fit: fit,
        width: width,
        height: height,
        placeholder: _placeholder(context),
      );
    }

    if (url.startsWith('http') || url.startsWith('blob:')) {
      final displayUrl = _shouldProxy(url)
          ? 'https://images.weserv.nl/?url=${Uri.encodeComponent(url)}'
          : url;
      return Image.network(
        displayUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    // Local file — only valid on mobile, on the same device it was picked
    if (kIsWeb) return _placeholder(context);

    final file = File(url);
    if (file.existsSync()) {
      return Image.file(file, fit: fit, width: width, height: height);
    }
    return _placeholder(context);
  }

  String _getBestUrl() {
    // If we have itemId and imageId, use the API endpoint (avoids CORS issues)
    if (itemId != null && imageId != null) {
      return 'https://api.angelcantero.store/api/v1/images/$itemId/$imageId';
    }

    // Remote URL as fallback (works across all devices and platforms)
    if (remoteImageUrl?.isNotEmpty == true) return remoteImageUrl!;

    // Blob URL from web image picker (before upload)
    if (imagePath.isNotEmpty && imagePath.startsWith('blob:')) return imagePath;

    // Local paths are only valid on the same device they were picked
    if (kIsWeb) return '';

    // Use local path as fallback if it exists
    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) return imagePath;

    return '';
  }

  bool _isFirebaseStorageUrl(String url) =>
      url.contains('firebasestorage.googleapis.com');

  bool _shouldProxy(String url) {
    if (!url.startsWith('http')) return false;
    if (_isFirebaseStorageUrl(url)) return false;
    if (url.contains('images.weserv.nl')) return false;
    // MAL blocks hotlinking on all platforms (both cdn. and direct domain)
    if (url.contains('myanimelist.net')) return true;
    // On web, proxy everything else too (CORS)
    return kIsWeb;
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.outline,
          size: 40,
        ),
      ),
    );
  }
}

// In-memory cache so each URL is only fetched once per session
final Map<String, Uint8List> _firebaseImageCache = {};

class _WebFirebaseImage extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget placeholder;

  const _WebFirebaseImage({
    required this.url,
    required this.fit,
    this.width,
    this.height,
    required this.placeholder,
  });

  @override
  State<_WebFirebaseImage> createState() => _WebFirebaseImageState();
}

class _WebFirebaseImageState extends State<_WebFirebaseImage> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Serve from cache if available
    if (_firebaseImageCache.containsKey(widget.url)) {
      if (mounted) {
        setState(() {
          _bytes = _firebaseImageCache[widget.url];
          _loading = false;
        });
      }
      return;
    }

    try {
      final ref = FirebaseStorage.instance.refFromURL(widget.url);
      final bytes = await ref.getData(10 * 1024 * 1024); // 10 MB max
      if (bytes != null) {
        _firebaseImageCache[widget.url] = bytes;
        if (mounted) setState(() { _bytes = bytes; _loading = false; });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (_bytes == null) return widget.placeholder;
    return Image.memory(
      _bytes!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, __, ___) => widget.placeholder,
    );
  }
}
