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

  const EntryDatesSection({
    super.key,
    required this.acquisitionDate,
    required this.startDate,
    required this.completionDate,
    required this.onAcquisitionDateChanged,
    required this.onStartDateChanged,
    required this.onCompletionDateChanged,
    this.tracksDates = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!tracksDates) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Fechas Importantes"),
        const SizedBox(height: 12),
        _buildDatePicker(context, "Adquisición", acquisitionDate, onAcquisitionDateChanged, Icons.shopping_bag_outlined),
        _buildDatePicker(context, "Inicio", startDate, onStartDateChanged, Icons.play_arrow_outlined),
        _buildDatePicker(context, "Finalización", completionDate, onCompletionDateChanged, Icons.done_all_rounded),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context, 
    String label, 
    int? timestamp, 
    Function(int?) onChanged,
    IconData icon,
  ) {
    final dateStr = timestamp != null 
        ? DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(timestamp))
        : "No establecida";

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(dateStr),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (timestamp != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () => onChanged(null),
            ),
          const Icon(Icons.calendar_month_rounded, size: 20),
        ],
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onChanged(picked.millisecondsSinceEpoch);
        }
      },
      contentPadding: EdgeInsets.zero,
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
