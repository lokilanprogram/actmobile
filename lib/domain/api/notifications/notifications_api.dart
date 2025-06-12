import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/notifications_model.dart';
import 'package:dio/dio.dart';

class NotificationApi {
  final storage = SecureStorageService();
  
  Future<NotificationsResponse?> getNotifications(
      {int offset = 0, int limit = 20}) async {
    final accessToken = await storage.getAccessToken();
    Dio dio = Dio();
    Response response;

    if (accessToken != null) {
      try {
        response = await dio.get(
          '$API/api/v1/notifications',
          queryParameters: {
            'offset': offset.clamp(0, double.infinity),
            'limit': limit.clamp(1, 100),
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          return NotificationsResponse.fromJson(response.data);
        } else {
          throw Exception(
              'Failed to fetch notifications: ${response.statusCode} ${response.data}');
        }
      } on DioException catch (e) {
        throw Exception('Error: ${e.response?.data['detail'] ?? e.message}');
      }
    }

    return null;
  }
}
