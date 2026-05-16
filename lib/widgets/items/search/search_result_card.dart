import 'package:flutter/material.dart';
import '../../../widgets/shared/universal_image.dart';

/// Tarjeta de resultado de búsqueda externa que muestra portada, título, calificación,
/// chips de fuente/año/estado y descripción.
///
/// El diseño escala proporcionalmente a [columnWidth] para que la tarjeta se adapte tanto
/// a la lista de una columna (móvil) como a la cuadrícula de dos columnas (escritorio).
class SearchResultCard extends StatelessWidget {
  /// Datos crudos normalizados del resultado de la API externa.
  final Map<String, dynamic> item;

  /// Ancho de la columna que contiene esta tarjeta, usado para escalar tamaños.
  final double columnWidth;

  /// Callback invocado cuando el usuario pulsa la tarjeta.
  final VoidCallback onSelect;

  const SearchResultCard({
    super.key,
    required this.item,
    required this.columnWidth,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final title = item['name'] ?? 'Sin título';
    final imageUrl = item['imagePath'];
    final year = item['year'];
    final rating = item['externalRating'];
    final author = item['author'];
    final description = item['description'] ?? '';
    final status = item['status'];
    final source = item['source'] ?? 'Unknown';

    String? secondaryInfo;
    if (author != null && (author as String).isNotEmpty) {
      secondaryInfo = author;
    } else if (year != null && (year as String).isNotEmpty) {
      secondaryInfo = year;
    }

    final scale = (columnWidth / 400).clamp(0.85, 1.4);
    final imgH = (145.0 * scale).clamp(100.0, 200.0);
    final imgW = imgH * 0.70;
    final titleSize = (15.0 * scale).clamp(14.0, 20.0);
    final bodySize = (13.0 * scale).clamp(12.0, 16.0);
    final tagSize = (11.0 * scale).clamp(10.0, 14.0);
    final ratingSize = (12.0 * scale).clamp(11.0, 16.0);
    final ratingIconSize = (16.0 * scale).clamp(14.0, 22.0);
    final descLimit = (100 * scale).toInt();
    final descLines = scale > 1.2 ? 4 : 3;
    final cardPadding = (12.0 * scale).clamp(10.0, 16.0);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && (imageUrl as String).isNotEmpty
                    ? UniversalImage(
                        '',
                        remoteImageUrl: imageUrl,
                        width: imgW,
                        height: imgH,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: imgW,
                        height: imgH,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image, size: 30),
                      ),
              ),
              SizedBox(width: (12 * scale).clamp(8, 18)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: titleSize,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (rating != null && (rating as num) > 0) ...[
                          SizedBox(width: (6 * scale).clamp(4, 10)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: (6 * scale).clamp(5, 12),
                              vertical: (3 * scale).clamp(2, 6),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: ratingIconSize, color: Colors.amber),
                                SizedBox(width: (3 * scale).clamp(2, 6)),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: ratingSize),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (secondaryInfo != null) ...[
                      SizedBox(height: (4 * scale).clamp(3, 6)),
                      Text(
                        secondaryInfo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: bodySize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: (6 * scale).clamp(4, 10)),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildTag(source, colorScheme.primaryContainer,
                            colorScheme.onPrimaryContainer, tagSize),
                        if (year != null && (year as String).isNotEmpty && secondaryInfo != year)
                          _buildTag(year, colorScheme.secondaryContainer,
                              colorScheme.onSecondaryContainer, tagSize),
                        if (status != null && (status as String).isNotEmpty)
                          _buildTag(
                            status,
                            _isFinished(status)
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.blue.withValues(alpha: 0.2),
                            _isFinished(status) ? Colors.green.shade700 : Colors.blue.shade700,
                            tagSize,
                          ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: (6 * scale).clamp(4, 10)),
                      Text(
                        description.length > descLimit
                            ? '${description.substring(0, descLimit)}...'
                            : description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: bodySize,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: descLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isFinished(String status) =>
      status.toLowerCase().contains('finish') ||
      status.toLowerCase().contains('complete');

  /// Construye una pequeña placa tipo píldora con [text], fondo [bg] y color [fg].
  Widget _buildTag(String text, Color bg, Color fg, [double fontSize = 10]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }
}
