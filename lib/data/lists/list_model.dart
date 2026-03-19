/// Modelo de una lista de usuario.
/// 
/// Representa las listas gestionadas por el usuario en la aplicación.
class ListModel {
  final String id;
  final String name;
  final String? description;
  final String color;
  final String icon;
  final bool isShared;
  final int order;

  const ListModel({
    required this.id,
    required this.name,
    this.description,
    required this.color,
    required this.icon,
    required this.isShared,
    required this.order,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      icon: json['icon'] as String,
      isShared: json['isShared'] as bool,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'color': color,
    'icon': icon,
    'isShared': isShared,
    'order': order,
  };
}
