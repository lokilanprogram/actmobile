class SocialLoginResponse {
  final String accessToken;
  final String tokenType;
  final String refreshToken;

  SocialLoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
  });

  factory SocialLoginResponse.fromJson(Map<String, dynamic> json) {
    return SocialLoginResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
    );
  }
}
