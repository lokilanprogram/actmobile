// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

TokenModel welcomeFromJson(String str) => TokenModel.fromJson(json.decode(str));

String welcomeToJson(TokenModel data) => json.encode(data.toJson());

class TokenModel {
    String tokenType;
    String accessToken;
    String refreshToken;

    TokenModel({
        required this.tokenType,
        required this.accessToken,
        required this.refreshToken,
    });

    factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
        tokenType: json["token_type"],
        accessToken: json["access_token"],
        refreshToken: json["refresh_token"],
    );

    Map<String, dynamic> toJson() => {
        "token_type": tokenType,
        "access_token": accessToken,
        "refresh_token": refreshToken,
    };
}

class LoginModel {
  String authReqId;
  String status;
  String correlationId;

  LoginModel({
    required this.authReqId,
    required this.status,
    required this.correlationId,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    authReqId: json["auth_req_id"],
    status: json["status"],
    correlationId: json["correlation_id"],
  );

  Map<String, dynamic> toJson() => {
    "auth_req_id": authReqId,
    "status": status,
    "correlation_id": correlationId,
  };
}

class AuthStatusModel {
  String status;
  String phone;
  String authReqId;
  String registerToken;

  AuthStatusModel({
    required this.status,
    required this.phone,
    required this.authReqId,
    required this.registerToken,
  });

  factory AuthStatusModel.fromJson(Map<String, dynamic> json) => AuthStatusModel(
    status: json["status"],
    phone: json["phone"],
    authReqId: json["auth_req_id"],
    registerToken: json["register_token"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "phone": phone,
    "auth_req_id": authReqId,
    "register_token": registerToken,
  };
}