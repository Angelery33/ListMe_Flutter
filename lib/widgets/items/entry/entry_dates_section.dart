import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import 'package:intl/intl.dart';

/// Una sección de formulario que maneja la selección de fechas, el interruptor de lista de deseos y el
/// interruptor de colección durante la entrada/edición de elementos.
///
/// Renderiza condicionalmente solo los controles que son relevantes: los selectores de fechas
/// se muestran cuando [tracksDates] es verdadero; el interruptor de lista de deseos y la fecha de adquisición
/// solo cuando [supportsWishlist] es verdadero; el interruptor de colección siempre se
/// muestra. Devuelve un widget vacío cuando no se necesitan ni las fechas ni la lista de deseos.
class EntryDatesSection extends StatelessWidget {
  /// Fecha de adquisición actual en milisegundos desde la época, o nulo si no está establecida.
  final int? acquisitionDate;

  /// Fecha de inicio actual en milisegundos desde la época, o nulo si no está establecida.
  final int? startDate;

  /// Fecha de finalización actual en milisegundos desde la época, o nulo si no está establecida.
  final int? completionDate;

  /// Se llama con la nueva marca de tiempo (o nulo para borrar) cuando el selector de fecha de
  /// adquisición confirma una selección.
  final Function(int?) onAcquisitionDateChanged;

  /// Se llama con la nueva marca de tiempo (o nulo para borrar) cuando el selector de fecha de
  /// inicio confirma una selección.
  final Function(int?) onStartDateChanged;

  /// Se llama con la nueva marca de tiempo (o nulo para borrar) cuando el selector de fecha de
  /// finalización confirma una selección.
  final Function(int?) onCompletionDateChanged;

  /// Indica si se deben renderizar los selectores de fecha de inicio y finalización.
  final bool tracksDates;

  /// Indica si se deben renderizar el interruptor de lista de deseos y el selector de fecha de adquisición.
  final bool supportsWishlist;

  /// Valor actual del interruptor de lista de deseos, vinculado al estado del formulario padre.
  final bool isWishlist;

  /// Valor actual del interruptor de colección, vinculado al estado del formulario padre.
  final bool isCollection;

  /// Se llama cuando el usuario cambia el valor del interruptor de lista de deseos.
  final Function(bool) onWishlistChanged;

  /// Se llama cuando el usuario cambia el valor del interruptor de colección.
  final Function(bool) onCollectionChanged;

  const EntryDatesSection({
    super.key,
    this.acquisitionDate,
    this.startDate,
    this.completionDate,
    required this.onAcquisitionDateChanged,
    required this.onStartDateChanged,
    required this.onCompletionDateChanged,
    this.tracksDates = true,
    this.supportsWishlist = false,
    this.isWishlist = false,
    this.isCollection = false,
    required this.onWishlistChanged,
    required this.onCollectionChanged,
  });

  /// Abre el selector de fechas de la plataforma preestablecido en [currentTimestamp] (o hoy),
  /// luego llama a [onChanged] con la fecha elegida en milisegundos desde la época.
  Future<void> _selectDate(
    BuildContext context,
    int? currentTimestamp,
    Function(int?) onChanged,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(currentTimestamp)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked.millisecondsSinceEpoch);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = tracksDates || supportsWishlist;
    if (!hasContent) return const SizedBox.shrink();

    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, context.l10n.itemSectionDates),
            const SizedBox(height: 12),

            if (tracksDates) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: context.l10n.datesStart,
                      timestamp: startDate,
                      onTap: () =>
                          _selectDate(context, startDate, onStartDateChanged),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: context.l10n.datesCompletion,
                      timestamp: completionDate,
                      onTap: () => _selectDate(
                        context,
                        completionDate,
                        onCompletionDateChanged,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            if (supportsWishlist) ...[
              SwitchListTile(
                title: Text(context.l10n.listConfigWishlist),
                subtitle: Text(context.l10n.listConfigWishlistSubtitle),
                secondary: Icon(
                  Icons.card_giftcard,
                  color: isWishlist ? Colors.orangeAccent : null,
                ),
                value: isWishlist,
                onChanged: onWishlistChanged,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              if (!isWishlist) ...[
                _buildDatePicker(
                  context: context,
                  label: context.l10n.datesAcquisitionShort,
                  timestamp: acquisitionDate,
                  onTap: () => _selectDate(
                    context,
                    acquisitionDate,
                    onAcquisitionDateChanged,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],

            SwitchListTile(
              title: Text(context.l10n.collectionTitle),
              subtitle: Text(context.l10n.collectionAddItem),
              secondary: const Icon(Icons.collections_bookmark_outlined),
              value: isCollection,
              onChanged: onCollectionChanged,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  /// Renderiza un [InputDecorator] pulsable que parece un campo de texto que muestra
  /// el [timestamp] formateado como dd/MM/yyyy, o una sugerencia cuando no hay fecha establecida.
  /// Llama a [onTap] cuando se pulsa el campo para activar el selector de fechas.
  Widget _buildDatePicker({
    required BuildContext context,
    required String label,
    required int? timestamp,
    required VoidCallback onTap,
  }) {
    final dateStr = timestamp != null
        ? DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.fromMillisecondsSinceEpoch(timestamp))
        : context.l10n.datesNotSet;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          dateStr,
          style: TextStyle(
            color: timestamp != null
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).hintColor,
          ),
        ),
      ),
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
