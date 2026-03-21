import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/routes.dart';
import 'data/auth/auth_repository.dart';
import 'data/lists/lists_repository.dart';
import 'providers/auth/auth_provider.dart';
import 'providers/lists/lists_provider.dart';
import 'providers/settings/settings_provider.dart';

import 'providers/items/items_provider.dart';

void main() {
  // Inicializamos el cliente API único
  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        // Repositorios de datos (Proveedores de dependencia)
        Provider(create: (_) => AuthRepository(apiClient)),
        Provider(create: (_) => ListsRepository(apiClient)),
        Provider(create: (_) => ItemsRepository(apiClient)),
        Provider(create: (_) => AttributesRepository(apiClient)),

        // Providers de Estado
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (context) => ListsProvider(context.read<ListsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ItemsProvider(context.read<ItemsRepository>()),
        ),
      ],
      child: const ListMeApp(),
    ),
  );
}

class ListMeApp extends StatelessWidget {
  const ListMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
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
    );
  }
}
