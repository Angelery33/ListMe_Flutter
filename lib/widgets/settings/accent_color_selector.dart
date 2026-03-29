import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../providers/settings/settings_provider.dart';

/// Widget especializado para seleccionar el color de acento (gemas).
class AccentColorSelector extends StatelessWidget {
  final SettingsProvider settings;

  const AccentColorSelector({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final accents = ['amethyst', 'sapphire', 'ruby', 'emerald', 'amber', 'cobalt', 'cyan', 'magenta', 'titanium'];

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accents.length,
        itemBuilder: (context, index) {
          final accent = accents[index];
          final isSelected = settings.accentColor == accent;
          final color = AppTheme.getPrimaryColor(accent, Theme.of(context).brightness);

          return GestureDetector(
            onTap: () => settings.setAccentColor(accent),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ] : [],
              ),
              child: isSelected 
                ? const Icon(Icons.check, color: Colors.white, size: 20) 
                : null,
            ),
          );
        },
      ),
    );
  }
}
