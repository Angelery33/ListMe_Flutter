import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/lists/list_model.dart';

/// [AppBar] personalizado para la pantalla de detalles de la biblioteca.
///
/// Implementa [PreferredSizeWidget] para que pueda colocarse directamente en un
/// espacio [Scaffold.appBar] slot. Su altura preferida se expande en 50 dp cuando el
/// campo de búsqueda en línea es visible ([isSearchVisible]).
///
/// La barra contiene:
/// - Un botón opcional de navegación hacia atrás (se muestra solo cuando hay una ruta para regresar).
/// - Un botón de alternancia de búsqueda.
/// - El nombre de la biblioteca y el logo de la aplicación como título centrado.
/// - Un botón opcional de alternancia de vista de tabla/lista.
/// - Un menú emergente con acciones sensibles al contexto (compartir, editar, sincronizar, eliminar).
/// - Un campo de texto de búsqueda en línea expandible en la parte inferior.
class ListDetailAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// El modelo de biblioteca cuyo nombre se muestra en la barra de título.
  final ListModel list;

  /// Controlador para el campo de texto de búsqueda en línea que se muestra cuando [isSearchVisible] es `true`.
  final TextEditingController searchController;

  /// Se llama cuando el usuario toca la acción de configuración (engranaje): navega a la configuración de la lista.
  final VoidCallback onSettingsPressed;

  /// Se llama cuando el usuario selecciona un elemento del menú desplegable emergente.
  /// El valor pasado es la clave del elemento del menú (ej. `'share'`, `'edit'`, `'delete'`).
  final void Function(String)? onMenuSelected;

  /// Se llama cuando el usuario toca la acción de compartir.
  final VoidCallback onSharePressed;

  /// Se llama cuando el usuario toca el icono de búsqueda para alternar la barra de búsqueda en línea.
  final VoidCallback onSearchToggle;

  /// Indica si el campo de texto de búsqueda en línea está actualmente visible.
  /// Controla tanto la altura preferida de la barra como el estado del icono de búsqueda.
  final bool isSearchVisible;

  /// Indica si esta lista se está viendo en modo "nube" (compartida por otro usuario).
  /// Algunas acciones del menú (como "compartir") se ocultan en el modo nube.
  final bool isCloud;

  /// Indica si el usuario actual tiene permisos de edición para esta biblioteca.
  final bool canEdit;

  /// Función de retorno opcional para la acción de menú "sincronizar". Cuando es `null`, el elemento
  /// de sincronización se omite del menú emergente.
  final VoidCallback? onSyncPressed;

  /// Función de retorno opcional para la acción de menú "editar". Cuando es `null`, el elemento
  /// de edición se omite del menú emergente.
  final VoidCallback? onEditPressed;

  /// Función de retorno opcional para la acción de menú "subir".
  final VoidCallback? onUploadPressed;

  /// Indica si se muestra el botón de alternancia de vista de tabla/lista en el área de acciones.
  final bool showTableToggle;

  /// Indica si la biblioteca se muestra actualmente en vista de tabla (frente a vista de lista de tarjetas).
  /// Controla el icono mostrado en el botón de alternancia.
  final bool isTableView;

  /// Se llama cuando el usuario toca el botón de alternancia de tabla/lista.
  final VoidCallback? onTableToggle;

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
    this.showTableToggle = false,
    this.isTableView = false,
    this.onTableToggle,
  });

  @override
  State<ListDetailAppBar> createState() => _ListDetailAppBarState();

  /// Expande la altura preferida en 50 dp cuando la barra de búsqueda es visible.
  @override
  Size get preferredSize =>
      Size.fromHeight(isSearchVisible ? kToolbarHeight + 50 : kToolbarHeight);
}

/// Estado para [ListDetailAppBar].
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
        if (widget.showTableToggle)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: TextButton.icon(
              icon: Icon(
                widget.isTableView ? Icons.view_list_rounded : Icons.table_chart_rounded,
                size: 20,
              ),
              label: Text(
                widget.isTableView ? 'Vista normal' : 'Vista tabla',
                style: const TextStyle(fontSize: 13),
              ),
              style: TextButton.styleFrom(
                foregroundColor: widget.isTableView
                    ? Theme.of(context).colorScheme.onPrimary
                    : textColor,
                backgroundColor: widget.isTableView
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: widget.onTableToggle,
            ),
          ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: textColor),
          onSelected: widget.onMenuSelected,
          itemBuilder: (context) => [
            if (widget.list.owner && !widget.isCloud)
              PopupMenuItem(
                value: 'share',
                child: Text(context.l10n.listsShareTitle),
              ),
            if (widget.list.owner && widget.onEditPressed != null)
              PopupMenuItem(value: 'edit', child: Text(context.l10n.commonEdit)),
            if (widget.onSyncPressed != null)
              PopupMenuItem(value: 'sync', child: Text(context.l10n.commonSync)),
            if (widget.list.owner)
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  context.l10n.listsDeleteTitle,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            // Visible solo para colaboradores (no propietarios) en listas compartidas
            if (!widget.list.owner && widget.list.shared)
              const PopupMenuItem(
                value: 'leave',
                child: Text(
                  'Abandonar lista',
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
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
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
