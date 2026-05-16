import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/items/item_model.dart';
import '../../../data/lists/list_model.dart';
import '../../../providers/items/items_provider.dart';
import '../../../providers/lists/lists_provider.dart';

// ─── Column definition ────────────────────────────────────────────────────────

/// Identifica cada columna posible en la vista de tabla.
enum _Col { name, status, score, genre, progress, price, wishlist }

/// Empareja un identificador [_Col] con su etiqueta de visualización y ancho flex relativo.
class _ColDef {
  final _Col col;
  final String label;
  final int flex;
  const _ColDef(this.col, this.label, this.flex);
}

// ─── Main widget ──────────────────────────────────────────────────────────────

/// Vista de tabla estilo hoja de cálculo para los elementos de una biblioteca.
///
/// Renderiza una fila de encabezado fija seguida de una lista desplazable de filas de datos.
/// Las columnas se derivan de los indicadores de características de la biblioteca (puntuación, género, progreso,
/// precio, lista de deseos), por lo que solo se muestran los datos relevantes.
///
/// Las celdas individuales se pueden editar en línea: al tocar se abre un pequeño diálogo para valores de texto/
/// numéricos, o un desplegable emergente para las celdas de estado y género.
class ListTableView extends StatefulWidget {
  /// El modelo de biblioteca que controla qué columnas son visibles.
  final ListModel list;

  /// El conjunto inicial de elementos para mostrar. El widget mantiene su propia copia ordenada
  /// internamente para que la lista principal no necesite estar ordenada.
  final List<ItemModel> items;

  const ListTableView({
    super.key,
    required this.list,
    required this.items,
  });

  @override
  State<ListTableView> createState() => _ListTableViewState();
}

/// Estado para [ListTableView].
///
/// Gestiona la lista de filas ordenadas mutables, la columna/dirección de ordenación activa
/// y los nombres de género cargados de forma diferida para las celdas desplegables de género.
class _ListTableViewState extends State<ListTableView> {
  /// La copia de trabajo, posiblemente ordenada, de la lista de elementos.
  late List<ItemModel> _rows;

  /// La columna utilizada actualmente para la ordenación, o `null` para ninguna ordenación.
  _Col? _sortCol;

  /// Indica si la ordenación actual es ascendente (`true`) o descendente (`false`).
  bool _sortAsc = true;

  /// Nombres de género cargados desde el servidor para las celdas desplegables de género.
  List<String> _genres = [];

