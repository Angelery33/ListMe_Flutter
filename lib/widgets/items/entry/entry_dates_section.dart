import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EntryDatesSection extends StatelessWidget {
  final int? acquisitionDate;
  final int? startDate;
  final int? completionDate;
  final Function(int?) onAcquisitionDateChanged;
  final Function(int?) onStartDateChanged;
  final Function(int?) onCompletionDateChanged;
  final bool tracksDates;
  final bool supportsWishlist;
  final bool isWishlist;
  final bool isCollection;
  final Function(bool) onWishlistChanged;
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
            _buildSectionTitle(context, "Fechas y Detalles"),
            const SizedBox(height: 12),

            if (tracksDates) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: 'Inicio',
                      timestamp: startDate,
                      onTap: () =>
                          _selectDate(context, startDate, onStartDateChanged),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDatePicker(
                      context: context,
                      label: 'Finalización',
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
                title: const Text("Lista de Deseos"),
                subtitle: const Text("Marcar si aún no lo has adquirido"),
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
                  label: 'Fecha Adquisición',
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
              title: const Text("Es una Colección"),
              subtitle: const Text("Permite añadir sub-ítems a este elemento"),
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
        : "No establecida";

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
