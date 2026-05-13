class InvitationModel {
  final int id;
  final String senderUsername;
  final String receiverUsername;
  final int libraryId;
  final String libraryName;
  final bool readOnly;
  final String status;
  final DateTime createdAt;

  InvitationModel({
    required this.id,
    required this.senderUsername,
    required this.receiverUsername,
    required this.libraryId,
    required this.libraryName,
    required this.readOnly,
    required this.status,
    required this.createdAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      senderUsername: json['senderUsername'],
      receiverUsername: json['receiverUsername'],
      libraryId: json['libraryId'],
      libraryName: json['libraryName'],
      readOnly: json['readOnly'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
