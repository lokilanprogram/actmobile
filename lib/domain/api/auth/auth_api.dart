import 'dart:convert';
import 'dart:developer' as developer;
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/token_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthApi {
  final storage = SecureStorageService();

  Future<TokenModel?> authRefreshToken() async {
    final refreshToken = await storage.getRefreshToken();
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
        await storage.writeTokens(
            resultToken.accessToken, resultToken.refreshToken);
        return resultToken;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<bool?> sendFcmToken(String token) async {
    final accessToken = await storage.getAccessToken();
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
    final accessToken = await storage.getAccessToken();
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
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final url = '$API/api/v1/users/profile/delete';
      final headers = {
        'Authorization': 'Bearer $accessToken',
      };

      developer.log('=== Начало запроса на удаление аккаунта ===',
          name: 'AUTH_API');
      developer.log('URL: $url', name: 'AUTH_API');
      developer.log('Headers: $headers', name: 'AUTH_API');
      developer.log('Method: DELETE', name: 'AUTH_API');

      try {
        final response = await http.delete(
          Uri.parse(url),
          headers: headers,
        );

        developer.log('=== Ответ от сервера ===', name: 'AUTH_API');
        developer.log('Status Code: ${response.statusCode}', name: 'AUTH_API');
        developer.log('Response Headers: ${response.headers}',
            name: 'AUTH_API');
        developer.log('Response Body: ${response.body}', name: 'AUTH_API');

        if (response.statusCode == 204) {
          developer.log('Аккаунт успешно удален (204 No Content)',
              name: 'AUTH_API');
          return true;
        } else {
          developer.log('Ошибка при удалении аккаунта', name: 'AUTH_API');
          developer.log('Код ошибки: ${response.statusCode}', name: 'AUTH_API');
          developer.log('Тело ответа: ${response.body}', name: 'AUTH_API');
          throw Exception('Error: ${response.body}');
        }
      } catch (e) {
        developer.log('=== Ошибка при выполнении запроса ===',
            name: 'AUTH_API');
        developer.log('Тип ошибки: ${e.runtimeType}', name: 'AUTH_API');
        developer.log('Сообщение об ошибке: $e', name: 'AUTH_API');
        rethrow;
      }
    }
    developer.log('=== Ошибка: токен доступа не найден ===', name: 'AUTH_API');
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
