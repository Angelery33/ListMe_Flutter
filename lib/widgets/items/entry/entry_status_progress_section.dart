import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/i18n/l10n_extension.dart';

/// Sección de formulario que combina el menú desplegable de estado del elemento, el interruptor de
/// "disfrutando ahora" y los campos de progreso específicos del tipo durante la entrada/edición de elementos.
///
/// Los campos de progreso mostrados dependen de [progressType]: serie/anime → temporada +
/// episodio; libro → página + volumen; manga → capítulo + volumen + página;
/// funko → cantidad; de lo contrario, se utiliza un par genérico de actual/total.
/// El interruptor "disfrutando ahora" solo está habilitado cuando el estado es 'IN_PROGRESS'.
class EntryStatusProgressSection extends StatefulWidget {
  /// El código de estado actual vinculado al menú desplegable (ej. 'PENDING',
  /// 'IN_PROGRESS', 'COMPLETED', 'DROPPED', 'PAUSED').
  final String status;

  /// Se llama con la nueva cadena de estado cuando cambia la selección del menú desplegable.
  final Function(String) onStatusChanged;

  /// Valor actual del interruptor de "disfrutando ahora".
  final bool isCurrent;

  /// Se llama cuando se alterna el interruptor de "disfrutando ahora". El interruptor está deshabilitado
  /// a menos que [status] sea 'IN_PROGRESS'.
  final Function(bool) onCurrentChanged;

  /// Indica si se deben renderizar campos de progreso debajo de los controles de estado.
  final bool supportsProgress;

  /// Determina qué conjunto de campos de progreso mostrar
  /// ('Serie', 'Anime', 'Libro', 'Manga', 'Funko' o nulo para genérico).
  final String? progressType;

  /// Controlador para el campo de progreso actual genérico.
  final TextEditingController? currentProgressController;

  /// Controlador para el campo de progreso total genérico.
  final TextEditingController? totalProgressController;

  /// Controlador para el campo de temporada actual (Serie/Anime).
  final TextEditingController? seasonController;

  /// Controlador para el campo de temporadas totales (Serie/Anime).
  final TextEditingController? totalSeasonController;

  /// Controlador para el campo de capítulo/episodio actual.
  final TextEditingController? chapterController;

  /// Controlador para el campo de capítulos/episodios totales.
  final TextEditingController? totalChapterController;

  /// Controlador para el campo de página actual.
  final TextEditingController? pageController;

  /// Controlador para el campo de páginas totales.
  final TextEditingController? totalPageController;

  /// Controlador para el campo de volumen actual.
  final TextEditingController? volumeController;

  /// Controlador para el campo de volúmenes totales.
  final TextEditingController? totalVolumeController;

  const EntryStatusProgressSection({
    super.key,
    required this.status,
    required this.onStatusChanged,
    required this.isCurrent,
    required this.onCurrentChanged,
    this.supportsProgress = false,
    this.progressType,
    this.currentProgressController,
    this.totalProgressController,
    this.seasonController,
    this.totalSeasonController,
    this.chapterController,
    this.totalChapterController,
    this.pageController,
    this.totalPageController,
    this.volumeController,
    this.totalVolumeController,
  });

  @override
  State<EntryStatusProgressSection> createState() =>
      _EntryStatusProgressSectionState();
}

