import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/lists/lists_screen.dart';
import '../screens/lists/list_screen.dart';
import '../screens/lists/list_config_screen.dart';
import '../screens/info/info_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/items/item_entry_screen.dart';
import '../screens/items/item_detail_screen.dart';
import '../data/items/item_model.dart';
import '../data/lists/list_model.dart';

/// Gestión centralizada de las rutas de la aplicación.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String lists = '/lists';
  static const String list = '/list';
  static const String listConfig = '/list-config';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String info = '/info';
  static const String itemEntry = '/item-entry';
  static const String itemDetail = '/item-detail';

  /// Mapa de rutas para la configuración de MaterialApp.
  /// 
  /// La ruta listConfig acepta un ListModel opcional como argumento:
  ///   - Con argumento → modo edición, precarga los datos de la lista
  ///   - Sin argumento → modo creación de nueva lista vacía
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    home: (_) => const HomeScreen(),
    lists: (_) => const ListsScreen(),
    list: (_) => const ListScreen(),
    listConfig: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      return ListConfigScreen(
        library: args is ListModel ? args : null,
      );
    },
    profile: (_) => const ProfileScreen(),
    settings: (_) => const SettingsScreen(),
    info: (_) => const InfoScreen(),
    itemEntry: (_) => const ItemEntryScreen(),
    itemDetail: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ItemDetailScreen(item: args['item'] as ItemModel);
    },
  };
}
