import '../services/auth_service.dart';
import '../../presentation/screens/chats/chat_detail/models/social_login_request.dart';
import '../../presentation/screens/chats/chat_detail/models/social_login_response.dart';
import '../../presentation/screens/chats/chat_detail/models/api_error.dart';
import '../../presentation/screens/chats/chat_detail/models/auth_request.dart';
import '../../presentation/screens/chats/chat_detail/models/auth_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class AuthRepository {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage;
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _tokenTypeKey = 'token_type';

  AuthRepository(this._authService)
      : _secureStorage = const FlutterSecureStorage() {
    developer.log('AuthRepository: конструктор вызван', name: 'AUTH_REPO');
  }

  // Регистрация нового пользователя
  Future<RegisterResponse> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? gender,
    DateTime? birthDate,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        gender: gender,
        birthDate: birthDate,
      );

      final response = await _authService.register(request);

      // Сохраняем токены в secure storage
      await saveTokens(response);

      return response;
    } on ApiError catch (e) {
      developer.log('ApiError при регистрации: ${e.detail}', name: 'AUTH');
      rethrow;
    } catch (e) {
      developer.log('Ошибка при регистрации: $e', name: 'AUTH');
      throw Exception('Ошибка при регистрации: $e');
    }
  }

  // Вход по email/пароль
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      developer.log('Начало процесса входа в репозитории', name: 'AUTH_REPO');
      final request = LoginRequest(
        username: username,
        password: password,
      );

      developer.log('Отправка запроса на вход в сервис', name: 'AUTH_REPO');
      final response = await _authService.login(request);

      developer.log('Получен ответ от сервиса, сохранение токенов',
          name: 'AUTH_REPO');
      // Сохраняем токены в secure storage
      await saveTokens(response);

      developer.log('Вход успешно завершен', name: 'AUTH_REPO');
      return response;
    } on ApiError catch (e) {
      developer.log('ApiError при входе в репозитории: ${e.detail}',
          name: 'AUTH_REPO');
      rethrow;
    } catch (e) {
      developer.log('Неизвестная ошибка при входе в репозитории: $e',
          name: 'AUTH_REPO');
      throw Exception('Ошибка при входе: $e');
    }
  }

  // Обновление токена
  // Future<RefreshTokenResponse> refreshToken() async {
  //   try {
  //     final refreshToken = await getRefreshToken();

  //     if (refreshToken == null || refreshToken.isEmpty) {
  //       throw Exception('Токен обновления отсутствует');
  //     }

  //     final request = RefreshTokenRequest(refreshToken: refreshToken);
  //     final response = await _authService.refreshToken(request);

  //     // Сохраняем новые токены
  //     await saveTokens(response);

  //     return response;
  //   } on ApiError catch (e) {
  //     developer.log('ApiError при обновлении токена: ${e.detail}',
  //         name: 'AUTH');
  //     rethrow;
  //   } catch (e) {
  //     developer.log('Ошибка при обновлении токена: $e', name: 'AUTH');
  //     throw Exception('Ошибка при обновлении токена: $e');
  //   }
  // }

  // Проверка валидности токена и обновление при необходимости
  // Future<bool> checkAndRefreshTokenIfNeeded() async {
  //   try {
  //     // Проверяем, есть ли токены
  //     final accessToken = await getAccessToken();
  //     final refreshToken = await getRefreshToken();

  //     developer.log('Проверка токенов:', name: 'AUTH');
  //     developer.log(
  //         'Access Token: ${accessToken != null ? 'есть' : 'отсутствует'}',
  //         name: 'AUTH');
  //     developer.log(
  //         'Refresh Token: ${refreshToken != null ? 'есть' : 'отсутствует'}',
  //         name: 'AUTH');

  //     // Если нет токенов вообще
  //     if (accessToken == null || accessToken.isEmpty) {
  //       if (refreshToken == null || refreshToken.isEmpty) {
  //         // Нет ни одного токена, пользователь не авторизован
  //         developer.log('Нет токенов, пользователь не авторизован',
  //             name: 'AUTH');
  //         return false;
  //       }

  //       // Есть только refresh token, пробуем обновить
  //       try {
  //         await this.refreshToken();
  //         return true;
  //       } catch (e) {
  //         // Не удалось обновить токен
  //         developer.log('Не удалось обновить токен: $e', name: 'AUTH');
  //         await logout(); // Очищаем токены при ошибке
  //         return false;
  //       }
  //     }

  //     // Проверяем срок действия access token на основе JWT
  //     if (_isTokenExpired(accessToken)) {
  //       developer.log('Access token истек, пробуем обновить', name: 'AUTH');
  //       if (refreshToken == null || refreshToken.isEmpty) {
  //         // Нет refresh токена, нужно заново авторизоваться
  //         await logout();
  //         return false;
  //       }

  //       // Обновляем токен
  //       try {
  //         await this.refreshToken();
  //         return true;
  //       } catch (e) {
  //         // Не удалось обновить токен
  //         developer.log('Не удалось обновить токен: $e', name: 'AUTH');
  //         await logout(); // Очищаем токены при ошибке
  //         return false;
  //       }
  //     }

  //     // Проверяем верификацию email
  //     try {
  //       final profileData = await checkEmailVerification(accessToken);
  //       developer.log('Данные профиля: $profileData', name: 'AUTH');

  //       // Если email "None", значит пользователь вошел через соц. сети
  //       if (profileData['email'] == 'None') {
  //         developer.log(
  //             'Пользователь вошел через соц. сети, пропускаем верификацию',
  //             name: 'AUTH');
  //         return true;
  //       }

  //       final isVerified = profileData['is_verified'] ?? false;
  //       developer.log(
  //           'Проверка верификации email: ${isVerified ? 'верифицирован' : 'не верифицирован'}',
  //           name: 'AUTH');

  //       if (!isVerified) {
  //         developer.log('Email не верифицирован', name: 'AUTH');
  //         return false;
  //       }
  //     } catch (e) {
  //       developer.log('Ошибка при проверке верификации email: $e',
  //           name: 'AUTH');
  //       return false;
  //     }

  //     // Токен действителен и email верифицирован
  //     developer.log('Токен действителен и email верифицирован', name: 'AUTH');
  //     return true;
  //   } catch (e) {
  //     // При ошибке обновления токена, считаем что пользователь не авторизован
  //     developer.log('Ошибка при проверке токена: $e', name: 'AUTH');
  //     await logout(); // Очищаем токены при любой ошибке
  //     return false;
  //   }
  // }

  // Проверка истекшего JWT токена
  bool _isTokenExpired(String token) {
    try {
      // Разделяем JWT токен на части
      final parts = token.split('.');
      if (parts.length != 3) {
        // Неверный формат токена
        return true;
      }

      // Декодируем payload (часть 2)
      final payload = parts[1];
      // Добавляем отступы, если нужно
      final normalized = base64Url.normalize(payload);
      // Декодируем из base64
      final decoded = utf8.decode(base64Url.decode(normalized));
      // Преобразуем JSON в Map
      final Map<String, dynamic> tokenData = jsonDecode(decoded);

      // Получаем время истечения (exp)
      if (tokenData.containsKey('exp')) {
        final exp = tokenData['exp'];
        if (exp is int) {
          // Время в токене хранится в секундах, а DateTime.now() возвращает миллисекунды
          final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final now = DateTime.now();

          // Считаем токен действительным, если до истечения осталось более 5 минут
          return now.isAfter(expDate.subtract(const Duration(minutes: 5)));
        }
      }

      // Если не удалось определить срок действия токена, считаем его истекшим
      return true;
    } catch (e) {
      developer.log('Ошибка при проверке срока действия токена: $e',
          name: 'AUTH');
      return true; // При ошибке считаем токен истекшим
    }
  }

  // Социальная авторизация
  Future<Map<String, dynamic>> socialLogin(dynamic request) async {
    try {
      developer.log('Начало социальной авторизации', name: 'AUTH');
      final response = await _authService.socialLogin(request);

      // Сохраняем токены после успешной авторизации
      if (response['access_token'] != null) {
        developer.log('Получены токены от сервера', name: 'AUTH');
        await saveTokens(TokenResponse(
          accessToken: response['access_token'],
          tokenType: response['token_type'] ?? 'Bearer',
          refreshToken: response['refresh_token'],
        ));
        developer.log('Токены успешно сохранены', name: 'AUTH');
      } else {
        developer.log('Токены не получены от сервера', name: 'AUTH');
      }

      return response;
    } catch (e) {
      developer.log('Ошибка при социальной авторизации: $e', name: 'AUTH');
      rethrow;
    }
  }

  // Сохранение токенов в secure storage
  Future<void> saveTokens(TokenResponse response) async {
    try {
      developer.log('AuthRepository: начало сохранения токенов',
          name: 'AUTH_REPO');
      await _secureStorage.write(
          key: _accessTokenKey, value: response.accessToken);
      await _secureStorage.write(
          key: _refreshTokenKey, value: response.refreshToken);
      await _secureStorage.write(key: _tokenTypeKey, value: response.tokenType);

      developer.log('AuthRepository: токены успешно сохранены',
          name: 'AUTH_REPO');
    } catch (e) {
      developer.log('AuthRepository: ошибка при сохранении токенов: $e',
          name: 'AUTH_REPO');
      rethrow;
    }
  }

  // Получение сохраненного токена доступа
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      developer.log('Ошибка при получении access token: $e', name: 'AUTH');
      return null;
    }
  }

  // Получение сохраненного refresh токена
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      developer.log('Ошибка при получении refresh token: $e', name: 'AUTH');
      return null;
    }
  }

  // Проверка наличия действительной авторизации
  // Future<bool> isAuthenticated() async {
  //   try {
  //     return await checkAndRefreshTokenIfNeeded();
  //   } catch (e) {
  //     developer.log('Ошибка при проверке аутентификации: $e', name: 'AUTH');
  //     return false;
  //   }
  // }

  // Выход из аккаунта - удаление токенов
  Future<void> logout() async {
    try {
      // Получаем access token
      final accessToken = await getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        try {
          await _authService.logout(accessToken);
        } catch (e) {
          developer.log('Ошибка при вызове API logout: $e', name: 'AUTH');
          // Даже если API logout не удался, продолжаем очищать токены локально
        }
      }
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
      await _secureStorage.delete(key: _tokenTypeKey);

      developer.log('Токены успешно удалены, пользователь вышел из системы',
          name: 'AUTH');
    } catch (e) {
      developer.log('Ошибка при выходе из системы: $e', name: 'AUTH');
      rethrow;
    }
  }

  // Повторная отправка письма с подтверждением
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _authService.resendVerificationEmail(email);
      developer.log('Письмо с подтверждением отправлено повторно',
          name: 'AUTH');
    } catch (e) {
      developer.log('Ошибка при повторной отправке письма: $e', name: 'AUTH');
      rethrow;
    }
  }

  // Проверка верификации email
  Future<Map<String, dynamic>> checkEmailVerification(
      String accessToken) async {
    try {
      final response = await _authService.checkEmailVerification(accessToken);
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403 &&
          e.response?.data['detail'] == 'Email is not verified') {
        return {'is_verified': false};
      }
      rethrow;
    }
  }

  // Запрос на сброс пароля
  Future<void> requestPasswordReset(String email) async {
    try {
      await _authService.requestPasswordReset(email);
      developer.log('Запрос на сброс пароля успешно отправлен', name: 'AUTH');
    } catch (e) {
      developer.log('Ошибка при запросе сброса пароля: $e', name: 'AUTH');
      rethrow;
    }
  }

  // Установка нового пароля
  Future<void> changePassword(String token, String newPassword) async {
    try {
      await _authService.changePassword(token, newPassword);
      developer.log('Пароль успешно изменен', name: 'AUTH');
    } catch (e) {
      developer.log('Ошибка при изменении пароля: $e', name: 'AUTH');
      rethrow;
    }
  }
}
