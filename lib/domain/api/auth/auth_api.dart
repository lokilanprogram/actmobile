import 'dart:convert';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/token_model.dart';
import 'package:http/http.dart' as http;

class AuthApi {
  Future<TokenModel?> authRefreshToken() async {
    final refreshToken = await storage.read(key: refreshStorageToken);
    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/auth/refresh-token'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, dynamic>{'refresh_token': refreshToken}),
      );
      if (response.statusCode == 200) {
        final resultToken = TokenModel.fromJson(jsonDecode(response.body));
        await writeAuthTokens(
            resultToken.accessToken, resultToken.refreshToken);
        return resultToken;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<bool?> sendFcmToken(String token) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/auth/fcm-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          "Content-Type": "application/json",
        },
        body: jsonEncode(<String, dynamic>{'fcm_token': token}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<bool> authLogout() async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/auth/logout'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return false;
  }

  Future<bool> authDelete() async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.delete(
        Uri.parse('$API/api/v1/users/delete'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return false;
  }

  Future<TokenModel?> authRegister(String phone) async {
    final response = await http.post(
      Uri.parse('$API/api/v1/auth/register'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(<String, dynamic>{'phone': phone}),
    );

    if (response.statusCode == 200) {
      return TokenModel.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<TokenModel?> authVerify(String phone, String phoneCode) async {
    final response = await http.post(
      Uri.parse('$API/api/v1/auth/verify'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(
          <String, dynamic>{"phone": phone, "call_last_digits": phoneCode}),
    );

    if (response.statusCode == 200) {
      return TokenModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error: ${response.body}');
    }
  }
}