  @override
  void initState() {
    super.initState();
    _rows = List.of(widget.items);
    if (widget.list.thematic && widget.list.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadGenres());
    }
  }

  /// Obtiene los nombres de género para la biblioteca de [ListsProvider] y los almacena
  /// para que las celdas de género puedan mostrar un desplegable en lugar de un campo de texto libre.
  Future<void> _loadGenres() async {
    final loaded = await context
        .read<ListsProvider>()
        .getLibraryGenres(widget.list.id!);
    if (mounted) setState(() => _genres = loaded.map((g) => g.name).toList());
  }

  @override
  void didUpdateWidget(ListTableView old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      _rows = List.of(widget.items);
      if (_sortCol != null) _doSort();
    }
  }

  /// Crea la lista de definiciones de columnas visibles basadas en los indicadores de la biblioteca.
  List<_ColDef> get _cols {
    final l = widget.list;
    return [
      _ColDef(_Col.name, '', 3),
      if (l.supportsCompletion) _ColDef(_Col.status, '', 1),
      if (l.gradeable) _ColDef(_Col.score, '', 1),
      if (l.thematic) _ColDef(_Col.genre, '', 2),
      if (l.supportsProgress) _ColDef(_Col.progress, '', 3),
      if (l.supportsPrice) _ColDef(_Col.price, '', 1),
      if (l.supportsWishlist) _ColDef(_Col.wishlist, '', 1),
    ];
  }

  /// Alterna o cambia la columna de ordenación activa y vuelve a ordenar [_rows].
  ///
  /// Al tocar la misma columna se invierte la dirección de ordenación; al tocar una columna diferente
  /// se restablece a ascendente.
  void _toggleSort(_Col col) {
    setState(() {
      if (_sortCol == col) {
        _sortAsc = !_sortAsc;
      } else {
        _sortCol = col;
        _sortAsc = true;
      }
      _doSort();
    });
  }

  /// Ordena [_rows] en el lugar según [_sortCol] y [_sortAsc].
  void _doSort() {
    _rows.sort((a, b) {
      int cmp;
      switch (_sortCol) {
        case _Col.name:
          cmp = a.name.compareTo(b.name);
          break;
        case _Col.status:
          cmp = (a.status ?? '').compareTo(b.status ?? '');
          break;
        case _Col.score:
          cmp = (a.score ?? 0).compareTo(b.score ?? 0);
          break;
        case _Col.genre:
          cmp = (a.genre ?? '').compareTo(b.genre ?? '');
          break;
        case _Col.progress:
          cmp = (a.currentProgress ?? a.chapter ?? 0)
              .compareTo(b.currentProgress ?? b.chapter ?? 0);
          break;
        case _Col.price:
          cmp = (a.price ?? 0).compareTo(b.price ?? 0);
          break;
        default:
          cmp = 0;
      }
      return _sortAsc ? cmp : -cmp;
    });
  }

  /// Reemplaza la fila de [updated] en [_rows] y vuelve a aplicar la ordenación actual.
  void _updateRow(ItemModel updated) {
    setState(() {
      final idx = _rows.indexWhere((r) => r.id == updated.id);
      if (idx != -1) _rows[idx] = updated;
      if (_sortCol != null) _doSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cols = _cols;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _HeaderRow(
            cols: cols,
            sortCol: _sortCol,
            sortAsc: _sortAsc,
            onSort: _toggleSort,
            list: widget.list,
          ),
          Divider(height: 1, color: theme.dividerColor),
          // Rows
          Expanded(
            child: _rows.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.listEmptyTitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, i) => _DataRow(
                      item: _rows[i],
                      cols: cols,
                      list: widget.list,
                      genres: _genres,
                      isEven: i.isEven,
                      onUpdated: (updated) async {
                        _updateRow(updated);
                        final ok = await context
                            .read<ItemsProvider>()
                            .updateItem(updated.id!, updated);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  ok ? Icons.check_circle_outline : Icons.error_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(ok
                                    ? '${updated.name} — guardado'
                                    : 'Error al guardar ${updated.name}'),
                              ],
                            ),
                            duration: Duration(seconds: ok ? 2 : 4),
                            backgroundColor: ok
                                ? Colors.green.shade700
                                : Theme.of(context).colorScheme.error,
                            behavior: SnackBarBehavior.floating,
                            width: 340,
                          ),
                        );
                      },
                    ),
                  ),
          ),
          // Footer count
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_rows.length} ${_rows.length == 1 ? context.l10n.commonItem : context.l10n.commonItems}',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header row ───────────────────────────────────────────────────────────────

/// Fila de encabezado fija que renderiza etiquetas de columna e indicadores de ordenación.
///
/// Al tocar un encabezado de columna se llama a [onSort] para cambiar la ordenación activa.
class _HeaderRow extends StatelessWidget {
  /// La lista ordenada de definiciones de columnas para renderizar.
  final List<_ColDef> cols;

  /// La columna utilizada actualmente para la ordenación, o `null` para sin ordenar.
  final _Col? sortCol;

  /// Indica si la dirección de ordenación actual es ascendente.
  final bool sortAsc;

  /// Se llama cuando el usuario toca un encabezado de columna para ordenar por esa columna.
  final void Function(_Col) onSort;

  /// El modelo de biblioteca, utilizado para resolver las etiquetas de columna localizadas.
  final ListModel list;

  const _HeaderRow({
    required this.cols,
    required this.sortCol,
    required this.sortAsc,
    required this.onSort,
    required this.list,
  });

