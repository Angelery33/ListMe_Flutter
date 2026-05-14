import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/lists/list_model.dart';
import '../../../../providers/items/item_details_provider.dart';

class DetailRatingSection extends StatelessWidget {
  final ListModel? library;
  final bool canEdit;

  const DetailRatingSection({super.key, this.library, this.canEdit = true});

  int get _ratingScale => library?.ratingScale ?? 10;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final item = provider.item;

    if (item == null) return const SizedBox.shrink();

    final showPersonal = library?.gradeable ?? (item.score != null && item.score! > 0);
    final showExternal =
        item.externalRating != null && item.externalRating! > 0;

    if (!showPersonal && !showExternal) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (showPersonal)
            _buildPersonalRating(context, provider, item.score ?? 0.0),
          if (showExternal)
            Padding(
              padding: EdgeInsets.only(top: showPersonal ? 16 : 0),
              child: _buildExternalRating(context, item.externalRating!, item.ratingSource),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalRating(
    BuildContext context,
    ItemDetailsProvider provider,
    double score,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Puntuación',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                _formatScore(score),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: List.generate(5, (index) {
              double fraction;
              if (_ratingScale == 5) {
                fraction = score - index;
              } else if (_ratingScale == 100) {
                fraction = (score / 20.0) - index;
              } else {
                fraction = (score / 2.0) - index;
              }

              IconData icon = Icons.star_border;
              if (fraction >= 0.75) {
                icon = Icons.star;
              } else if (fraction >= 0.25) {
                icon = Icons.star_half;
              }

              return GestureDetector(
                onTap: canEdit
                    ? () {
                        double newScore;
                        if (_ratingScale == 5) {
                          newScore = (index + 1).toDouble();
                        } else if (_ratingScale == 100) {
                          newScore = (index + 1) * 20.0;
                        } else {
                          newScore = (index + 1) * 2.0;
                        }
                        provider.updateScore(newScore);
                      }
                    : null,
                child: Icon(icon, color: Colors.amber, size: 28),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalRating(BuildContext context, double extRating, String? ratingSource) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.public, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            'Valoración General',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              double starValue = extRating / 2;
              double diff = starValue - index;
              IconData icon = Icons.star_border;
              if (diff >= 0.75) {
                icon = Icons.star;
              } else if (diff >= 0.25) {
                icon = Icons.star_half;
              }
              return Icon(icon, color: Colors.amber, size: 16);
            }),
          ),
          const SizedBox(width: 8),
          Text(
            extRating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blueAccent,
            ),
          ),
          if (ratingSource != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
              ),
              child: Text(
                ratingSource,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatScore(double score) {
    if (_ratingScale == 5) {
      return '${score.toStringAsFixed(1)} / 5';
    } else if (_ratingScale == 100) {
      return '${score.toStringAsFixed(0)} / 100';
    }
    return '${score.toStringAsFixed(1)} / 10';
  }
}
