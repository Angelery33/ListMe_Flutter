import 'package:flutter/material.dart';
import 'package:list_me/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../providers/settings/settings_provider.dart';
import '../../widgets/settings/accent_color_selector.dart';
import '../../widgets/settings/font_scale_selector.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_bottom_nav_bar.dart';

/// Pantalla de ajustes de la aplicación.
///
/// Permite al usuario personalizar la apariencia y comportamiento de ListMe.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomGradientAppBar(
        title: 'Ajustes',
        showBackButton: false,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0)
            Navigator.pushReplacementNamed(context, AppRoutes.lists);
          if (index == 1) Navigator.pushNamed(context, AppRoutes.profile);
          if (index == 3) Navigator.pushNamed(context, AppRoutes.social);
        },
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildSection(context, 'Apariencia', [
            _buildSettingTile(
              context,
              title: 'Tema de la aplicación',
              subtitle: 'Elige el modo de color',
              trailing: Text(
                settings.themeMode == ThemeMode.light
                    ? 'Claro'
                    : settings.themeMode == ThemeMode.dark
                    ? 'Oscuro'
                    : 'Sistema',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.auto_awesome_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (val) => settings.setThemeMode(val.first),
                showSelectedIcon: false,
              ),
            ),
            const Divider(height: 32),
            Row(
              children: [
                const Text(
                  'Elije tu tema',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  _accentColorLabel(settings.accentColor),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AccentColorSelector(settings: settings),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Texto y Lectura', [
            _buildSettingTile(
              context,
              title: 'Tamaño de fuente',
              subtitle: 'Ajusta el tamaño del texto global',
              trailing: Text(
                _fontScaleLabel(settings.fontScale),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FontScaleSelector(settings: settings),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'APIs Externas', [
            _buildApiKeyField(
              context,
              settings: settings,
              title: 'OMDb API Key',
              subtitle: 'Para buscar películas y series',
              value: settings.omdbApiKey,
              hint: 'Clave de OMDb (opcional)',
              onSave: (value) => settings.setOmdbApiKey(value),
            ),
            const SizedBox(height: 16),
            _buildApiKeyField(
              context,
              settings: settings,
              title: 'TMDb API Key',
              subtitle: 'Para buscar películas y series',
              value: settings.tmdbApiKey,
              hint: 'Clave de TMDb (opcional)',
              onSave: (value) => settings.setTmdbApiKey(value),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSection(context, 'Cuenta', [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                final auth = context.read<AuthProvider>();
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),
          ]),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Versión 0.1.0 Beta',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 80), // Espacio extra para scroll
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final isTitanium =
        scheme.primary.toARGB32() == const Color(0xFF1D1B1E).toARGB32() ||
        scheme.primary.toARGB32() == const Color(0xFFE3E2E6).toARGB32();

    Color cardColor;
    if (isTitanium) {
      cardColor = isDark
          ? const Color.fromARGB(255, 75, 75, 78)
          : const Color.fromARGB(255, 226, 224, 224);
    } else {
      cardColor = isDark
          ? scheme.onSurfaceVariant.withValues(alpha: 0.25)
          : scheme.onSurfaceVariant.withValues(alpha: 0.1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeFont = MediaQuery.textScalerOf(context).scale(1) > 1.2;

        if (isLargeFont) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: trailing),
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
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        );
      },
    );
  }

  String _fontScaleLabel(double scale) {
    if (scale <= 0.85) return 'Muy Pequeño';
    if (scale <= 0.95) return 'Pequeño';
    if (scale <= 1.05) return 'Normal';
    if (scale <= 1.15) return 'Mediano';
    if (scale <= 1.30) return 'Grande';
    return 'Muy Grande';
  }

  String _accentColorLabel(String accent) {
    switch (accent) {
      case 'amethyst':
        return 'Amatista';
      case 'sapphire':
        return 'Zafiro';
      case 'ruby':
        return 'Rubí';
      case 'emerald':
        return 'Esmeralda';
      case 'cobalt':
        return 'Cobalto';
      case 'cyan':
        return 'Turquesa';
      case 'magenta':
        return 'Magenta';
      case 'titanium':
        return 'Titanio';
      default:
        return 'Desconocido';
    }
  }

  Widget _buildApiKeyField(
    BuildContext context, {
    required SettingsProvider settings,
    required String title,
    required String subtitle,
    required String value,
    required String hint,
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: value);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: () {
                onSave(controller.text.trim());
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Guardado')));
              },
            ),
          ],
        ),
      ],
    );
  }
}
