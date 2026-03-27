import 'package:flutter/material.dart';

class ConfigFeaturesSection extends StatelessWidget {
  final bool supportsCompletion;
  final ValueChanged<bool> onSupportsCompletionChanged;
  
  final bool isGradeable;
  final ValueChanged<bool> onIsGradeableChanged;
  
  final bool isThematic;
  final ValueChanged<bool> onIsThematicChanged;
  
  final bool supportsWishlist;
  final ValueChanged<bool> onSupportsWishlistChanged;
  
  final bool tracksDates;
  final ValueChanged<bool> onTracksDatesChanged;
  
  final bool supportsPrice;
  final ValueChanged<bool> onSupportsPriceChanged;
  
  final bool isCompact;
  final ValueChanged<bool> onIsCompactChanged;
  
  final bool supportsProgress;
  final ValueChanged<bool> onSupportsProgressChanged;

  const ConfigFeaturesSection({
    super.key,
    required this.supportsCompletion,
    required this.onSupportsCompletionChanged,
    required this.isGradeable,
    required this.onIsGradeableChanged,
    required this.isThematic,
    required this.onIsThematicChanged,
    required this.supportsWishlist,
    required this.onSupportsWishlistChanged,
    required this.tracksDates,
    required this.onTracksDatesChanged,
    required this.supportsPrice,
    required this.onSupportsPriceChanged,
    required this.isCompact,
    required this.onIsCompactChanged,
    required this.supportsProgress,
    required this.onSupportsProgressChanged,
  });

  Widget _buildSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildSwitch(
              "Ítems Completables",
              "Permitir marcar ítems como completados",
              supportsCompletion,
              onSupportsCompletionChanged,
              Icons.check_circle_outline,
            ),
            _buildSwitch(
              "Es Calificable",
              "Permitir puntuar los ítems",
              isGradeable,
              onIsGradeableChanged,
              Icons.star_border,
            ),
            _buildSwitch(
              "Es Temática",
              "Organizar ítems por géneros personalizados",
              isThematic,
              onIsThematicChanged,
              Icons.category_outlined,
            ),
            _buildSwitch(
              "Lista de Deseos",
              "Soportar ítems deseados vs adquiridos",
              supportsWishlist,
              onSupportsWishlistChanged,
              Icons.card_giftcard,
            ),
            _buildSwitch(
              "Seguimiento de Fechas",
              "Registrar fechas de inicio y fin",
              tracksDates,
              onTracksDatesChanged,
              Icons.date_range,
            ),
            _buildSwitch(
              "Habilitar Precios",
              "Seguimiento de costes y presupuestos",
              supportsPrice,
              onSupportsPriceChanged,
              Icons.attach_money,
            ),
            _buildSwitch(
              "Vista Compacta",
              "Mostrar tarjetas más pequeñas en la lista",
              isCompact,
              onIsCompactChanged,
              Icons.view_comfy_alt_outlined,
            ),
            _buildSwitch(
              "Seguimiento de Progreso",
              "Contabilizar páginas, capítulos, niveles...",
              supportsProgress,
              onSupportsProgressChanged,
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }
}
