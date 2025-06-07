import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:acti_mobile/data/models/all_events_model.dart' as events;
import 'package:acti_mobile/data/models/alter_event_model.dart';
import 'package:acti_mobile/data/models/mapbox_reverse_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/recommendated_user_model.dart';
import 'package:acti_mobile/data/models/searched_events_model.dart';
import 'package:dio/dio.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EventsApi {
  Dio dio = Dio();
  Future<bool?> cancelActivity(String eventId, bool isRecurring) async {
    final queryParameter = {
      'cancel_recurring': isRecurring.toString(),
    };
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/events/$eventId/cancel')
            .replace(queryParameters: queryParameter),
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

  Future<bool?> acceptUserOnActivity(
      String eventId, String userId, String status) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.post(
          Uri.parse('$API/api/v1/events/$eventId/users/$userId/status'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode({"status": status}));
      if (response.statusCode == 200) {
        print(response.body);
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<RecommendatedUsersModel?> getProfileRecommendedUsers(
      String eventId) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/events/$eventId/recommendations'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return RecommendatedUsersModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<OrganizedEventModel?> getProfileEvent(String eventId) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/events/$eventId'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return OrganizedEventModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<bool?> joinEvent(String eventId) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/events/$eventId/join'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
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

  Future<bool?> deletePhotoEvent(String eventId, String photoUrl) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.delete(
          Uri.parse('$API/api/v1/events/$eventId/photo'),
          headers: {
            "Content-Type": "application/json",
            'Authorization': 'Bearer $accessToken'
          },
          body: jsonEncode(<String, dynamic>{"photo_url": photoUrl}));
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return false;
  }

  Future<SearchedEventsModel?> searchEventsOnMap(
      double latitude, double longitude,
      {Map<String, dynamic>? filters}) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      // Формируем базовые параметры
      final Map<String, dynamic> queryParameters = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'limit': 100.toString(),
        'radius': filters?['radius']?.toString() ?? '100',
      };

      // Добавляем дополнительные параметры фильтрации
      if (filters != null) {
        if (filters['restrictions'] != null) {
          queryParameters['restrictions'] = filters['restrictions'];
        }
        if (filters['duration_min'] != null) {
          queryParameters['duration_min'] = filters['duration_min'].toString();
        }
        if (filters['duration_max'] != null) {
          queryParameters['duration_max'] = filters['duration_max'].toString();
        }
        if (filters['category_ids'] != null) {
          queryParameters['category_ids'] = filters['category_ids'];
        }
        if (filters['price_min'] != null) {
          queryParameters['price_min'] = filters['price_min'].toString();
        }
        if (filters['price_max'] != null) {
          queryParameters['price_max'] = filters['price_max'].toString();
        }
        if (filters['date_from'] != null) {
          queryParameters['date_from'] = filters['date_from'];
        }
        if (filters['date_to'] != null) {
          queryParameters['date_to'] = filters['date_to'];
        }
        if (filters['time_from'] != null) {
          queryParameters['time_from'] = filters['time_from'];
        }
        if (filters['time_to'] != null) {
          queryParameters['time_to'] = filters['time_to'];
        }
      }

      // Удаляем параметры, которые равны null или строке 'null'
      queryParameters
          .removeWhere((key, value) => value == null || value == 'null');

      // Формируем URL вручную для поддержки массивов
      final baseUrl = '$API/api/v1/events/map';
      final queryParams = <String, List<String>>{};

      // Преобразуем обычные параметры
      queryParameters.forEach((key, value) {
        if (key != 'category_ids' && key != 'restrictions') {
          queryParams[key] = [value.toString()];
        }
      });

      // Добавляем restrictions как массив
      if (queryParameters['restrictions'] != null) {
        final restrictions = queryParameters['restrictions'] as List;
        queryParams['restrictions'] =
            restrictions.map((e) => e.toString()).toList();
      }

      // Добавляем category_ids как массив
      if (queryParameters['category_ids'] != null) {
        final categoryIds = queryParameters['category_ids'] as List;
        queryParams['category_ids'] =
            categoryIds.map((e) => e.toString()).toList();
      }

      final uri = Uri(
        scheme: 'http',
        host: '93.183.81.104',
        path: '/api/v1/events/map',
        queryParameters: queryParams,
      );

      developer.log('Отправляем запрос на поиск событий на карте:',
          name: 'MAP_SEARCH');
      developer.log('Параметры запроса: $queryParams', name: 'MAP_SEARCH');
      developer.log('Полный URL: ${uri.toString()}', name: 'MAP_SEARCH');

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );

      developer.log('Получен ответ от сервера:', name: 'MAP_SEARCH');
      developer.log('Статус код: ${response.statusCode}', name: 'MAP_SEARCH');
      developer.log('Тело ответа: ${response.body}', name: 'MAP_SEARCH');

      if (response.statusCode == 200) {
        return SearchedEventsModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<bool?> alterEvent(
      {required AlterEventModel alterEvent, required bool isCreated}) async {
    final accessToken = await storage.read(key: accessStorageToken);
    FormData formData;
    List<MultipartFile> photos = [];
    Response response;
    final now = DateTime.now();

    final timezoneOffset = now.timeZoneOffset; // например, Duration(hours: 7)

// Преобразовать в формат +07:00
    String offsetString =
        '${timezoneOffset.isNegative ? '-' : '+'}${timezoneOffset.inHours.abs().toString().padLeft(2, '0')}:${(timezoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    for (var photo in alterEvent.images) {
      if (!photo.contains('http://93.183.81.104')) {
        final file = File(photo);
        final bytes = file.readAsBytesSync();
        final type = file.path.split('.').last;
        final multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: file.path.split('/').last,
          contentType: DioMediaType('image', type),
        );
        photos.add(multipartFile);
      }
    }
    if (!isCreated) {
      for (var photo in alterEvent.deletedImages) {
        await EventsApi().deletePhotoEvent(alterEvent.id!, photo);
      }
    }

    final List<String> restrictions = [];
    if (alterEvent.isKidsAllowed) restrictions.add('withKids');
    if (alterEvent.withAnimals) restrictions.add('withAnimals');
    if (alterEvent.is18plus) restrictions.add('isKidsNotAllowed');
    if (alterEvent.isUnlimited) restrictions.add('isUnlimited');

    formData = FormData.fromMap({
      'title': alterEvent.title,
      'description': alterEvent.description,
      'type': alterEvent.type,
      'address': alterEvent.isOnline ? null : alterEvent.address,
      'date_start': alterEvent.isRecurring
          ? alterEvent.recurringDay
          : alterEvent.dateStart,
      'time_start': '${alterEvent.timeStart.substring(0, 8)}$offsetString',
      'time_end': '${alterEvent.timeEnd.substring(0, 8)}$offsetString',
      'price': alterEvent.price != null ? alterEvent.price.toString() : '0',
      'create_group_chat': alterEvent.isGroupChat.toString(),
      'restrictions': restrictions.isNotEmpty ? restrictions : null,
      'category_id': alterEvent.categoryId,
      'is_recurring': alterEvent.isRecurring.toString(),
      'update_recurring': alterEvent.isRecurring.toString(),
      'slots': alterEvent.isUnlimited ? 0 : alterEvent.slots.toString(),
      'photos': photos,
    });

    if (alterEvent.isOnline == false) {
      formData.fields.add(MapEntry(
          'latitude', alterEvent.selectedAddressModel!.latitude.toString()));
      formData.fields.add(MapEntry(
          'longitude', alterEvent.selectedAddressModel!.longitude.toString()));
    }

    developer.log('Отправляем данные: ${formData.fields}',
        name: 'CREATE_EVENT');
    developer.log('Отправляем restrictions: $restrictions',
        name: 'CREATE_EVENT');

    try {
      if (isCreated) {
        response = await dio.post(
          '$API/api/v1/events',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
      } else {
        response = await dio.put(
          '$API/api/v1/events/${alterEvent.id}',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
      }
      developer.log('Ответ сервера: ${response.data}', name: 'CREATE_EVENT');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to create event: ${response.statusCode} ${response.data}');
      }
    } on DioException catch (e) {
      developer.log('Ошибка: ${e.response?.data}', name: 'CREATE_EVENT');
      throw Exception('Error: ${e.response!.data['detail']}');
    }
  }

  Future<MapboxReverseModel> getMapBoxAddress(
      String latitude, String longitude) async {
    final response = await http.get(
      Uri.parse(
          'https://api.mapbox.com/search/geocode/v6/reverse?longitude=$latitude&latitude=$longitude&access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg'),
      headers: {
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      return MapboxReverseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error: ${response.body}');
    }
  }

  Future<bool?> reportUser(
      String? imagePath, String title, String userId) async {
    MultipartFile multipartFile;
    FormData formData;
    final accessToken = await storage.read(
      key: accessStorageToken,
    );
    if (imagePath != null) {
      final file = File(imagePath);
      final bytes = file.readAsBytesSync();
      final type = file.path.split('.').last;
      multipartFile = MultipartFile.fromBytes(bytes,
          filename: file.path.split('/').last,
          contentType: DioMediaType('image', type));
      formData = FormData.fromMap({'reason': title, 'photo': multipartFile});
    } else {
      formData = FormData.fromMap({
        'reason': title,
      });
    }

    final response = await dio.post(
      '$API/api/v1/users/$userId/reports',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $accessToken'
        },
      ),
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Error: ${response.statusCode}');
  }

  Future<bool?> reportEvent(
      String? imagePath, String title, String? comment, String eventId) async {
    MultipartFile multipartFile;
    FormData formData;
    final accessToken = await storage.read(
      key: accessStorageToken,
    );
    if (imagePath != null) {
      final file = File(imagePath);
      final bytes = file.readAsBytesSync();
      final type = file.path.split('.').last;
      multipartFile = MultipartFile.fromBytes(bytes,
          filename: file.path.split('/').last,
          contentType: DioMediaType('image', type));
      formData = FormData.fromMap(
          {'reason': title, 'comment': comment, 'file': multipartFile});
    } else {
      formData = FormData.fromMap({
        'reason': title,
        'comment': comment,
      });
    }

    final response = await dio.post(
      '$API/api/v1/events/$eventId/reports',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $accessToken'
        },
      ),
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Error: ${response.statusCode}');
  }

  Future<bool?> leaveEvent(String eventId) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/events/$eventId/leave'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
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

  Future<events.AllEventsModel?> searchEvents({
    required double latitude,
    required double longitude,
    int? radius,
    String? address,
    String? date_from,
    String? date_to,
    String? time_from,
    String? time_to,
    String? type,
    double? price_min,
    double? price_max,
    List<String>? restrictions,
    List<String>? category_ids,
    int? duration_min,
    int? duration_max,
    int? slots_min,
    int? slots_max,
    String? search_query,
    int offset = 0,
    int limit = 20,
  }) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      // restrictions теперь только на английском, без кириллической интерпретации
      List<String>? formattedRestrictions = restrictions;

      final queryParameters = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'limit': limit.toString(),
        'offset': offset.toString(),
        'radius': radius?.toString(),
        'address': address,
        'date_from': date_from,
        'date_to': date_to,
        'time_from': time_from,
        'time_to': time_to,
        'type': type,
        'price_min': price_min?.toString(),
        'price_max': price_max?.toString(),
        'duration_min': duration_min?.toString(),
        'duration_max': duration_max?.toString(),
        'slots_min': slots_min?.toString(),
        'slots_max': slots_max?.toString(),
        'search_query': search_query,
      };

      // Удаляем параметры, которые равны null или строке 'null'
      queryParameters
          .removeWhere((key, value) => value == null || value == 'null');

      // Формируем URL вручную для поддержки массивов
      final baseUrl = '$API/api/v1/events';
      final queryParams = <String, List<String>>{};

      // Преобразуем обычные параметры
      queryParameters.forEach((key, value) {
        if (key != 'category_ids' && key != 'restrictions') {
          queryParams[key] = [value.toString()];
        }
      });

      // Добавляем restrictions как массив
      if (formattedRestrictions != null && formattedRestrictions.isNotEmpty) {
        queryParams['restrictions'] = formattedRestrictions;
      }

      // Добавляем category_ids как массив
      if (category_ids != null && category_ids.isNotEmpty) {
        queryParams['category_ids'] = category_ids;
      }

      final uri = Uri(
        scheme: 'http',
        host: '93.183.81.104',
        path: '/api/v1/events',
        queryParameters: queryParams,
      );

      developer.log('Запрос к API: ${uri.toString()}');

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );

      developer.log('Статус ответа: ${response.statusCode}');
      developer.log('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        return events.AllEventsModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<List<events.VoteModel>> getVotesList() async {
    final accessToken = await storage.read(key: accessStorageToken);
    final url = '$API/api/v1/votes';
    final headers = {
      "Content-Type": "application/json",
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    developer.log('[VOTES] GET $url');
    developer.log('[VOTES] Headers: $headers');
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    developer.log('[VOTES] Status: ${response.statusCode}');
    developer.log('[VOTES] Response: ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List eventsList = data['events'] ?? [];
      return eventsList.map((e) => events.VoteModel.fromJson(e)).toList();
    } else {
      throw Exception('Error: ${response.body}');
    }
  }

  Future<void> changeNotificationSettings({required bool enabled}) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken == null) throw Exception('Нет accessToken');
    final response = await http.put(
      Uri.parse('$API/api/v1/users/settings/notifications'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode({'enabled': enabled}),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка уведомлений: ${response.body}');
    }
  }

  Future<void> voteForEvent(String eventId) async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken == null) throw Exception('Нет accessToken');
    final response = await http.post(
      Uri.parse('$API/api/v1/events/$eventId/votes'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken'
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка голосования: ${response.body}');
    }
  }

  Future<List<events.Category>> getCategories() async {
    final accessToken = await storage.read(key: accessStorageToken);
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/admin/categories'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => events.Category.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return [];
  }
}
