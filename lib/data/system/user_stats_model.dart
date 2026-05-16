/// Estadísticas agregadas para el usuario autenticado, devueltas por el punto de conexión
/// de estadísticas del sistema.
///
/// Proporciona un resumen rápido del contenido del usuario, utilizado por la pantalla de perfil
/// para mostrar métricas de uso generales sin cargar cada biblioteca o elemento.
class UserStatsModel {
  /// El número total de bibliotecas (listas) propias o compartidas con el usuario.
  final int totalLibraries;

  /// El número total de elementos en todas las bibliotecas del usuario.
  final int totalItems;

  UserStatsModel({
    required this.totalLibraries,
    required this.totalItems,
  });

  /// Crea un [UserStatsModel] a partir del mapa JSON devuelto por la API.
  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalLibraries: json['totalLibraries'],
      totalItems: json['totalItems'],
    );
  }
}