/// Estado para [EntryStatusProgressSection]. Se reconstruye cuando cambia el estado
/// para que se refleje el estado de habilitado/deshabilitado del interruptor de "disfrutando ahora".
class _EntryStatusProgressSectionState
    extends State<EntryStatusProgressSection> {
  // FocusNodes para navegación entre el par actual/total de cada campo de progreso.
  final FocusNode _totalProgressFocus = FocusNode();
  final FocusNode _totalSeasonFocus = FocusNode();
  final FocusNode _totalChapterFocus = FocusNode();
  final FocusNode _totalPageFocus = FocusNode();
  final FocusNode _totalVolumeFocus = FocusNode();

  void _fillCurrentFromTotal(TextEditingController? current, TextEditingController? total) {
    if (current == null || total == null) return;
    if (total.text.isNotEmpty) current.text = total.text;
  }

  @override
  void dispose() {
    _totalProgressFocus.dispose();
    _totalSeasonFocus.dispose();
    _totalChapterFocus.dispose();
    _totalPageFocus.dispose();
    _totalVolumeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, context.l10n.itemSectionStatusProgress),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: widget.status,
              decoration: InputDecoration(
                labelText: context.l10n.statusStatusCurrent,
                prefixIcon: const Icon(Icons.star_half_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(value: "PENDING", child: Text(context.l10n.statusPending)),
                DropdownMenuItem(
                  value: "IN_PROGRESS",
                  child: Text(context.l10n.statusInProgress),
                ),
                DropdownMenuItem(value: "COMPLETED", child: Text(context.l10n.statusCompleted)),
                DropdownMenuItem(value: "DROPPED", child: Text(context.l10n.statusDropped)),
                DropdownMenuItem(value: "PAUSED", child: Text(context.l10n.statusPaused)),
              ],
              onChanged: (val) {
                if (val != null) {
                  widget.onStatusChanged(val);
                  if (val != "IN_PROGRESS" && widget.isCurrent) {
                    widget.onCurrentChanged(false);
                  }
                  // Al completar, rellenar el progreso actual con el total
                  if (val == "COMPLETED") {
                    _fillCurrentFromTotal(widget.currentProgressController, widget.totalProgressController);
                    _fillCurrentFromTotal(widget.seasonController, widget.totalSeasonController);
                    _fillCurrentFromTotal(widget.chapterController, widget.totalChapterController);
                    _fillCurrentFromTotal(widget.pageController, widget.totalPageController);
                    _fillCurrentFromTotal(widget.volumeController, widget.totalVolumeController);
                  }
                }
              },
            ),

            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text(context.l10n.statusEnjoying),
                subtitle: Text(
                  widget.status == "IN_PROGRESS"
                      ? context.l10n.statusEnjoyingSubtitle
                      : context.l10n.statusEnjoyingDisabled,
                ),
                value: widget.isCurrent,
                onChanged: widget.status == "IN_PROGRESS"
                    ? widget.onCurrentChanged
                    : null,
                secondary: Icon(
                  Icons.play_circle_outline_rounded,
                  color: widget.isCurrent
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
              ),
            ),

            if (widget.supportsProgress) ...[
              const Divider(height: 32),
              _buildProgressFields(context),
            ],
          ],
        ),
      ),
    );
  }

  /// Devuelve los widgets de campo de progreso apropiados para [progressType].
  /// Cada par de campos es renderizado por [_buildDoubleField].
  Widget _buildProgressFields(BuildContext context) {
    final progressType = widget.progressType;

    final l = context.l10n;
    if (progressType == "Serie" || progressType == "Anime") {
      return Column(
        children: [
          _buildDoubleField(context, l.progressSeason,
              widget.seasonController, widget.totalSeasonController, _totalSeasonFocus),
          const SizedBox(height: 12),
          _buildDoubleField(context, l.progressEpisode,
              widget.chapterController, widget.totalChapterController, _totalChapterFocus),
        ],
      );
    } else if (progressType == "Libro") {
      return Column(
        children: [
          _buildDoubleField(context, l.progressPage,
              widget.pageController, widget.totalPageController, _totalPageFocus),
          const SizedBox(height: 12),
          _buildDoubleField(context, l.progressVolume,
              widget.volumeController, widget.totalVolumeController, _totalVolumeFocus),
        ],
      );
    } else if (progressType == "Manga") {
      return Column(
        children: [
          _buildDoubleField(context, l.progressChapter,
              widget.chapterController, widget.totalChapterController, _totalChapterFocus),
          const SizedBox(height: 12),
          _buildDoubleField(context, l.progressVolume,
              widget.volumeController, widget.totalVolumeController, _totalVolumeFocus),
          const SizedBox(height: 12),
          _buildDoubleField(context, l.progressPage,
              widget.pageController, widget.totalPageController, _totalPageFocus),
        ],
      );
    } else if (progressType == "Funko") {
      return _buildDoubleField(context, l.progressQuantity,
          widget.currentProgressController, widget.totalProgressController, _totalProgressFocus);
    } else {
      return _buildDoubleField(context, l.progressProgress,
          widget.currentProgressController, widget.totalProgressController, _totalProgressFocus);
    }
  }

  /// Renderiza dos campos de texto numéricos uno al lado del otro para los valores [current] y [total]
  /// de una dimensión de progreso, separados por un divisor "/". Cualquier
  /// controlador puede ser nulo, en cuyo caso el campo correspondiente se omite.
  Widget _buildDoubleField(
    BuildContext context,
    String label,
    TextEditingController? current,
    TextEditingController? total,
    FocusNode totalFocus,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: current,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => totalFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: "$label ${context.l10n.progressActual}",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text("/", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: TextFormField(
            controller: total,
            focusNode: totalFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: context.l10n.progressTotal,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  /// Renderiza la etiqueta del encabezado de la sección con estilo en color primario en mayúsculas.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
