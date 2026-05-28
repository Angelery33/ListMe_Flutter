import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/lists/lists_screen.dart';
import '../../screens/lists/list_screen.dart';
import '../../screens/lists/list_config_screen.dart';
import '../../screens/info/info_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/social/social_screen.dart';
import '../../screens/items/item_entry_screen.dart';
import '../../screens/items/item_detail_screen.dart';
import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';
import '../../providers/lists/lists_provider.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/friends/friends_provider.dart';
import '../../providers/invitations/invitations_provider.dart';
import '../navigation/refresh_on_enter.dart';

/// Gestión centralizada de las rutas de la aplicación.
///
/// Expone constantes de nombre de ruta y el mapa de [routes] listo para pasar
/// a [MaterialApp.routes]. Las rutas que requieren argumentos extraen éstos de
/// [ModalRoute.settings.arguments] para desacoplar la navegación del tipo
/// exacto de objeto pasado.
class AppRoutes {
  AppRoutes._();

  /// Ruta de la pantalla de inicio de sesión.
  static const String login = '/login';

  /// Ruta de la pantalla de registro de nueva cuenta.
  static const String register = '/register';

  /// Ruta de la pantalla principal que lista todas las listas del usuario.
  static const String lists = '/lists';

  /// Ruta de la pantalla de contenido de una lista concreta.
  /// Argumentos esperados: [Map<String, dynamic>] con claves `id`, `name`,
  /// `remoteId` y `parentId`, o directamente un [ListModel].
  static const String list = '/list';

  /// Ruta de la pantalla de configuración de una lista o sublista.
  static const String listConfig = '/list-config';

  /// Ruta de la pantalla de perfil del usuario autenticado.
  static const String profile = '/profile';

  /// Ruta de la pantalla de preferencias y ajustes de la app.
  static const String settings = '/settings';

  /// Ruta de la pantalla de información/about de la aplicación.
  static const String info = '/info';

  /// Ruta de la pantalla social (comunidad, compartir listas, etc.).
  static const String social = '/social';

  /// Ruta de la pantalla de alta/edición de un ítem.
  static const String itemEntry = '/item-entry';

  /// Ruta de la pantalla de detalle de un ítem.
  /// Argumentos esperados: [Map<String, dynamic>] con claves `item` ([ItemModel])
  /// y opcionalmente `list` ([ListModel]).
  static const String itemDetail = '/item-detail';

  /// Mapa de constructores de widgets indexado por nombre de ruta, listo para
  /// pasar a [MaterialApp.routes].
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    lists: (context) => RefreshOnEnter(
      onEnter: () => context.read<ListsProvider>().fetchLists(),
      child: const ListsScreen(),
    ),
    list: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;

      // Soporta tanto Map como ListModel para compatibilidad con versiones anteriores
      if (args is Map<String, dynamic>) {
        return ListScreen(
          listId: args['id'] as int,
          listName: args['name'] as String,
          remoteId: args['remoteId'] as String?,
          parentId: args['parentId'] as int?,
        );
      }

      // Compatibilidad anterior: si es ListModel, extraer id y name
      if (args is ListModel) {
        return ListScreen(
          listId: args.id ?? 0,
          listName: args.name,
          list: args,
        );
      }

      // Caso por defecto
      return const ListScreen(listId: 0, listName: 'Lista');
    },
    listConfig: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      return ListConfigScreen(library: args is ListModel ? args : null);
    },
    profile: (context) => RefreshOnEnter(
      onEnter: () => context.read<ProfileProvider>().loadProfile(),
      child: const ProfileScreen(),
    ),
    settings: (_) => const SettingsScreen(),
    info: (_) => const InfoScreen(),
    social: (context) => RefreshOnEnter(
      onEnter: () {
        context.read<FriendsProvider>().loadAll();
        context.read<InvitationsProvider>().loadPendingInvitations();
      },
      child: const SocialScreen(),
    ),
    itemEntry: (_) => const ItemEntryScreen(),
    itemDetail: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is! Map<String, dynamic>) {
        return const ItemDetailScreen(
          item: ItemModel(idLibrary: 0, name: 'Error'),
          list: null,
        );
      }
      final item = args['item'];
      final list = args['list'];
      if (item is! ItemModel) {
        return const ItemDetailScreen(
          item: ItemModel(idLibrary: 0, name: 'Error'),
          list: null,
        );
      }
      return ItemDetailScreen(
        item: item,
        list: list is ListModel ? list : null,
      );
    },
  };
}
