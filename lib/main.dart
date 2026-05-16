import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/generated/app_localizations.dart';

import 'firebase_options.dart';
import 'core/theme/theme.dart';
import 'core/config/routes.dart';
import 'data/auth/auth_repository.dart';
import 'data/lists/lists_repository.dart';
import 'data/items/items_repository.dart';
import 'data/attributes/attributes_repository.dart';
import 'data/profile/profile_repository.dart';
import 'data/invitations/invitations_repository.dart';
import 'data/system/system_repository.dart';
import 'providers/auth/auth_provider.dart';
import 'providers/lists/lists_provider.dart';
import 'providers/settings/settings_provider.dart';
import 'providers/items/items_provider.dart';
import 'providers/items/item_details_provider.dart';
import 'providers/profile/profile_provider.dart';
import 'providers/invitations/invitations_provider.dart';
import 'core/providers/responsive_provider.dart';
import 'core/providers/sidebar_provider.dart';

import 'core/services/local_storage_service.dart';
import 'core/auth/auth_wrapper.dart';
import 'core/services/api_client.dart';

/// Punto de entrada: inicializa los bindings de Flutter, Firebase, el almacenamiento local y
/// el proveedor de ajustes antes de pasar el control a [runApp].
void main() async {
  // Aseguramos que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Persistencia Local (Hive)
  await LocalStorageService.instance.init();

  // Inicializamos el cliente API único (singleton)
  final apiClient = ApiClient.instance;

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
        Provider(create: (_) => ProfileRepository(apiClient)),
        Provider(create: (_) => InvitationsRepository(apiClient)),
        Provider(create: (_) => SystemRepository(apiClient)),

        // Providers de Estado
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (context) => ListsProvider(
            context.read<ListsRepository>(),
            context.read<ItemsRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ItemsProvider(
            context.read<ItemsRepository>(),
            context.read<AttributesRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ItemDetailsProvider(context.read<ItemsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ProfileProvider(
            context.read<ProfileRepository>(),
            context.read<SystemRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              InvitationsProvider(context.read<InvitationsRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ResponsiveProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SidebarProvider(),
        ),
      ],
      child: const ListMeApp(),
    ),
  );
}

/// Widget raíz de la aplicación ListMe.
///
/// Escucha al [SettingsProvider] y reconstruye el [MaterialApp] cada vez que cambia el
/// modo de tema, el color de acento, la escala de fuente o la configuración regional para que cada pantalla
/// refleje las preferencias del usuario sin necesidad de reiniciar.
class ListMeApp extends StatelessWidget {
  const ListMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'ListMe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(
            settings.accentColor,
            Brightness.light,
            settings.fontScale,
          ),
          darkTheme: AppTheme.getTheme(
            settings.accentColor,
            Brightness.dark,
            settings.fontScale,
          ),
          themeMode: settings.themeMode,
          locale: Locale(settings.locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const AuthWrapper(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
