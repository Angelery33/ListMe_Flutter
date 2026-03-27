class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

class RegisterRequest {
  final String username;
  final String password;
  final String email;

  const RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'email': email,
  };
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

class TokenRefreshRequest {
  final String refreshToken;

  const TokenRefreshRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}
