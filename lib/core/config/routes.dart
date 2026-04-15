import 'package:flutter/material.dart';
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

/// Gestión centralizada de las rutas de la aplicación.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String lists = '/lists';
  static const String list = '/list';
  static const String listConfig = '/list-config';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String info = '/info';
  static const String social = '/social';
  static const String itemEntry = '/item-entry';
  static const String itemDetail = '/item-detail';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    lists: (_) => const ListsScreen(),
    list: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;

      // Soporta tanto Map como ListModel para backwards compatibility
      if (args is Map<String, dynamic>) {
        return ListScreen(
          listId: args['id'] as int,
          listName: args['name'] as String,
          remoteId: args['remoteId'] as String?,
          parentId: args['parentId'] as int?,
        );
      }

      // Legacy: si es ListModel, extraer id y name
      if (args is ListModel) {
        return ListScreen(
          listId: args.id ?? 0,
          listName: args.name,
          list: args,
        );
      }

      // Fallback
      return const ListScreen(listId: 0, listName: 'Lista');
    },
    listConfig: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      return ListConfigScreen(library: args is ListModel ? args : null);
    },
    profile: (_) => const ProfileScreen(),
    settings: (_) => const SettingsScreen(),
    info: (_) => const InfoScreen(),
    social: (_) => const SocialScreen(),
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