  /// Devuelve la etiqueta de visualización localizada para una columna.
  String _label(BuildContext ctx, _Col col) {
    switch (col) {
      case _Col.name: return ctx.l10n.itemName;
      case _Col.status: return ctx.l10n.statusStatusCurrent;
      case _Col.score: return ctx.l10n.itemScore;
      case _Col.genre: return ctx.l10n.itemGenre;
      case _Col.progress: return ctx.l10n.progressProgress;
      case _Col.price: return ctx.l10n.itemPrice;
      case _Col.wishlist: return ctx.l10n.groupWishlist;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: cols.map((c) {
          final active = sortCol == c.col;
          return Expanded(
            flex: c.flex,
            child: c.col == _Col.wishlist
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: () => onSort(c.col),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _label(context, c.col),
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: active
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          active
                              ? (sortAsc
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded)
                              : Icons.unfold_more_rounded,
                          size: 14,
                          color: active
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Data row ─────────────────────────────────────────────────────────────────

/// Una única fila de datos en la tabla que renderiza un [ItemModel].
///
/// Alterna el color de fondo entre filas pares e impares para mayor legibilidad.
/// Cada celda se puede editar de forma independiente a través de diálogos en línea o desplegables.
class _DataRow extends StatelessWidget {
  /// El elemento cuyos datos se renderizan a través de las celdas de la fila.
  final ItemModel item;

  /// Definiciones de columnas que controlan qué celdas se renderizan y sus anchos.
  final List<_ColDef> cols;

  /// El modelo de biblioteca utilizado para buscar el tipo de progreso y la escala de puntuación.
  final ListModel list;

  /// Nombres de género disponibles para la celda desplegable de género.
  final List<String> genres;

  /// Indica si esta fila tiene un índice par, se utiliza para alternar los colores de fondo.
  final bool isEven;

  /// Se llama cuando se confirma la edición de una celda con el [ItemModel] actualizado.
  /// El llamador es responsable de persistir el cambio en el backend.
  final void Function(ItemModel) onUpdated;

  const _DataRow({
    required this.item,
    required this.cols,
    required this.list,
    required this.genres,
    required this.isEven,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: isEven
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Row(
        children: cols.map((c) => Expanded(
          flex: c.flex,
          child: _buildCell(context, c.col),
        )).toList(),
      ),
    );
  }

  /// Selecciona y construye el widget de celda apropiado para la [col] dada.
  Widget _buildCell(BuildContext context, _Col col) {
    switch (col) {
      case _Col.name:
        return _TapToEditCell(
          display: item.name,
          dialogTitle: context.l10n.itemName,
          initialValue: item.name,
          onSaved: (v) {
            if (v.isNotEmpty) onUpdated(item.copyWith(name: v));
          },
          bold: true,
        );

      case _Col.status:
        return _StatusCell(
          item: item,
          onChanged: (s) => onUpdated(item.copyWith(status: s)),
        );

      case _Col.score:
        return _TapToEditCell(
          display: item.score != null ? item.score!.toStringAsFixed(1) : '—',
          dialogTitle: context.l10n.itemScore,
          initialValue: item.score?.toString() ?? '',
          suffix: '/${list.ratingScale ?? 10}',
          isNumeric: true,
          onSaved: (v) {
            final d = double.tryParse(v);
            if (d != null) onUpdated(item.copyWith(score: d));
          },
        );

      case _Col.genre:
        return _GenreCell(
          current: item.genre,
          genres: genres,
          onChanged: (g) => onUpdated(item.copyWith(genre: g.isEmpty ? null : g)),
        );

      case _Col.progress:
        return _ProgressCell(
          item: item,
          list: list,
          onUpdated: onUpdated,
        );

      case _Col.price:
        return _TapToEditCell(
          display: item.price != null ? '${item.price!.toStringAsFixed(2)} €' : '—',
          dialogTitle: context.l10n.itemPrice,
          initialValue: item.price?.toString() ?? '',
          suffix: ' €',
          isNumeric: true,
          onSaved: (v) {
            final d = double.tryParse(v);
            if (d != null) onUpdated(item.copyWith(price: d));
          },
        );

      case _Col.wishlist:
        return Transform.scale(
          scale: 0.85,
          alignment: Alignment.centerLeft,
          child: Checkbox(
            value: item.wishlist,
            onChanged: (v) => onUpdated(item.copyWith(wishlist: v ?? false)),
          ),
        );
    }
  }
}

// ─── Status cell ──────────────────────────────────────────────────────────────

/// Celda de tabla que muestra el estado actual del elemento como un punto coloreado + etiqueta
/// y abre un menú emergente para cambiarlo.
class _StatusCell extends StatelessWidget {
  /// El elemento cuyo estado se muestra.
  final ItemModel item;

  /// Se llama con la nueva clave de estado cuando el usuario selecciona una opción diferente.
  final void Function(String) onChanged;

  const _StatusCell({required this.item, required this.onChanged});

  /// Todas las opciones de estado válidas con sus claves de visualización, claves l10n y colores.
  static const _options = [
    ('PENDING', 'statusPending', Color(0xFF9E9E9E)),
    ('IN_PROGRESS', 'statusInProgress', Color(0xFF2196F3)),
    ('PAUSED', 'statusPaused', Color(0xFFFF9800)),
    ('DROPPED', 'statusDropped', Color(0xFFF44336)),
    ('COMPLETED', 'statusCompleted', Color(0xFF4CAF50)),
  ];

  /// Devuelve la etiqueta localizada para una clave de [status] dada.
  String _label(BuildContext ctx, String status) {
    switch (status) {
      case 'PENDING': return ctx.l10n.statusPending;
      case 'IN_PROGRESS': return ctx.l10n.statusInProgress;
      case 'PAUSED': return ctx.l10n.statusPaused;
      case 'DROPPED': return ctx.l10n.statusDropped;
      case 'COMPLETED': return ctx.l10n.statusCompleted;
      default: return status;
    }
  }

  /// Devuelve el color asociado con la clave de estado dada.
  Color _color(String? s) {
    for (final (k, _, c) in _options) {
      if (k == s) return c;
    }
    return const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    final status = item.status ?? 'PENDING';
    final color = _color(status);
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 28),
      onSelected: onChanged,
      itemBuilder: (_) => _options.map((t) {
        final (k, _, c) = t;
        return PopupMenuItem(
          value: k,
          child: Row(children: [
            Container(width: 10, height: 10,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(_label(context, k),
                style: const TextStyle(fontSize: 13)),
          ]),
        );
      }).toList(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _label(context, status),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.arrow_drop_down, size: 14, color: color),
        ],
      ),
    );
  }
}

// ─── Genre cell with dropdown ─────────────────────────────────────────────────

/// Celda de tabla que muestra el género actual y permite al usuario elegir uno diferente
/// de un menú emergente, o recurre a un diálogo de texto libre cuando aún no se han configurado
/// géneros para la biblioteca.
class _GenreCell extends StatelessWidget {
  /// El género actual del elemento, o `null` si no está establecido.
  final String? current;

  /// La lista de nombres de género disponibles. Cuando está vacía, se muestra una celda de edición de
  /// texto libre en lugar de un desplegable.
  final List<String> genres;

  /// Se llama con la cadena de género seleccionada (una cadena vacía significa "borrar").
  final void Function(String) onChanged;

  const _GenreCell({
    required this.current,
    required this.genres,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (genres.isEmpty) {
      // fallback: free text if no genres configured yet
      return _TapToEditCell(
        display: current ?? '—',
        dialogTitle: context.l10n.itemGenre,
        initialValue: current ?? '',
        onSaved: onChanged,
      );
    }
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 28),
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: '',
          child: Text('—', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ),
        ...genres.map((g) => PopupMenuItem(
          value: g,
          child: Row(children: [
            if (current == g) ...[
              Icon(Icons.check, size: 14, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
            ] else
              const SizedBox(width: 20),
            Text(g),
          ]),
        )),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            current ?? '—',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: current == null
                  ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.arrow_drop_down, size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
        ],
      ),
    );
  }
}

// ─── Generic tap-to-edit cell ─────────────────────────────────────────────────

/// Celda de tabla que muestra una cadena [display] y abre un pequeño [AlertDialog]
/// con un campo de texto al tocarla, permitiendo al usuario editar el valor en línea.
class _TapToEditCell extends StatelessWidget {
  /// La cadena formateada que se muestra en la celda cuando no se está editando.
  final String display;

