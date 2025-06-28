import 'package:dio/dio.dart';
import '../../presentation/screens/chats/chat_detail/models/social_login_request.dart';
import '../../presentation/screens/chats/chat_detail/models/social_login_response.dart';
import '../../presentation/screens/chats/chat_detail/models/api_error.dart';
import '../../presentation/screens/chats/chat_detail/models/auth_request.dart';
import '../../presentation/screens/chats/chat_detail/models/auth_response.dart';
import 'dart:developer' as developer;

class AuthService {
  final Dio _dio;
  final String _baseUrl;

  AuthService(this._dio, this._baseUrl) {
    // Настраиваем перехватчики для логирования
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (object) => developer.log(object.toString(), name: 'API_LOG'),
    ));
  }

  // Метод для регистрации нового пользователя
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      developer.log('Отправка запроса регистрации: ${request.toJson()}',
          name: 'REGISTER');

      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/register',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('Успешный ответ на запрос регистрации: ${response.data}',
            name: 'REGISTER');
        return RegisterResponse.fromJson(response.data);
      } else if (response.statusCode == 400) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      } else {
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      developer.log(
          'Ошибка запроса регистрации: ${e.response?.data ?? e.message}',
          name: 'REGISTER_ERROR');
      rethrow;
    }
  }

  // Метод для входа по email/пароль
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      developer.log('Отправка запроса входа: ${request.username}',
          name: 'LOGIN');

      final data = request.toJson();
      developer.log('Данные запроса: $data', name: 'LOGIN');

      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/login',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      } else {
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      developer.log('Ошибка запроса входа: ${e.response?.data ?? e.message}',
          name: 'LOGIN_ERROR');
      rethrow;
    }
  }

  // Метод для обновления токена
  Future<RefreshTokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      developer.log('Отправка запроса обновления токена',
          name: 'REFRESH_TOKEN');

      // Формируем данные для запроса обновления токена (только refresh_token)
      final data = {
        'refresh_token': request.refreshToken,
      };

      developer.log('Данные запроса: $data', name: 'REFRESH_TOKEN');

      // Установка повторных попыток и таймаутов
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
        },
        contentType: 'application/json',
        validateStatus: (status) => status != null && status < 500,
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      );

      // Максимальное количество попыток
      const maxRetries = 3;
      int retryCount = 0;
      DioException? lastError;

      // Цикл повторных попыток
      while (retryCount < maxRetries) {
        try {
          final response = await _dio.post(
            '$_baseUrl/api/v1/auth/refresh',
            data: data,
            options: options,
          );

          // Проверка успешного ответа
          if (response.statusCode == 200 || response.statusCode == 201) {
            developer.log(
                'Успешный ответ на запрос обновления токена: ${response.data}',
                name: 'REFRESH_TOKEN');
            return RefreshTokenResponse.fromJson(response.data);
          } else {
            // Обработка других кодов ответа
            developer.log(
                'Получен неожиданный код ответа: ${response.statusCode}',
                name: 'REFRESH_TOKEN_ERROR');
            throw DioException(
              requestOptions:
                  RequestOptions(path: '$_baseUrl/api/v1/auth/refresh'),
              response: response,
              type: DioExceptionType.badResponse,
            );
          }
        } on DioException catch (e) {
          lastError = e;

          // Если токен недействителен или проблема с сетью, сразу выходим
          if (e.response?.statusCode == 401 ||
              e.response?.statusCode == 422 ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            break;
          }

          // Увеличиваем задержку между попытками
          await Future.delayed(Duration(milliseconds: 300 * (retryCount + 1)));
          retryCount++;
        }
      }

      // Обработка конкретных ошибок после всех попыток
      if (lastError != null) {
        developer.log(
            'Ошибка запроса обновления токена после $retryCount попыток: ${lastError.response?.data ?? lastError.message}',
            name: 'REFRESH_TOKEN_ERROR');

        if (lastError.response?.statusCode == 401) {
          throw Exception('Недействительный токен обновления');
        } else if (lastError.response?.statusCode == 422) {
          throw ApiError.fromJson(lastError.response?.data);
        } else if (lastError.type == DioExceptionType.connectionTimeout ||
            lastError.type == DioExceptionType.sendTimeout ||
            lastError.type == DioExceptionType.receiveTimeout) {
          throw Exception(
              'Не удалось подключиться к серверу. Проверьте интернет-соединение.');
        }

        throw lastError;
      }

      throw Exception('Не удалось обновить токен после нескольких попыток');
    } catch (e) {
      if (e is DioException || e is ApiError || e is Exception) {
        rethrow;
      }

      developer.log('Неизвестная ошибка при обновлении токена: $e',
          name: 'REFRESH_TOKEN_ERROR');
      throw Exception('Не удалось обновить токен: $e');
    }
  }

  Future<Map<String, dynamic>> socialLogin(dynamic request) async {
    try {
      String endpoint;
      Map<String, dynamic> requestData;

      if (request is VkLoginRequest) {
        endpoint = '$_baseUrl/api/v1/auth/vk';
        requestData = request.toJson();
        developer.log('🔵 VK социальная авторизация', name: 'AUTH_SERVICE');
      } else if (request is YandexLoginRequest) {
        endpoint = '$_baseUrl/api/v1/auth/yandex';
        requestData = request.toJson();
        developer.log('🟡 Yandex социальная авторизация', name: 'AUTH_SERVICE');
      } else if (request is AppleLoginRequest) {
        endpoint = '$_baseUrl/api/v1/auth/apple';
        requestData = request.toJson();
        developer.log('🍎 Apple социальная авторизация', name: 'AUTH_SERVICE');
        developer.log('🍎 Apple запрос данные: $requestData', name: 'AUTH_SERVICE');
      } else {
        throw Exception('Неподдерживаемый тип запроса: ${request.runtimeType}');
      }

      developer.log('Отправка запроса на социальную авторизацию',
          name: 'AUTH_SERVICE');
      developer.log('Endpoint: $endpoint', name: 'AUTH_SERVICE');
      developer.log('Request body: $requestData', name: 'AUTH_SERVICE');

      final response = await _dio.post(
        endpoint,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      developer.log('Ответ от сервера: ${response.data}', name: 'AUTH_SERVICE');
      developer.log('Статус код: ${response.statusCode}', name: 'AUTH_SERVICE');

      if (response.statusCode == 200) {
        if (request is AppleLoginRequest) {
          developer.log('🍎 Apple авторизация успешна!', name: 'AUTH_SERVICE');
        }
        return response.data;
      } else if (response.statusCode == 401) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      } else {
        throw ApiError.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (request is AppleLoginRequest) {
        developer.log('🍎 Ошибка Dio при Apple авторизации: ${e.message}', name: 'AUTH_SERVICE');
        developer.log('🍎 Ошибка response: ${e.response?.data}', name: 'AUTH_SERVICE');
      }
      developer.log('Ошибка Dio при социальной авторизации: ${e.message}',
          name: 'AUTH_SERVICE');
      if (e.response?.data != null) {
        throw ApiError.fromJson(e.response!.data);
      }
      rethrow;
    } catch (e) {
      if (request is AppleLoginRequest) {
        developer.log('🍎 Неизвестная ошибка при Apple авторизации: $e', name: 'AUTH_SERVICE');
      }
      developer.log('Неизвестная ошибка при социальной авторизации: $e',
          name: 'AUTH_SERVICE');
      rethrow;
    }
  }

  // Метод для выхода из аккаунта (logout)
  Future<void> logout(String accessToken) async {
    try {
      developer.log('Отправка запроса logout', name: 'LOGOUT');
      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      developer.log(
          'Ответ logout: статус ${response.statusCode}, данные: ${response.data}',
          name: 'LOGOUT');
      if (response.statusCode != 200) {
        throw Exception('Ошибка logout: ${response.statusCode}');
      }
    } on DioException catch (e) {
      developer.log('Ошибка logout: ${e.response?.data ?? e.message}',
          name: 'LOGOUT_ERROR');
      rethrow;
    }
  }

  // Метод для повторной отправки письма с подтверждением
  Future<void> resendVerificationEmail(String email) async {
    try {
      developer.log(
          'Отправка запроса на повторную отправку письма с подтверждением',
          name: 'RESEND_VERIFICATION');

      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/resend-verify-email',
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      developer.log(
          'Успешный ответ на запрос повторной отправки: ${response.data}',
          name: 'RESEND_VERIFICATION');
    } on DioException catch (e) {
      developer.log(
          'Ошибка запроса повторной отправки: ${e.response?.data ?? e.message}',
          name: 'RESEND_VERIFICATION_ERROR');
      rethrow;
    }
  }

  // Метод для проверки верификации email
  Future<Map<String, dynamic>> checkEmailVerification(
      String accessToken) async {
    try {
      developer.log(
          'Проверка верификации email, токен: ${accessToken.substring(0, 10)}...',
          name: 'AUTH_SERVICE');

      final response = await _dio.get(
        '$_baseUrl/users/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      developer.log('Ответ сервера при проверке верификации: ${response.data}',
          name: 'AUTH_SERVICE');

      if (response.statusCode == 200) {
        // Добавляем флаг is_verified в ответ
        final data = response.data as Map<String, dynamic>;
        data['is_verified'] = data['email'] != 'None';
        return data;
      } else if (response.statusCode == 403 &&
          response.data['detail'] == 'Email is not verified') {
        developer.log('Email не верифицирован (403)', name: 'AUTH_SERVICE');
        return {'is_verified': false};
      } else {
        developer.log('Неожиданный статус код: ${response.statusCode}',
            name: 'AUTH_SERVICE');
        throw Exception('Ошибка при проверке верификации email');
      }
    } on DioException catch (e) {
      developer.log('Ошибка Dio при проверке верификации: ${e.response?.data}',
          name: 'AUTH_SERVICE');
      if (e.response?.statusCode == 403 &&
          e.response?.data['detail'] == 'Email is not verified') {
        return {'is_verified': false};
      }
      rethrow;
    }
  }

  // Метод для запроса сброса пароля
  Future<void> requestPasswordReset(String email) async {
    try {
      developer.log('Отправка запроса на сброс пароля для email: $email',
          name: 'PASSWORD_RESET');

      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/reset-password',
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      developer.log('Ответ на запрос сброса пароля: ${response.data}',
          name: 'PASSWORD_RESET');
    } on DioException catch (e) {
      developer.log(
          'Ошибка запроса сброса пароля: ${e.response?.data ?? e.message}',
          name: 'PASSWORD_RESET_ERROR');
      rethrow;
    }
  }

  // Метод для установки нового пароля
  Future<void> changePassword(String token, String newPassword) async {
    try {
      developer.log('Отправка запроса на изменение пароля',
          name: 'CHANGE_PASSWORD');

      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/change-password',
        data: {
          'token': token,
          'password': newPassword,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      developer.log('Ответ на запрос изменения пароля: ${response.data}',
          name: 'CHANGE_PASSWORD');
    } on DioException catch (e) {
      developer.log(
          'Ошибка запроса изменения пароля: ${e.response?.data ?? e.message}',
          name: 'CHANGE_PASSWORD_ERROR');
      rethrow;
    }
  }
}
