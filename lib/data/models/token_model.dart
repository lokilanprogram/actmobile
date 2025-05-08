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
