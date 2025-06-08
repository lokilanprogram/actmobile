import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:dio/dio.dart';

class MapApi {
  final dio = Dio();

  Future<void> updateUserLocation(double lat, double lon) async {
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
      } on DioException catch (e) {
        throw Exception(
            "Failed to update location: ${e.response?.data ?? e.message}");
      }
    }
  }
}
