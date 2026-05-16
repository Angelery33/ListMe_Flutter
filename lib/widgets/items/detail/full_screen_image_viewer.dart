import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../shared/universal_image.dart';

/// Objeto de transferencia de datos inmutable que contiene la información que un
/// [FullScreenImageViewer] necesita para mostrar una sola imagen.
class ViewerImageData {
  /// Ruta de archivo local o ruta de activo para la imagen. Puede estar vacía cuando solo
  /// [remoteUrl] está disponible.
  final String path;

  /// URL remota utilizada como respaldo (o fuente principal) cuando [path] está vacío.
  final String? remoteUrl;

  /// ID de base de datos del registro de imagen, utilizado para llamar a la función de retorno de establecer favorita.
  /// Nulo para entradas sintéticas (ej. la imagen principal del elemento).
  final int? imageId;

  /// Indica si esta imagen es actualmente la imagen favorita (portada) del elemento.
  final bool isFavorite;

  const ViewerImageData({
    required this.path,
    this.remoteUrl,
    this.imageId,
    this.isFavorite = false,
  });
}

/// Visor de imágenes a pantalla completa y con zoom que admite múltiples imágenes a través de un
/// [PageView] horizontal.
///
/// Se utiliza tanto como una ruta independiente en dispositivos móviles como dentro de un diálogo en diseños
/// anchos/web. Muestra un contador de páginas, un botón de cierre y un botón de estrella opcional
/// para marcar la imagen actual como favorita.
class FullScreenImageViewer extends StatefulWidget {
  /// La lista ordenada de imágenes para mostrar. No debe estar vacía.
  final List<ViewerImageData> images;

  /// El índice de página que se mostrará cuando se abra el visor por primera vez.
  final int initialIndex;

  /// Se llama cuando se pulsa el botón de cierre para que el llamador pueda cerrar la ruta
  /// o el diálogo.
  final VoidCallback? onDismiss;

  /// Cuando no es nulo, se muestra un botón de estrella. Se llama con el ID de la base de datos de la imagen
  /// y se espera que devuelva `true` si tiene éxito. En caso de fallo, se revierte la actualización
  /// optimista local.
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

/// Estado para [FullScreenImageViewer]. Mantiene el controlador de página, el índice de página
/// visible actualmente y una copia mutable de la lista de imágenes para que los cambios de favorita
/// puedan reflejarse de forma optimista mientras se completa la llamada de red.
class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  /// Controla el [PageView] para saltos de página programáticos.
  late PageController _pageController;

  /// Índice de la página de imagen visible actualmente.
  late int _currentIndex;

  /// Copia de trabajo mutable de la lista de imágenes. Se modifica de forma optimista cuando el
  /// usuario toca la estrella de favorita, luego se revierte si falla la llamada al backend.
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

  /// Indica si la imagen visible actualmente está marcada como favorita.
  bool get _currentIsFavorite =>
      _images.isNotEmpty && _images[_currentIndex].isFavorite;

  /// El ID de la base de datos de la imagen visible actualmente, o nulo para entradas sintéticas.
  int? get _currentImageId =>
      _images.isNotEmpty ? _images[_currentIndex].imageId : null;

  /// Maneja una pulsación en la estrella de favorita: marca de forma optimista la imagen actual
  /// como favorita, llama a [FullScreenImageViewer.onSetFavorite] y
  /// revierte el estado local si la llamada devuelve false.
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