  /// El título del diálogo de edición.
  final String dialogTitle;

  /// El valor inicial pre-rellenado en el campo de texto del diálogo de edición.
  final String initialValue;

  /// Sufijo opcional añadido al campo de texto (ej. `"€"`, `"/10"`).
  final String suffix;

  /// Cuando es `true`, el teclado se configura como numérico y se filtran las entradas
  /// que no sean dígitos o puntos.
  final bool isNumeric;

  /// Cuando es `true`, el texto de visualización se renderiza con un peso seminegrita.
  final bool bold;

  /// Se llama con el nuevo valor de cadena cuando el usuario confirma el diálogo de edición.
  /// Solo se llama cuando el valor ha cambiado realmente.
  final void Function(String) onSaved;

  const _TapToEditCell({
    required this.display,
    required this.dialogTitle,
    required this.initialValue,
    this.suffix = '',
    this.isNumeric = false,
    this.bold = false,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmpty = display == '—';
    return GestureDetector(
      onTap: () => _edit(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              display,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                color: isEmpty
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.edit_rounded,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35)),
        ],
      ),
    );
  }

  /// Abre el diálogo de edición y llama a [onSaved] si el usuario confirma un cambio.
  void _edit(BuildContext context) async {
    final ctrl = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(dialogTitle),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
              : null,
          decoration: InputDecoration(
            suffixText: suffix.trim(),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          onTap: () => ctrl.selection = TextSelection(
            baseOffset: 0,
            extentOffset: ctrl.text.length,
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(ctx.l10n.commonSave),
          ),
        ],
      ),
    );
    if (result != null && result != initialValue) onSaved(result);
  }
}

