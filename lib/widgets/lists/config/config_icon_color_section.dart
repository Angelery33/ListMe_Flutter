import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

class ConfigIconColorSection extends StatelessWidget {
  final String selectedIcon;
  final String selectedColor;
  final ValueChanged<String> onIconChanged;
  final ValueChanged<String> onColorChanged;

  const ConfigIconColorSection({
    super.key,
    required this.selectedIcon,
    required this.selectedColor,
    required this.onIconChanged,
    required this.onColorChanged,
  });

  static const Map<String, IconData> icons = {
    'list': Icons.list_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'tv': Icons.tv_rounded,
    'book': Icons.book_rounded,
    'movie': Icons.movie_rounded,
    'games': Icons.sports_esports_rounded,
    'music': Icons.music_note_rounded,
    'restaurant': Icons.restaurant_rounded,
    'work': Icons.work_rounded,
    'fitness': Icons.fitness_center_rounded,
    'home': Icons.home_rounded,
    'favorite': Icons.favorite_rounded,
  };

  static const Map<String, Color> colors = {
    'emerald': Color(0xFF256A4A),
    'amethyst': Color(0xFF7D4E7E),
    'sapphire': Color(0xFF00796B),
    'ruby': Color(0xFF800020),
    'amber': Color(0xFFA66800),
    'cobalt': Color(0xFF2F48A8),
    'cyan': Color(0xFF00ACC1),
    'magenta': Color(0xFFC2185B),
    'titanium': Color(0xFF1D1B1E),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.listConfigIconAndColor,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.listConfigSelectIcon),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: icons.entries.map((entry) {
                  final isSelected = selectedIcon == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Icon(
                        entry.value, 
                        size: 20, 
                        color: isSelected ? Colors.white : theme.colorScheme.onSurfaceVariant
                      ),
                      selected: isSelected,
                      onSelected: (selected) { if (selected) onIconChanged(entry.key); },
                      selectedColor: theme.colorScheme.primary,
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.listConfigSelectColor),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: colors.entries.map((entry) {
                  final isSelected = selectedColor == entry.key;
                  return GestureDetector(
                    onTap: () => onColorChanged(entry.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: entry.value.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                      child: isSelected 
                        ? const Icon(Icons.check, size: 16, color: Colors.white) 
                        : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
