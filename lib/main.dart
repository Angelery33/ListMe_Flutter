import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/routes.dart';
import 'data/auth/auth_repository.dart';
import 'data/lists/lists_repository.dart';
import 'providers/auth/auth_provider.dart';
import 'providers/lists/lists_provider.dart';
import 'providers/settings/settings_provider.dart';

import 'core/services/local_storage_service.dart';
import 'core/auth_wrapper.dart';
import 'core/api_client.dart';
import 'data/items/items_repository.dart';
import 'data/attributes/attributes_repository.dart';
import 'providers/items/items_provider.dart';

void main() async {
  // Aseguramos que los bindings de Flutter estén inicializados para SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Persistencia Local (Hive)
  await LocalStorageService.instance.init();

  // Inicializamos el cliente API único
  final apiClient = ApiClient();

  // Cargamos los ajustes del usuario antes de arrancar la interfaz
  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

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
        ChangeNotifierProvider.value(value: settingsProvider),
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
          home: const AuthWrapper(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
