import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/local_city_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/public_user_model.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:dio/dio.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';

class ProfileApi {
  Dio dio = Dio();
  final storage = SecureStorageService();

  Future<ProfileModel?> getProfile() async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/users/profile'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    }
    return null;
  }

  Future<bool?> inviteUser(String userId, String eventId) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/events/$eventId/users/$userId/invite'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<bool?> blockUser(String userId) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/users/$userId/block'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        print(response.body);
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<ProfileEventModels?> getProfileListEvents() async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/users/events/my'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return ProfileEventModels.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<ProfileEventModels?> getProfileVisitedListEvents() async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/users/events/visited'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return ProfileEventModels.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<Either<PublicUserModel, String>> getPublicUser(String userId) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/users/$userId'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return Left(PublicUserModel.fromJson(jsonDecode(response.body)));
      } else if (response.statusCode == 403) {
        return Right("Пользователь вас заблокировал");
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    throw Exception('Error');
  }

  Future<LocalCityModel?> searchCity(String city) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse(
            'https://api.mapbox.com/geocoding/v5/mapbox.places/$city.json?proximity=-74.70850,40.78375&country=ru&access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return LocalCityModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<List<SimiliarUsersModel>?> getSimiliarUsers() async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/users/similar'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => SimiliarUsersModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<ProfileModel?> updateProfile(ProfileModel profileModel) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      developer.log(
        '=== HTTP запрос на обновление профиля ===\n'
        'URL: $API/api/v1/users/profile\n'
        'Метод: PUT\n'
        'Заголовки:\n'
        'Content-Type: application/json\n'
        'Authorization: Bearer ${accessToken.substring(0, 10)}...',
        name: 'ProfileApi',
      );

      final requestBody = jsonEncode(<String, dynamic>{
        "name": profileModel.name,
        "surname": profileModel.surname,
        "email": profileModel.email,
        "bio": profileModel.bio,
        "city": profileModel.city,
        "is_organization": profileModel.isOrganization,
        "categories": profileModel.categories.map((event) => event.id).toList(),
        "hide_my_events": profileModel.hideMyEvents,
        "hide_attended_events": profileModel.hideAttendedEvents
      });

      developer.log(
        'Тело запроса:\n$requestBody',
        name: 'ProfileApi',
      );

      final response = await http.put(Uri.parse('$API/api/v1/users/profile'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
          body: requestBody);

      developer.log(
        '=== HTTP ответ на обновление профиля ===\n'
        'Статус код: ${response.statusCode}\n'
        'Тело ответа:\n${response.body}',
        name: 'ProfileApi',
      );

      if (response.statusCode == 200) {
        return profileModel;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    try {
      developer.log(
        '=== HTTP запрос на обновление фото профиля ===\n'
        'URL: $API/api/v1/users/profile/photo\n'
        'Метод: POST',
        name: 'ProfileApi',
      );

      final file = File(imagePath);
      if (!await file.exists()) {
        developer.log(
          'Ошибка: Файл не существует\n'
          'Путь: $imagePath',
          name: 'ProfileApi',
          error: 'File not found',
        );
        throw Exception('Файл не найден');
      }

      final bytes = file.readAsBytesSync();
      final type = file.path.split('.').last.toLowerCase();

      developer.log(
        'Информация о файле:\n'
        'Размер: ${bytes.length} байт (${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB)\n'
        'Тип: $type\n'
        'Имя: ${file.path.split('/').last}\n'
        'Полный путь: $imagePath',
        name: 'ProfileApi',
      );

      // Проверка размера файла (5MB = 5 * 1024 * 1024 bytes)
      if (bytes.length > 5 * 1024 * 1024) {
        developer.log(
          'Ошибка: Превышен размер файла\n'
          'Текущий размер: ${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB\n'
          'Максимальный размер: 5 MB',
          name: 'ProfileApi',
          error: 'File size exceeded',
        );
        throw Exception('Размер файла превышает 5MB');
      }

      // Проверка типа файла
      if (!['png', 'jpg', 'jpeg'].contains(type)) {
        developer.log(
          'Ошибка: Неподдерживаемый формат файла\n'
          'Текущий формат: $type\n'
          'Поддерживаемые форматы: png, jpg, jpeg',
          name: 'ProfileApi',
          error: 'Unsupported file type',
        );
        throw Exception(
            'Неподдерживаемый формат файла. Используйте PNG, JPG или JPEG');
      }

      MultipartFile multipartFile = MultipartFile.fromBytes(bytes,
          filename: file.path.split('/').last,
          contentType: DioMediaType('image', type));

      final formData = FormData.fromMap({'file': multipartFile});
      final accessToken = await storage.getAccessToken();

      developer.log(
        'Отправка файла на сервер...\n'
        'Content-Type: multipart/form-data\n'
        'Authorization: Bearer ${accessToken?.substring(0, 10)}...',
        name: 'ProfileApi',
      );

      final response = await dio.post(
        '$API/api/v1/users/profile/photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );

      developer.log(
        '=== HTTP ответ на обновление фото профиля ===\n'
        'Статус код: ${response.statusCode}\n'
        'Тело ответа:\n${response.data}',
        name: 'ProfileApi',
      );

      if (response.statusCode == 200) {
        developer.log(
          'Фото профиля успешно обновлено\n'
          'Статус: 200 OK',
          name: 'ProfileApi',
        );
        return true;
      }

      developer.log(
        'Ошибка при обновлении фото профиля\n'
        'Статус код: ${response.statusCode}\n'
        'Ответ сервера: ${response.data}',
        name: 'ProfileApi',
        error: 'Server error',
      );
      throw Exception('Ошибка сервера: ${response.statusCode}');
    } catch (e) {
      developer.log(
        '=== Ошибка при обновлении фото профиля ===\n'
        'Тип ошибки: ${e.runtimeType}\n'
        'Сообщение: $e',
        name: 'ProfileApi',
        error: e,
      );
      rethrow;
    }
  }
}
