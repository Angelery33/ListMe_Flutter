
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../shared/universal_image.dart';

/// Un editor de galería desplazable horizontal utilizado en el formulario de entrada/edición de elementos.
///
/// Muestra miniaturas de imágenes existentes (cargadas de la BD) e imágenes locales recién seleccionadas,
/// además de un botón "añadir" que abre una hoja inferior para elegir entre galería y cámara.
/// Cada miniatura tiene un botón de eliminar y un botón de estrella para establecerla como la imagen
/// favorita (portada).
class EntryImagePicker extends StatelessWidget {
  /// Rutas a las imágenes ya persistidas en la base de datos para este elemento.
  final List<String> existingImages;

  /// URLs remotas correspondientes a [existingImages], utilizadas por [UniversalImage]
  /// como respaldo cuando la ruta local no está disponible.
  final List<String> existingRemoteUrls;

  /// Rutas a las imágenes locales recién seleccionadas que aún no se han guardado en la base de datos.
  final List<String> newImages;

  /// Índice combinado (a través de [existingImages] + [newImages]) de la imagen
  /// marcada actualmente como favorita. Nulo por defecto al índice 0.
  final int? favoriteIndex;

  /// Se llama con la cadena de origen ('gallery' o 'camera') cuando el usuario
  /// selecciona un origen de la hoja inferior.
  final Function(String) onPickImage;

  /// Se llama con el índice de la lista de la imagen existente que el usuario desea eliminar.
  final Function(int) onRemoveExisting;

  /// Se llama con el índice de la lista (dentro de [newImages]) de la nueva imagen a eliminar.
  final Function(int) onRemoveNew;

  /// Se llama con el índice combinado cuando el usuario toca una estrella para convertir una imagen
  /// en la favorita.
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

  /// Muestra una hoja inferior modal pidiendo al usuario que elija entre galería y
  /// cámara (la cámara está oculta en plataformas de escritorio). Llama a [onPickImage] con
  /// la cadena de origen elegida.
  void _showImageSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.imageGallery),
                onTap: () {
                  Navigator.of(context).pop();
                  onPickImage('gallery');
                },
              ),
              if (!kIsWeb && !Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(context.l10n.imageCamera),
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

  /// Devuelve true si la imagen en el [index] combinado es la favorita actual.
  /// Cuando [favoriteIndex] es nulo, el índice 0 se trata como favorito.
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
            _buildSectionTitle(context, context.l10n.itemSectionGallery),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Imágenes existentes
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

                  // Imágenes nuevas (archivos locales)
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

                  // Botón de añadir
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
                            context.l10n.commonAdd,
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

  /// Construye una sola miniatura de 100 × 120 px con botones superpuestos.
  /// Una X roja en la parte superior derecha llama a [onRemove]; una insignia de estrella en la parte inferior derecha
  /// llama a [onSetFavorite] para promocionar esta imagen a favorita. Cuando [isFavorite]
  /// es verdadero, se muestra una insignia de estrella dorada en la parte superior izquierda y el borde resplandece.
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

  /// Renderiza la etiqueta del encabezado de la sección con estilo en color primario en mayúsculas.
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
