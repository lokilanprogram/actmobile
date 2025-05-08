
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage storage = const FlutterSecureStorage();
const accessStorageToken = 'accessToken';
const refreshStorageToken = 'refreshToken';
const isOnboardingCompletedFlag = 'isOnboardingCompletedFlag';

Future<void> writeAuthTokens(String accessToken, String? refreshToken) async {
  await storage.write(key: accessStorageToken, value: accessToken);
  await storage.write(key: refreshStorageToken, value: refreshToken);

  print('access token inserted --- $accessToken');
  print('refresh token inserted --- $refreshToken');
}

Future<void> deleteAuthTokens() async {
  await storage.delete(key: accessStorageToken);
  await storage.delete(key: refreshStorageToken);
  print('access token deleted');
  print('refresh token deleted');
}