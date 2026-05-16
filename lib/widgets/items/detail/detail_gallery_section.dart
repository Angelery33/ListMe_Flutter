import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/items/item_image_model.dart';
import '../../../../providers/items/item_details_provider.dart';
import '../../shared/universal_image.dart';
import 'full_screen_image_viewer.dart';

/// Muestra la galería de fotos de un elemento en la pantalla de detalles como una franja
/// horizontal desplazable de tarjetas de miniaturas.
///
/// Cada miniatura se puede pulsar para abrir el [FullScreenImageViewer]. Cuando
/// [canEdit] es verdadero, se muestra un botón de estrella en cada miniatura para marcarla como
/// la imagen favorita (portada).
class DetailGallerySection extends StatelessWidget {
  /// El elemento cuyas imágenes de galería se muestran.
  final ItemModel item;

  /// Indica si se debe renderizar el botón de estrella favorita en cada miniatura, permitiendo
  /// al usuario cambiar la imagen de portada. Se establece en falso en contextos de solo lectura.
  final bool canEdit;

  const DetailGallerySection({super.key, required this.item, this.canEdit = true});

  /// Convierte la lista de objetos [ItemImageModel] en instancias de [ViewerImageData]
  /// consumidas por [FullScreenImageViewer].
  List<ViewerImageData> _toViewerImages(List<ItemImageModel> images) {
    return images.map((img) => ViewerImageData(
      path: img.imageUri ?? '',
      remoteUrl: img.remoteImageUrl,
      imageId: img.id,
      isFavorite: img.isFavorite,
    )).toList();
  }

  /// Abre el [FullScreenImageViewer] comenzando en [index].
  /// En pantallas anchas (> 840 px) se abre como un diálogo; en pantallas estrechas
  /// empuja una ruta de pantalla completa.
  void _showImageFullScreen(
    BuildContext context,
    List<ItemImageModel> images,
    int index,
  ) {
    final viewerImages = _toViewerImages(images);
    if (viewerImages.isEmpty) return;

    Future<bool> onSetFavorite(int imageId) =>
        context.read<ItemDetailsProvider>().setFavoriteImage(imageId);

    if (MediaQuery.of(context).size.width > 840) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          child: Container(
            width: 595,
            height: 842,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: FullScreenImageViewer(
              images: viewerImages,
              initialIndex: index,
              onDismiss: () => Navigator.pop(ctx),
              onSetFavorite: canEdit ? onSetFavorite : null,
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullScreenImageViewer(
            images: viewerImages,
            initialIndex: index,
            onDismiss: () => Navigator.pop(context),
            onSetFavorite: canEdit ? onSetFavorite : null,
          ),
        ),
      );
    }
  }

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
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.2),
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
                        onTap: () => _showImageFullScreen(context, images, index),
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
                      if (canEdit)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => provider.setFavoriteImage(img.id!),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                img.isFavorite ? Icons.star : Icons.star_border,
                                color: img.isFavorite
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
}
