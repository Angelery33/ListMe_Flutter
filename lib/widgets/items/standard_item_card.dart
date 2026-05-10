import 'package:flutter/material.dart';
import '../../data/items/item_model.dart';
import '../shared/universal_image.dart';

/// Vista estándar para el elemento de una lista.
class StandardItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showStatus;
  final bool isGradeable;
  final bool isThematic;
  final bool supportsPrice;
  final bool supportsProgress;

  const StandardItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.showStatus = true,
    this.isGradeable = true,
    this.isThematic = true,
    this.supportsPrice = true,
    this.supportsProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Colores de estado basados en el código original
    Color statusColor;
    String statusText;
    switch (item.status) {
      case "COMPLETED":
        statusColor = const Color(0xFF4CAF50);
        statusText = "Completado";
        break;
      case "IN_PROGRESS":
        statusColor = const Color(0xFFFFC107);
        statusText = "En proceso";
        break;
      default:
        statusColor = const Color(0xFFE53935);
        statusText = "Pendiente";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox(
          height: 160,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen Cuadrada
              Container(
                width: 100,
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(context),
                    if (item.itemNumber != null &&
                        item.itemNumber!.isNotEmpty)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: _buildItemNumberBadge(context),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      if (isThematic &&
                          item.genre != null &&
                          item.genre!.isNotEmpty)
                        _buildGenre(context),
                      if (item.edition != null && item.edition!.isNotEmpty)
                        _buildEditionBadge(context),
                      const SizedBox(height: 4),
                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        _buildDescription(context),
                      const Spacer(),
                      _buildStatusRow(context, statusColor, statusText),
                      if (supportsProgress && (item.currentProgress ?? 0) > 0)
                        _buildProgressBar(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {

    return UniversalImage(
      item.imagePath ?? "",
      remoteImageUrl: item.remoteImageUrl,
      fit: BoxFit.cover,
    );
  }

  Widget _buildItemNumberBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          item.itemNumber!,
          style: TextStyle(
            color: colorScheme.onTertiary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            item.name,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (item.price != null && supportsPrice)
          Text(
            "${item.price!.toStringAsFixed(2)}€",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  Widget _buildGenre(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        item.genre!,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEditionBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          item.edition!,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        item.description!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 11,
          height: 1.1,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    Color statusColor,
    String statusText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (item.current) _buildFollowingBadge(context),
            if (showStatus) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                statusText.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
        if (isGradeable && (item.score ?? 0) > 0) _buildScoreBadge(context),
      ],
    );
  }

  Widget _buildFollowingBadge(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.play_circle_fill, size: 10, color: Colors.white),
          SizedBox(width: 2),
          Text(
            "SIGUIENDO",
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, size: 12, color: color),
        const SizedBox(width: 2),
        Text(
          item.score!.toStringAsFixed(1),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (item.totalProgress != null && item.totalProgress! > 0)
        ? (item.currentProgress ?? 0) / item.totalProgress!
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${item.progressUnit ?? 'Progreso'} ${item.currentProgress}${item.totalProgress != null ? ' / ${item.totalProgress}' : ''}",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            if (item.totalProgress != null && item.totalProgress! > 0)
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