// ─── Progress cell ────────────────────────────────────────────────────────────

/// Celda de tabla que muestra datos de progreso estructurados (temporadas, capítulos, páginas,
/// volúmenes o un contador genérico) como chips compactos, y abre un diálogo de varios campos
/// para editar al tocarla.
class _ProgressCell extends StatelessWidget {
  /// El elemento cuyos campos de progreso se renderizan.
  final ItemModel item;

  /// El modelo de biblioteca, utilizado para determinar el [ListModel.progressType].
  final ListModel list;

  /// Se llama con un [ItemModel] actualizado cuando el usuario guarda los cambios en el
  /// diálogo de edición de progreso.
  final void Function(ItemModel) onUpdated;

  const _ProgressCell({
    required this.item,
    required this.list,
    required this.onUpdated,
  });

  /// Formatea un valor de progreso como `"<unidad> <act>[/<tot>]"`.
  String _fmt(int cur, int? tot, String unit) {
    final t = (tot != null && tot > 0) ? '/$tot' : '';
    return '$unit $cur$t';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pt = list.progressType;

    final chips = <Widget>[];
    if (pt == 'Anime' || pt == 'Serie') {
      chips.add(_chip(context, _fmt(item.season ?? 0, item.totalSeason, 'T'), theme));
      chips.add(_chip(context, _fmt(item.chapter ?? 0, item.totalChapter, 'Ep'), theme));
    } else if (pt == 'Manga') {
      chips.add(_chip(context, _fmt(item.volume ?? 0, item.totalVolume, 'Vol'), theme));
      chips.add(_chip(context, _fmt(item.chapter ?? 0, item.totalChapter, 'Cap'), theme));
      if ((item.page ?? 0) > 0 || (item.totalPage ?? 0) > 0)
        chips.add(_chip(context, _fmt(item.page ?? 0, item.totalPage, 'Pág'), theme));
    } else if (pt == 'Libro') {
      chips.add(_chip(context, _fmt(item.chapter ?? 0, item.totalChapter, 'Cap'), theme));
      chips.add(_chip(context, _fmt(item.page ?? 0, item.totalPage, 'Pág'), theme));
    } else {
      chips.add(_chip(context, _fmt(item.currentProgress ?? 0, item.totalProgress, ''), theme));
    }

    return GestureDetector(
      onTap: () => _edit(context),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: chips,
            ),
          ),
          Icon(Icons.edit_rounded, size: 12,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.35)),
        ],
      ),
    );
  }

  /// Construye un pequeño chip en forma de píldora para mostrar una única etiqueta de segmento de progreso.
  Widget _chip(BuildContext context, String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label.trim(), style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
      )),
    );
  }

  /// Abre un diálogo de edición de progreso de varios campos apropiado para el
  /// [ListModel.progressType] de la biblioteca y llama a [onUpdated] cuando el usuario guarda.
  void _edit(BuildContext context) async {
    final pt = list.progressType;
    final fields = <String, (String label, TextEditingController ctrl, TextEditingController totCtrl)>{};

    if (pt == 'Anime' || pt == 'Serie') {
      fields['season'] = (context.l10n.progressSeason,
        TextEditingController(text: (item.season ?? 0).toString()),
        TextEditingController(text: (item.totalSeason ?? 0) > 0 ? (item.totalSeason!).toString() : ''));
      fields['chapter'] = (context.l10n.progressEpisode,
        TextEditingController(text: (item.chapter ?? 0).toString()),
        TextEditingController(text: (item.totalChapter ?? 0) > 0 ? (item.totalChapter!).toString() : ''));
    } else if (pt == 'Manga') {
      fields['volume'] = (context.l10n.progressVolume,
        TextEditingController(text: (item.volume ?? 0).toString()),
        TextEditingController(text: (item.totalVolume ?? 0) > 0 ? (item.totalVolume!).toString() : ''));
      fields['chapter'] = (context.l10n.progressChapter,
        TextEditingController(text: (item.chapter ?? 0).toString()),
        TextEditingController(text: (item.totalChapter ?? 0) > 0 ? (item.totalChapter!).toString() : ''));
      fields['page'] = (context.l10n.progressPage,
        TextEditingController(text: (item.page ?? 0).toString()),
        TextEditingController(text: (item.totalPage ?? 0) > 0 ? (item.totalPage!).toString() : ''));
    } else if (pt == 'Libro') {
      fields['chapter'] = (context.l10n.progressChapter,
        TextEditingController(text: (item.chapter ?? 0).toString()),
        TextEditingController(text: (item.totalChapter ?? 0) > 0 ? (item.totalChapter!).toString() : ''));
      fields['page'] = (context.l10n.progressPage,
        TextEditingController(text: (item.page ?? 0).toString()),
        TextEditingController(text: (item.totalPage ?? 0) > 0 ? (item.totalPage!).toString() : ''));
    } else {
      fields['progress'] = (context.l10n.progressProgress,
        TextEditingController(text: (item.currentProgress ?? 0).toString()),
        TextEditingController(text: (item.totalProgress ?? 0) > 0 ? (item.totalProgress!).toString() : ''));
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.progressProgress),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields.entries.map((e) {
              final (label, cur, tot) = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: cur,
                        autofocus: e.key == fields.keys.first,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: ctx.l10n.progressActual,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onTap: () => cur.selection = TextSelection(
                            baseOffset: 0, extentOffset: cur.text.length),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('/', style: TextStyle(fontSize: 18)),
                    ),
                    Expanded(
                      child: TextField(
                        controller: tot,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          labelText: ctx.l10n.progressTotal,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        onTap: () => tot.selection = TextSelection(
                            baseOffset: 0, extentOffset: tot.text.length),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.commonSave),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    int _v(TextEditingController c) => int.tryParse(c.text) ?? 0;
    int? _t(TextEditingController c) {
      final v = int.tryParse(c.text);
      return (v != null && v > 0) ? v : null;
    }
    if (pt == 'Anime' || pt == 'Serie') {
      final s = fields['season']!; final e = fields['chapter']!;
      onUpdated(item.copyWith(
        season: _v(s.$2), totalSeason: _t(s.$3),
        chapter: _v(e.$2), totalChapter: _t(e.$3),
      ));
    } else if (pt == 'Manga') {
      final vol = fields['volume']!; final ch = fields['chapter']!; final pg = fields['page']!;
      onUpdated(item.copyWith(
        volume: _v(vol.$2), totalVolume: _t(vol.$3),
        chapter: _v(ch.$2), totalChapter: _t(ch.$3),
        page: _v(pg.$2), totalPage: _t(pg.$3),
      ));
    } else if (pt == 'Libro') {
      final ch = fields['chapter']!; final pg = fields['page']!;
      onUpdated(item.copyWith(
        chapter: _v(ch.$2), totalChapter: _t(ch.$3),
        page: _v(pg.$2), totalPage: _t(pg.$3),
      ));
    } else {
      final pr = fields['progress']!;
      onUpdated(item.copyWith(
        currentProgress: _v(pr.$2), totalProgress: _t(pr.$3),
      ));
    }
  }
}
