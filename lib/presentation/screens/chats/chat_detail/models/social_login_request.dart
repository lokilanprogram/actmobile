import 'package:equatable/equatable.dart';

class VkLoginRequest extends Equatable {
  final String code;
  final String codeVerifier;
  final String? deviceId;
  final String state;
  final String? email;
  final String? phone;

  const VkLoginRequest({
    required this.code,
    required this.codeVerifier,
    this.deviceId,
    required this.state,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props =>
      [code, codeVerifier, deviceId, state, email, phone];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'platform': 'mobile',
      'code': code,
      'code_verifier': codeVerifier,
      'state': state,
      'email': email ?? '',
      'phone': phone ?? '',
    };

    if (deviceId != null && deviceId!.isNotEmpty) {
      data['device_id'] = deviceId;
    }

    return data;
  }
}

class YandexLoginRequest extends Equatable {
  final String token;

  const YandexLoginRequest({
    required this.token,
  });

  @override
  List<Object?> get props => [token];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'token': token,
    };

    return data;
  }
}

class AppleLoginRequest extends Equatable {
  final String identityToken;
  final String? authorizationCode;
  final String? email;
  final String? fullName;

  const AppleLoginRequest({
    required this.identityToken,
    this.authorizationCode,
    this.email,
    this.fullName,
  });

  @override
  List<Object?> get props => [identityToken, authorizationCode, email, fullName];

  Map<String, dynamic> toJson() {
    return {
      'identity_token': identityToken,
      'authorization_code': authorizationCode,
      'email': email,
      'full_name': fullName,
    };
  }
}
