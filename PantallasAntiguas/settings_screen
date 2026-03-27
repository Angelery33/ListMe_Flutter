import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../app_theme.dart';
import '../components/responsive_container.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppTheme.getAppBarGradient(context),
        title: const Text('Ajustes'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ResponsiveContainer(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSection(context, 'Apariencia', [
                  _buildSettingTile(
                    context,
                    title: 'Tema de la aplicación',
                    subtitle: 'Elige el color principal',
                    trailing: DropdownButton<ThemeAccent>(
                      value: settings.themeAccent,
                      onChanged: (val) => settings.setThemeAccent(val!),
                      items: ThemeAccent.values.map((accent) {
                        return DropdownMenuItem(
                          value: accent,
                          child: Text(
                            _getAccentName(accent),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _buildSettingTile(
                    context,
                    title: 'Modo del tema',
                    subtitle: 'Claro, Oscuro o Automático',
                    trailing: DropdownButton<ThemeMode>(
                      value: settings.themeMode,
                      onChanged: (val) => settings.setThemeMode(val!),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Sistema'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Claro'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Oscuro'),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'Texto y Lectura', [
                  _buildSettingTile(
                    context,
                    title: 'Tamaño de fuente',
                    subtitle: 'Ajusta el tamaño del texto',
                    trailing: DropdownButton<double>(
                      value: settings.fontScale,
                      onChanged: (val) => settings.setFontScale(val!),
                      items: const [
                        DropdownMenuItem(
                          value: 0.85,
                          child: Text('Muy Pequeño'),
                        ),
                        DropdownMenuItem(value: 0.90, child: Text('Pequeño')),
                        DropdownMenuItem(value: 1.0, child: Text('Normal')),
                        DropdownMenuItem(value: 1.10, child: Text('Mediano')),
                        DropdownMenuItem(value: 1.25, child: Text('Grande')),
                        DropdownMenuItem(
                          value: 1.40,
                          child: Text('Muy Grande'),
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildSection(context, 'General', [
                  _buildSettingTile(
                    context,
                    title: 'Idioma',
                    subtitle: 'Selecciona tu idioma preferido',
                    trailing: DropdownButton<String>(
                      value: settings.language,
                      onChanged: (val) => settings.setLanguage(val!),
                      items: const [
                        DropdownMenuItem(value: 'es', child: Text('Español')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                    ),
                  ),
                  _buildSettingTile(
                    context,
                    title: 'Moneda predeterminada',
                    subtitle: 'Símbolo usado para precios',
                    trailing: DropdownButton<String>(
                      value: settings.currency,
                      onChanged: (val) => settings.setCurrency(val!),
                      items: [
                        const DropdownMenuItem(
                          value: '€',
                          child: Text('Euro (€)'),
                        ),
                        const DropdownMenuItem(
                          value: '\$',
                          child: Text('Dólar (\$)'),
                        ),
                        const DropdownMenuItem(
                          value: '£',
                          child: Text('Libra (£)'),
                        ),
                        const DropdownMenuItem(
                          value: '¥',
                          child: Text('Yen (¥)'),
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Confirmar al borrar'),
                    subtitle: const Text(
                      'Pedir confirmación antes de eliminar',
                    ),
                    value: settings.requireDeleteConfirmation,
                    onChanged: (val) =>
                        settings.setRequireDeleteConfirmation(val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ]),
                const SizedBox(height: 24),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    'ListMe v1.2.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // If the text is likely to overflow (based on scale), stack vertically
          final isLargeFont = MediaQuery.textScalerOf(context).scale(1) > 1.1;

          if (isLargeFont) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: trailing),
                const Divider(),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          );
        },
      ),
    );
  }

  String _getAccentName(ThemeAccent accent) {
    switch (accent) {
      case ThemeAccent.emerald:
        return 'Esmeralda (Verde)';
      case ThemeAccent.amethyst:
        return 'Amatista (Púrpura)';
      case ThemeAccent.sapphire:
        return 'Zafiro (Azul)';
      case ThemeAccent.ruby:
        return 'Rubí (Rojo)';
      case ThemeAccent.amber:
        return 'Ámbar (Naranja)';
      case ThemeAccent.cobalt:
        return 'Cobalto (Azul Oscuro)';
      case ThemeAccent.cyan:
        return 'Turquesa (Cyan)';
      case ThemeAccent.magenta:
        return 'Fucsia (Magenta)';
      case ThemeAccent.titanium:
        return 'Titanio (Apple Style)';
    }
  }
}
