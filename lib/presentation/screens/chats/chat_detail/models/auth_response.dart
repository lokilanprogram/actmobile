// Базовый класс для ответов аутентификации, содержащий токены
class TokenResponse {
  final String accessToken;
  final String tokenType;
  final String refreshToken;

  TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

// Модель ответа для регистрации
class RegisterResponse extends TokenResponse {
  RegisterResponse({
    required super.accessToken,
    required super.tokenType,
    required super.refreshToken,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

// Модель ответа для входа
class LoginResponse extends TokenResponse {
  LoginResponse({
    required super.accessToken,
    required super.tokenType,
    required super.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

// Модель ответа для обновления токена
class RefreshTokenResponse extends TokenResponse {
  RefreshTokenResponse({
    required super.accessToken,
    required super.tokenType,
    required super.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }
}
