import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/lists/list_model.dart';

class ListDetailAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ListModel list;
  final TextEditingController searchController;
  final VoidCallback onSettingsPressed;
  final void Function(String)? onMenuSelected;
  final VoidCallback onSharePressed;
  final VoidCallback onSearchToggle;
  final bool isSearchVisible;
  final bool isCloud;
  final bool canEdit;
  final VoidCallback? onSyncPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onUploadPressed;

  const ListDetailAppBar({
    super.key,
    required this.list,
    required this.searchController,
    required this.onSettingsPressed,
    this.onMenuSelected,
    required this.onSharePressed,
    required this.onSearchToggle,
    required this.isSearchVisible,
    this.isCloud = false,
    this.canEdit = true,
    this.onSyncPressed,
    this.onEditPressed,
    this.onUploadPressed,
  });

  @override
  State<ListDetailAppBar> createState() => _ListDetailAppBarState();

  @override
  Size get preferredSize =>
      Size.fromHeight(isSearchVisible ? kToolbarHeight + 50 : kToolbarHeight);
}

class _ListDetailAppBarState extends State<ListDetailAppBar> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isTitanium = AppTheme.isTitanium(scheme);
    final useDarkText = isTitanium;

    final textColor = useDarkText ? Colors.black87 : Colors.white;
    final hintColor = useDarkText ? Colors.black54 : Colors.white54;

    final canPop = Navigator.canPop(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: AppTheme.appBarGradient(context),
      automaticallyImplyLeading: false,
      centerTitle: true,
      leadingWidth: canPop ? 96 : 48,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canPop)
            IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: context.l10n.commonBack,
            ),
          IconButton(
            icon: Icon(
              widget.isSearchVisible ? Icons.search_off : Icons.search,
              color: textColor,
            ),
            onPressed: widget.onSearchToggle,
            tooltip: widget.isSearchVisible ? context.l10n.commonClose : context.l10n.commonSearch,
          ),
        ],
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/logobiblio.png',
            height: 35,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.bookmark_rounded, color: textColor, size: 28),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.list.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: textColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: textColor),
          onSelected: widget.onMenuSelected,
          itemBuilder: (context) => [
            if (!widget.isCloud)
              PopupMenuItem(
                value: 'share',
                child: Text(context.l10n.listsShareTitle),
              ),
            if (widget.canEdit && widget.onEditPressed != null)
              PopupMenuItem(value: 'edit', child: Text(context.l10n.commonEdit)),
            if (widget.onSyncPressed != null)
              PopupMenuItem(value: 'sync', child: Text(context.l10n.commonSync)),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                context.l10n.listsDeleteTitle,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ],
      bottom: widget.isSearchVisible
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchPlaceholder,
                    prefixIcon: Icon(Icons.search, color: hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    isDense: true,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
