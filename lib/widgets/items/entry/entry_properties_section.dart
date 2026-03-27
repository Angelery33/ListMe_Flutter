import 'package:flutter/material.dart';

class EntryPropertiesSection extends StatelessWidget {
  final String? genre;
  final List<String> availableGenres;
  final Function(String?) onGenreChanged;
  final TextEditingController priceController;
  final bool wishlist;
  final Function(bool) onWishlistChanged;
  final double score;
  final Function(double) onScoreChanged;
  final bool supportsPrice;

  const EntryPropertiesSection({
    super.key,
    required this.genre,
    required this.availableGenres,
    required this.onGenreChanged,
    required this.priceController,
    required this.wishlist,
    required this.onWishlistChanged,
    required this.score,
    required this.onScoreChanged,
    this.supportsPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Categorización y Valoración"),
        const SizedBox(height: 16),

        // Género / Categoría
        DropdownButtonFormField<String>(
          initialValue: genre,
          decoration: InputDecoration(
            labelText: "Género / Categoría",
            prefixIcon: const Icon(Icons.category_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: [
            const DropdownMenuItem(value: null, child: Text("Sin categoría")),
            ...availableGenres.map((g) => DropdownMenuItem(value: g, child: Text(g))),
          ],
          onChanged: onGenreChanged,
        ),
        const SizedBox(height: 16),

        // Precio (opcional)
        if (supportsPrice) ...[
          TextFormField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Precio pagado",
              prefixIcon: const Icon(Icons.euro_rounded),
              suffixText: "€",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Wishlist Toggle
        SwitchListTile(
          title: const Text("En lista de deseos"),
          subtitle: const Text("Marcar si aún no lo has adquirido"),
          value: wishlist,
          onChanged: onWishlistChanged,
          secondary: Icon(Icons.wallet_giftcard_rounded, 
            color: wishlist ? Colors.orangeAccent : null),
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 16),

        // Puntuación
        _buildScoreSlider(context),
      ],
    );
  }

  Widget _buildScoreSlider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Puntuación Personal", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                score.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
              ),
            ),
          ],
        ),
        Slider(
          value: score,
          min: 0,
          max: 10,
          divisions: 20,
          label: score.toStringAsFixed(1),
          onChanged: onScoreChanged,
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
