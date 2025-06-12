import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _userIdKey = 'userIdStorage';
  static const _userIsVerifiedKey = 'userIsVerifyStorage';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> writeTokens(String accessToken, String? refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  Future<void> deleteAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userIsVerifiedKey);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);
  Future<String?> getUserId() => _storage.read(key: _userIdKey);
  Future<bool> isUserVerified() async {
    final value = await _storage.read(key: _userIsVerifiedKey);
    return value == 'true';
  }

  Future<void> setUserVerified(bool verified) =>
      _storage.write(key: _userIsVerifiedKey, value: verified.toString());
  Future<void> setUserId(String userId) =>
      _storage.write(key: _userIdKey, value: userId.toString());
}
