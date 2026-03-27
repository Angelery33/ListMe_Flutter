import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/lists/list_model.dart';

class ListDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ListModel list;
  final TextEditingController searchController;
  final VoidCallback onSettingsPressed; // → Navega a ListConfigScreen
  final VoidCallback onMorePressed;     // → Menú opciones extra (eliminar)
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
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.2),
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
                const Icon(Icons.bookmark_rounded),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              list.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        if (list.shared || list.owner)
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: onSharePressed,
            tooltip: 'Compartir',
          ),
        // Acceso directo a los ajustes/configuración de esta lista
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: onSettingsPressed,
          tooltip: 'Ajustes de la lista',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
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
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(116); // 56 AppBar + 60 Bottom
}
