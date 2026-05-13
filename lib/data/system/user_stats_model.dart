class UserStatsModel {
  final int totalLibraries;
  final int totalItems;

  UserStatsModel({
    required this.totalLibraries,
    required this.totalItems,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalLibraries: json['totalLibraries'],
      totalItems: json['totalItems'],
    );
  }
}
