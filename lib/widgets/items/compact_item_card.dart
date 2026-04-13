import 'package:flutter/material.dart';
import '../../data/items/item_model.dart';
import '../shared/universal_image.dart';

/// Vista compacta (Grid) para el elemento de una lista.
class CompactItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isGradeable;
  final bool supportsProgress;

  const CompactItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.isGradeable = true,
    this.supportsProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen
              _buildImage(context),

              // Edition Tag (Bottom Right)
              if (item.edition != null && item.edition!.isNotEmpty)
                Positioned(
                  bottom: (supportsProgress && (item.currentProgress ?? 0) > 0)
                      ? 46
                      : 32,
                  right: 6,
                  child: _buildEditionBadge(context),
                ),

              // Gradient Overlay
              _buildGradientOverlay(context),

              // Item Number Badge (Top Left)
              if (item.itemNumber != null && item.itemNumber!.isNotEmpty)
                Positioned(
                  top: 6,
                  left: 6,
                  child: _buildItemNumberBadge(context),
                ),

              // Score Overlay (Top Right)
              if (isGradeable && (item.score ?? 0) > 0)
                Positioned(top: 6, right: 6, child: _buildScoreBadge(context)),

              // Siguiendo Badge Overlay
              if (item.current)
                Positioned(
                  top: 6,
                  left: 6,
                  child: _buildFollowingBadge(context),
                ),

              // Progress Overlay (Bottom)
              if (supportsProgress && (item.currentProgress ?? 0) > 0)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildProgressOverlay(context),
                ),

              // Name Overlay
              Positioned(
                bottom: (supportsProgress && (item.currentProgress ?? 0) > 0)
                    ? 22
                    : 8,
                left: 0,
                right: 0,
                child: _buildNameOverlay(context),
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

  Widget _buildEditionBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2),
        ],
      ),
      child: Text(
        item.edition!,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGradientOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              colorScheme.surface.withValues(alpha: 0.1),
              colorScheme.surface.withValues(alpha: 0.9),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildItemNumberBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
        ],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            item.itemNumber!,
            style: TextStyle(
              color: colorScheme.onTertiary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 10, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            item.score!.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
      child: const Icon(Icons.play_circle_fill, size: 14, color: Colors.white),
    );
  }

  Widget _buildProgressOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (item.totalProgress != null && item.totalProgress! > 0)
        ? (item.currentProgress ?? 0) / item.totalProgress!
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.totalProgress != null && item.totalProgress! > 0)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: 4,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          color: Colors.black54,
          width: double.infinity,
          child: Text(
            "${item.progressUnit ?? 'Progreso'} ${item.currentProgress}${item.totalProgress != null ? '/${item.totalProgress}' : ''}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildNameOverlay(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              shadows: [
                const Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
