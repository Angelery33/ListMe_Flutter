import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/lists/list_model.dart';

class ListDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ListModel list;
  final TextEditingController searchController;
  final VoidCallback onSettingsPressed;
  final VoidCallback onMorePressed;
  final VoidCallback onSharePressed;

  const ListDetailAppBar({
    super.key,
    required this.list,
    required this.searchController,
    required this.onSettingsPressed,
    required this.onMorePressed,
    required this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTitanium = AppTheme.isTitanium(scheme);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useDarkText = isTitanium && !isDark;

    final textColor = useDarkText ? Colors.black87 : Colors.white;
    final hintColor = useDarkText ? Colors.black54 : Colors.white54;
    final iconColor = useDarkText ? Colors.black54 : Colors.white70;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: (useDarkText ? Colors.white : Colors.black).withValues(
              alpha: 0.2,
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.bookmark_rounded, color: textColor),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              list.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (list.shared || list.owner)
          IconButton(
            icon: Icon(Icons.share_rounded, color: textColor),
            onPressed: onSharePressed,
            tooltip: 'Compartir',
          ),
        IconButton(
          icon: Icon(Icons.settings_rounded, color: textColor),
          onPressed: onSettingsPressed,
          tooltip: 'Ajustes de la lista',
        ),
        IconButton(
          icon: Icon(Icons.more_vert_rounded, color: textColor),
          onPressed: onMorePressed,
          tooltip: 'Más opciones',
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: textColor.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: hintColor, fontSize: 14),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: iconColor,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(116);
}
