import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/lists/lists_screen.dart';
import '../screens/lists/list_detail_screen.dart';
import '../screens/lists/list_config_screen.dart';
import '../screens/info/info_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Gestión centralizada de las rutas de la aplicación.
/// 
/// Centraliza todas las rutas para evitar literales dispersos.
class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String lists = '/lists';
  static const String listDetail = '/list-detail';
  static const String listConfig = '/list-config';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String info = '/info';

  /// Mapa de rutas para la configuración de MaterialApp.
  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        home: (_) => const HomeScreen(),
        lists: (_) => const ListsScreen(),
        listDetail: (_) => const ListDetailScreen(),
        listConfig: (_) => const ListConfigScreen(),
        profile: (_) => const ProfileScreen(),
        settings: (_) => const SettingsScreen(),
        info: (_) => const InfoScreen(),
      };
}
