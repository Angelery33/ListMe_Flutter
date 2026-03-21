class ShareRequestModel {
  final String username;
  final bool readOnly;

  const ShareRequestModel({
    required this.username,
    this.readOnly = true,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'readOnly': readOnly,
  };
}
