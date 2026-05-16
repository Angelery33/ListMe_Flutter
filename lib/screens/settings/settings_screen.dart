import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/routes.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../core/i18n/currencies.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/settings/settings_provider.dart';
import '../../widgets/settings/accent_color_selector.dart';
import '../../widgets/settings/font_scale_selector.dart';
import '../../widgets/shared/app_shell.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/responsive_centered_content.dart';

/// Pantalla que expone todas las preferencias configurables por el usuario.
///
/// Dividida en cuatro secciones: Apariencia (tema, color de acento), Texto y Lectura
/// (escala de fuente), Regional (idioma, moneda) y Cuenta (cerrar sesión). Todos los
/// cambios se persisten inmediatamente a través de [SettingsProvider].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return AppShell(
      currentIndex: 2,
      appBar: CustomGradientAppBar(
        title: context.l10n.settingsTitle,
        showBackButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          ResponsiveCenteredContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AppearanceSection(settings: settings, theme: theme),
                const SizedBox(height: 24),
                _TextSection(settings: settings, theme: theme),
                const SizedBox(height: 24),
                _RegionalSection(settings: settings, theme: theme),
                const SizedBox(height: 24),
                _AccountSection(),
                const SizedBox(height: 40),
                _VersionFooter(theme: theme),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Sections
// ============================================================

/// Sección de ajustes para la selección del modo de tema y el color de acento.
class _AppearanceSection extends StatelessWidget {
  final SettingsProvider settings;
  final ThemeData theme;
  const _AppearanceSection({required this.settings, required this.theme});

  /// Devuelve una etiqueta localizada para [mode] (claro, oscuro o sistema).
  String _themeLabel(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return context.l10n.settingsThemeLight;
      case ThemeMode.dark:
        return context.l10n.settingsThemeDark;
      default:
        return context.l10n.settingsThemeSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: context.l10n.settingsAppearance,
      children: [
        _SettingTile(
          title: context.l10n.settingsTheme,
          subtitle: context.l10n.settingsThemeSubtitle,
          trailing: Text(
            _themeLabel(context, settings.themeMode),
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
            Text(
              context.l10n.settingsAccent,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              _accentLabel(context, settings.accentColor),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AccentColorSelector(settings: settings),
      ],
    );
  }
}

/// Sección de ajustes para el ajuste de la escala de fuente (tamaño de texto).
class _TextSection extends StatelessWidget {
  final SettingsProvider settings;
  final ThemeData theme;
  const _TextSection({required this.settings, required this.theme});

  /// Devuelve una etiqueta localizada legible por el hombre para la escala de fuente [s].
  String _fontScaleLabel(BuildContext context, double s) {
    final l = context.l10n;
    if (s <= 0.85) return l.fontSizeVerySmall;
    if (s <= 0.95) return l.fontSizeSmall;
    if (s <= 1.05) return l.fontSizeNormal;
    if (s <= 1.15) return l.fontSizeMedium;
    if (s <= 1.30) return l.fontSizeLarge;
    return l.fontSizeVeryLarge;
  }

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: context.l10n.settingsTextAndReading,
      children: [
        _SettingTile(
          title: context.l10n.settingsFontSize,
          subtitle: context.l10n.settingsFontSizeSubtitle,
          trailing: Text(
            _fontScaleLabel(context, settings.fontScale),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FontScaleSelector(settings: settings),
      ],
    );
  }
}

/// Sección de ajustes para la selección de configuración regional y moneda.
class _RegionalSection extends StatelessWidget {
  final SettingsProvider settings;
  final ThemeData theme;
  const _RegionalSection({required this.settings, required this.theme});

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(settings.currency);

    return _Section(
      title: context.l10n.settingsRegional,
      children: [
        _SettingTile(
          title: context.l10n.settingsLanguage,
          subtitle: context.l10n.settingsLanguageSubtitle,
          trailing: DropdownButton<String>(
            value: settings.locale,
            underline: const SizedBox.shrink(),
            items: kSupportedAppLocales
                .map((e) => DropdownMenuItem(
                      value: e.code,
                      child: Text(e.label),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) settings.setLocale(val);
            },
          ),
        ),
        const Divider(height: 32),
        _SettingTile(
          title: context.l10n.settingsCurrency,
          subtitle: context.l10n.settingsCurrencySubtitle,
          trailing: DropdownButton<String>(
            value: currency.code,
            underline: const SizedBox.shrink(),
            items: kSupportedCurrencies
                .map((c) => DropdownMenuItem(
                      value: c.code,
                      child: Text('${c.symbol}  ${c.code}'),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) settings.setCurrency(val);
            },
          ),
        ),
      ],
    );
  }
}

/// Sección de ajustes que proporciona una acción de cierre de sesión.
class _AccountSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _Section(
      title: context.l10n.settingsAccount,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title: Text(
            context.l10n.settingsLogout,
            style: const TextStyle(
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
      ],
    );
  }
}

/// Widget de pie de página que muestra el nombre de la aplicación y la versión de compilación actual.
class _VersionFooter extends StatelessWidget {
  final ThemeData theme;
  const _VersionFooter({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'ListMe',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${context.l10n.settingsVersion} 0.2.0 (Build 2)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Reusable building blocks
// ============================================================

/// Una sección de tarjeta con título utilizada en toda la pantalla de ajustes.
///
/// Renderiza una etiqueta de [title] en mayúsculas del color primario encima de una tarjeta redondeada
/// que contiene [children]. El color de la tarjeta se adapta al tema y color de acento actuales.
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
                  color: scheme.primary,
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
}

/// Una fila adaptable de dos columnas (o apilada) que empareja un bloque de etiquetas [title]/[subtitle]
/// con un widget de control [trailing].
///
/// Cuando el factor de escala de texto supera 1.2, el diseño se apila verticalmente para
/// evitar el desbordamiento en tamaños de fuente de accesibilidad.
class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
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
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
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
}

/// Asocia una clave de color de acento [accent] con su nombre visible localizado.
///
/// Vuelve a devolver [accent] sin cambios para claves no reconocidas.
String _accentLabel(BuildContext context, String accent) {
  final l = context.l10n;
  switch (accent) {
    case 'amethyst':
      return l.accentAmethyst;
    case 'sapphire':
      return l.accentSapphire;
    case 'ruby':
      return l.accentRuby;
    case 'emerald':
      return l.accentEmerald;
    case 'cobalt':
      return l.accentCobalt;
    case 'cyan':
      return l.accentCyan;
    case 'magenta':
      return l.accentMagenta;
    case 'titanium':
      return l.accentTitanium;
    default:
      return accent;
  }
}
