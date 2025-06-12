// Модель для запроса обычной регистрации
class RegisterRequest {
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? gender;
  final DateTime? birthDate;

  RegisterRequest({
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.phone,
    this.gender,
    this.birthDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
    };

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (gender != null) data['gender'] = gender;
    if (birthDate != null) data['birth_date'] = birthDate!.toIso8601String();

    return data;
  }
}

// Модель для запроса обычного входа
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'grant_type': 'password',
      'scope': '',
      'client_id': '',
      'client_secret': ''
    };
  }
}

// Модель для запроса обновления токена
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}
