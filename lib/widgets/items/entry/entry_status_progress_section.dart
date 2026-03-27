import 'package:flutter/material.dart';

class EntryStatusProgressSection extends StatelessWidget {
  final String status;
  final Function(String) onStatusChanged;
  final bool isCurrent;
  final Function(bool) onCurrentChanged;
  final bool supportsProgress;
  final String? progressType; // "Libro", "Serie", "Manual", etc.
  
  // Controllers para progreso detallado
  final TextEditingController? currentProgressController;
  final TextEditingController? totalProgressController;
  final TextEditingController? seasonController;
  final TextEditingController? totalSeasonController;
  final TextEditingController? chapterController;
  final TextEditingController? totalChapterController;

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Estado y Progreso"),
        const SizedBox(height: 16),
        
        // Selector de Estado
        DropdownButtonFormField<String>(
          initialValue: status,
          decoration: InputDecoration(
            labelText: "Estado actual",
            prefixIcon: const Icon(Icons.star_half_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: "PENDING", child: Text("Pendiente")),
            DropdownMenuItem(value: "IN_PROGRESS", child: Text("En Progreso")),
            DropdownMenuItem(value: "COMPLETED", child: Text("Completado")),
            DropdownMenuItem(value: "DROPPED", child: Text("Abandonado")),
            DropdownMenuItem(value: "PAUSED", child: Text("En Pausa")),
          ],
          onChanged: (val) => onStatusChanged(val ?? "PENDING"),
        ),
        
        const SizedBox(height: 16),
        
        // Toggle "Disfrutando ahora"
        SwitchListTile(
          title: const Text("Disfrutando ahora"),
          subtitle: const Text("Mostrar en la sección destacada de la lista"),
          value: isCurrent,
          onChanged: onCurrentChanged,
          secondary: Icon(Icons.play_circle_outline_rounded, 
            color: isCurrent ? Theme.of(context).colorScheme.primary : null),
          contentPadding: EdgeInsets.zero,
        ),

        if (supportsProgress) ...[
          const Divider(height: 32),
          _buildProgressFields(context),
        ],
      ],
    );
  }

  Widget _buildProgressFields(BuildContext context) {
    // Adaptar campos según el tipo
    if (progressType == "Serie" || progressType == "Anime") {
      return Column(
        children: [
          _buildDoubleField("Temporada", seasonController, totalSeasonController),
          const SizedBox(height: 12),
          _buildDoubleField("Episodio", chapterController, totalChapterController),
        ],
      );
    } else if (progressType == "Libro" || progressType == "Manga") {
      return _buildDoubleField("Página", currentProgressController, totalProgressController);
    } else {
      return _buildDoubleField("Progreso", currentProgressController, totalProgressController);
    }
  }

  Widget _buildDoubleField(String label, TextEditingController? current, TextEditingController? total) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: current,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "$label actual",
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
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Total",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
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
