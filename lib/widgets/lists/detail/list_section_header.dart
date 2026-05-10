import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/responsive_provider.dart';

class ListSectionHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  final VoidCallback onTap;
  final double? totalPrice;

  const ListSectionHeader({
    super.key,
    required this.title,
    required this.isCollapsed,
    required this.onTap,
    this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final responsive = context.read<ResponsiveProvider>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: const EdgeInsets.only(top: 24.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: responsive.sectionHeaderFontSize,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (totalPrice != null && totalPrice! > 0)
                    Text(
                      "${totalPrice!.toStringAsFixed(2)}€",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              isCollapsed
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: colorScheme.primary.withValues(alpha: 0.5),
              size: responsive.sectionHeaderFontSize + 6,
            ),
          ],
        ),
      ),
    );
  }
}
