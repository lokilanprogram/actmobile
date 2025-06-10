import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:dio/dio.dart';

class MapApi {
  final dio = Dio();
  static DateTime? _lastUpdated;

  Future<void> updateUserLocation(double lat, double lon) async {
    final now = DateTime.now();

    if (_lastUpdated != null && now.difference(_lastUpdated!).inSeconds < 10) {
      // Пропустить обновление, если прошло меньше 10 секунд
      return;
    }

    final accessToken = await storage.read(key: accessStorageToken);

    if (accessToken != null) {
      try {
        await dio.patch(
          '$API/api/v1/users/location',
          data: {
            "latitude": lat,
            "longitude": lon,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
        _lastUpdated = now; // Обновляем таймер после успешного вызова
      } on DioException catch (e) {
        throw Exception(
            "Failed to update location: ${e.response?.data ?? e.message}");
      }
    }
  }
}
