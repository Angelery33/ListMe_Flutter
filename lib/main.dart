import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/routes.dart';
import 'data/auth/auth_repository.dart';
import 'data/lists/lists_repository.dart';
import 'providers/auth/auth_provider.dart';
import 'providers/lists/lists_provider.dart';
import 'providers/settings/settings_provider.dart';

void main() {
  runApp(const ListMeApp());
}

/// Punto de entrada de la aplicación ListMe.
/// 
/// Configura el MultiProvider global para los providers que requieren
/// disponibilidad en múltiples secciones de la app (auth y settings).
/// Los providers de feature específica se inyectan a nivel de ruta.
class ListMeApp extends StatelessWidget {
  const ListMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers globales: requeridos en múltiples secciones no relacionadas.
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository())),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // ListsProvider se provee como global ya que la barra de navegación
        // puede necesitar acceder al conteo de listas desde cualquier pantalla.
        ChangeNotifierProvider(create: (_) => ListsProvider(ListsRepository())),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'ListMe',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(settings.accentColor, Brightness.light, settings.fontScale),
            darkTheme: AppTheme.getTheme(settings.accentColor, Brightness.dark, settings.fontScale),
            themeMode: settings.themeMode,
            initialRoute: AppRoutes.login,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
