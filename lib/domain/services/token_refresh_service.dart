import 'dart:async';
import 'dart:developer' as developer;
import 'package:acti_mobile/domain/api/auth/auth_api.dart';
import 'package:acti_mobile/configs/storage.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  factory TokenRefreshService() => _instance;
  TokenRefreshService._internal();

  Timer? _timer;
  final AuthApi _authApi = AuthApi();
  final SecureStorageService _storage = SecureStorageService();

  /// Запуск автообновления токена
  Future<void> start() async {
    await refreshToken(); // обновить при запуске
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 50), (_) async {
      await refreshToken();
    });
    developer.log('TokenRefreshService: таймер обновления токена запущен',
        name: 'TOKEN_REFRESH');
  }

  /// Остановить автообновление
  void stop() {
    _timer?.cancel();
    developer.log('TokenRefreshService: таймер обновления токена остановлен',
        name: 'TOKEN_REFRESH');
  }

  /// Принудительно обновить токен
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      final oldAccessToken = await _storage.getAccessToken();
      if (refreshToken == null) {
        developer.log('TokenRefreshService: refreshToken отсутствует',
            name: 'TOKEN_REFRESH');
        return;
      }
      developer.log('TokenRefreshService: старый accessToken: $oldAccessToken',
          name: 'TOKEN_REFRESH');
      developer.log(
          'TokenRefreshService: отправляю запрос на обновление токена с refreshToken: $refreshToken',
          name: 'TOKEN_REFRESH');
      final tokenModel = await _authApi.authRefreshToken();
      if (tokenModel != null) {
        developer.log(
            'TokenRefreshService: получен новый accessToken: ${tokenModel.accessToken}',
            name: 'TOKEN_REFRESH');
        developer.log(
            'TokenRefreshService: новый refreshToken: ${tokenModel.refreshToken}',
            name: 'TOKEN_REFRESH');
        developer.log('TokenRefreshService: сохраняю новые токены',
            name: 'TOKEN_REFRESH');
        // Сохраняется внутри authRefreshToken, но для явности можно продублировать:
        await _storage.writeTokens(
            tokenModel.accessToken, tokenModel.refreshToken);
        developer.log('TokenRefreshService: токены успешно сохранены',
            name: 'TOKEN_REFRESH');
      } else {
        developer.log('TokenRefreshService: не удалось обновить токен',
            name: 'TOKEN_REFRESH');
      }
    } catch (e) {
      developer.log('TokenRefreshService: ошибка обновления токена: $e',
          name: 'TOKEN_REFRESH', error: e);
      // TODO: обработать разлогинивание, если refreshToken невалиден
    }
  }
}
