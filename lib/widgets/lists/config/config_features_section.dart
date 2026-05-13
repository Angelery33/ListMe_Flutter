import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

class ConfigFeaturesSection extends StatelessWidget {
  final bool supportsCompletion;
  final ValueChanged<bool> onSupportsCompletionChanged;
  
  final bool isGradeable;
  final ValueChanged<bool> onIsGradeableChanged;
  
  final bool isThematic;
  final ValueChanged<bool> onIsThematicChanged;
  
  final bool supportsWishlist;
  final ValueChanged<bool> onSupportsWishlistChanged;
  
  final bool tracksDates;
  final ValueChanged<bool> onTracksDatesChanged;
  
  final bool supportsPrice;
  final ValueChanged<bool> onSupportsPriceChanged;
  
  final bool isCompact;
  final ValueChanged<bool> onIsCompactChanged;
  
  final bool supportsProgress;
  final ValueChanged<bool> onSupportsProgressChanged;

  const ConfigFeaturesSection({
    super.key,
    required this.supportsCompletion,
    required this.onSupportsCompletionChanged,
    required this.isGradeable,
    required this.onIsGradeableChanged,
    required this.isThematic,
    required this.onIsThematicChanged,
    required this.supportsWishlist,
    required this.onSupportsWishlistChanged,
    required this.tracksDates,
    required this.onTracksDatesChanged,
    required this.supportsPrice,
    required this.onSupportsPriceChanged,
    required this.isCompact,
    required this.onIsCompactChanged,
    required this.supportsProgress,
    required this.onSupportsProgressChanged,
  });

  Widget _buildSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildSwitch(
              context.l10n.listConfigCompletion,
              context.l10n.listConfigCompletionSubtitle,
              supportsCompletion,
              onSupportsCompletionChanged,
              Icons.check_circle_outline,
            ),
            _buildSwitch(
              context.l10n.listConfigGradeable,
              context.l10n.listConfigGradeableSubtitle,
              isGradeable,
              onIsGradeableChanged,
              Icons.star_border,
            ),
            _buildSwitch(
              context.l10n.listConfigThematic,
              context.l10n.listConfigThematicSubtitle,
              isThematic,
              onIsThematicChanged,
              Icons.category_outlined,
            ),
            _buildSwitch(
              context.l10n.listConfigWishlist,
              context.l10n.listConfigWishlistSubtitle,
              supportsWishlist,
              onSupportsWishlistChanged,
              Icons.card_giftcard,
            ),
            _buildSwitch(
              context.l10n.listConfigTracksDates,
              context.l10n.listConfigTracksDatesSubtitle,
              tracksDates,
              onTracksDatesChanged,
              Icons.date_range,
            ),
            _buildSwitch(
              context.l10n.listConfigPrice,
              context.l10n.listConfigPriceSubtitle,
              supportsPrice,
              onSupportsPriceChanged,
              Icons.attach_money,
            ),
            _buildSwitch(
              context.l10n.listConfigCompact,
              context.l10n.listConfigCompactSubtitle,
              isCompact,
              onIsCompactChanged,
              Icons.view_comfy_alt_outlined,
            ),
            _buildSwitch(
              context.l10n.listConfigProgress,
              "Contabilizar páginas, capítulos, niveles...",
              supportsProgress,
              onSupportsProgressChanged,
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }
}
