import 'dart:convert';

import 'dart:io';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/chat_info_model.dart';
import 'package:acti_mobile/data/models/chat_model.dart';
import 'package:acti_mobile/data/models/created_chat_model.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/data/models/all_chats_model.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:dio/src/multipart_file.dart';
import 'package:dio/src/form_data.dart';

class ChatApi {
  final storage = SecureStorageService();

  Future<Either<String, bool>> sendFileMessage(
      String chatId, String message, String imagePath) async {
    final accessToken = await storage.getAccessToken();
    Dio dio = Dio();
    Response response;
    if (accessToken != null) {
      final file = File(imagePath);
      final bytes = file.readAsBytesSync();
      final type = file.path.split('.').last;
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: file.path.split('/').last,
        contentType: DioMediaType('image', type),
      );

      FormData formData =
          FormData.fromMap({'content': message, 'file': multipartFile});
      try {
        response = await dio.post(
          '$API/api/v1/chats/$chatId/files',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          print(response.data);
          return Right(true);
        } else {
          return Left(response.data['detail']);
        }
      } on DioException catch (e) {
        throw Exception('Error: ${e.response!.data['detail']}');
      }
    }
    return Left('No access token');
  }

  Future<Either<String, bool>> sendMessage(String chatId, String message) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/chats/$chatId/messages'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(<String, dynamic>{'content': message}),
      );
      if (response.statusCode == 200) {
        return Right(true);
      } else if (response.statusCode == 403) {
        return Left("Пользователь вас заблокировал");
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return Left('No access token');
  }

  Future<bool?> deleteChat(
    String chatId,
  ) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.delete(
        Uri.parse('$API/api/v1/chats/$chatId'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<AllChatsModel?> getAllChats(String chatType) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final queries = {
        'chat_type': chatType,
        'limit': 30.toString(),
        'offset': 0.toString()
      };
      final response = await http.get(
        Uri.parse('$API/api/v1/chats').replace(queryParameters: queries),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return AllChatsModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<ChatInfoModel?> getChatInfo(String chatId) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.get(
        Uri.parse('$API/api/v1/chats/$chatId'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
      );
      if (response.statusCode == 200) {
        return ChatInfoModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<CreatedChatModel?> createPrivateChat(String userId) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken != null) {
      final response = await http.post(
        Uri.parse('$API/api/v1/chats/private'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode(<String, dynamic>{'user_id': userId}),
      );
      if (response.statusCode == 200) {
        return CreatedChatModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error: ${response.body}');
      }
    }
    return null;
  }

  Future<ChatMessagesModel?> getChatHistory({
    required String chatId,
    required int offset,
    int limit = 50,
  }) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken == null) return null;

    final uri = Uri.parse('$API/api/v1/chats/$chatId/history')
        .replace(queryParameters: {
      'offset': offset.toString(),
      'limit': limit.toString(),
    });

    final response = await http.get(uri, headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken',
    });

    if (response.statusCode == 200) {
      return ChatMessagesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error: ${response.body}');
    }
  }
}
