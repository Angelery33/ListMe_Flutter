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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final s = constraints.maxWidth;
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen
                  _buildImage(context),

                  // Edition Tag (Bottom Right)
                  if (item.edition != null && item.edition!.isNotEmpty)
                    Positioned(
                      bottom: (supportsProgress && (item.currentProgress ?? 0) > 0)
                          ? s * 0.46
                          : s * 0.32,
                      right: s * 0.06,
                      child: _buildEditionBadge(context, s),
                    ),

                  // Gradient Overlay
                  _buildGradientOverlay(context),

                  // Item Number Badge (Top Left)
                  if (item.itemNumber != null && item.itemNumber!.isNotEmpty)
                    Positioned(
                      top: s * 0.06,
                      left: s * 0.06,
                      child: _buildItemNumberBadge(context, s),
                    ),

                  // Score Overlay (Top Right)
                  if (isGradeable && (item.score ?? 0) > 0)
                    Positioned(
                      top: s * 0.06,
                      right: s * 0.06,
                      child: _buildScoreBadge(context, s),
                    ),

                  // Siguiendo Badge Overlay
                  if (item.current)
                    Positioned(
                      top: s * 0.06,
                      left: s * 0.06,
                      child: _buildFollowingBadge(context, s),
                    ),

                  // Progress Overlay (Bottom)
                  if (supportsProgress && (item.currentProgress ?? 0) > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildProgressOverlay(context, s),
                    ),

                  // Name Overlay
                  Positioned(
                    bottom: (supportsProgress && (item.currentProgress ?? 0) > 0)
                        ? s * 0.22
                        : s * 0.08,
                    left: 0,
                    right: 0,
                    child: _buildNameOverlay(context, s),
                  ),
                ],
              );
            },
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

  Widget _buildEditionBadge(BuildContext context, double s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s * 0.06, vertical: s * 0.02),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(s * 0.04),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 2),
        ],
      ),
      child: Text(
        item.edition!,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontSize: s * 0.08,
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

  Widget _buildItemNumberBadge(BuildContext context, double s) {
    final colorScheme = Theme.of(context).colorScheme;
    final badgeSize = s * 0.22;
    return Container(
      width: badgeSize,
      height: badgeSize,
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
              fontSize: s * 0.10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(BuildContext context, double s) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s * 0.06, vertical: s * 0.02),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(s * 0.08),
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
          Icon(Icons.star, size: s * 0.10, color: Colors.white),
          SizedBox(width: s * 0.02),
          Text(
            item.score!.toStringAsFixed(1),
            style: TextStyle(
              color: Colors.white,
              fontSize: s * 0.10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowingBadge(BuildContext context, double s) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s * 0.06, vertical: s * 0.02),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(s * 0.08),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
      child: Icon(Icons.play_circle_fill, size: s * 0.14, color: Colors.white),
    );
  }

  Widget _buildProgressOverlay(BuildContext context, double s) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (item.totalProgress != null && item.totalProgress! > 0)
        ? (item.currentProgress ?? 0) / item.totalProgress!
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.totalProgress != null && item.totalProgress! > 0)
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(s * 0.12),
              bottomRight: Radius.circular(s * 0.12),
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              minHeight: s * 0.04,
            ),
          ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: s * 0.04, vertical: s * 0.01),
          color: Colors.black54,
          width: double.infinity,
          child: Text(
            "${item.progressUnit ?? 'Progreso'} ${item.currentProgress}${item.totalProgress != null ? '/${item.totalProgress}' : ''}",
            style: TextStyle(
              color: Colors.white,
              fontSize: s * 0.08,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildNameOverlay(BuildContext context, double s) {
    return Align(
      alignment: Alignment.center,
      child: IntrinsicWidth(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: s * 0.08, vertical: s * 0.04),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(s * 0.06),
          ),
          child: Text(
            item.name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: s * 0.11,
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
