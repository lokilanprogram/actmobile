
import 'dart:convert';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/chat_model.dart';
import 'package:acti_mobile/data/models/created_chat_model.dart';
import 'package:acti_mobile/data/models/message_model.dart';
import 'package:acti_mobile/data/models/all_chats_model.dart';
import 'package:http/http.dart' as http;

class ChatApi {
Future<MessageModel?> sendMessage(String chatId,String message) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.post(
    Uri.parse('$API/api/v1/chats/$chatId/messages'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
    body: jsonEncode(<String, dynamic>{'content': message}),
  );
   if (response.statusCode == 200) {
    return MessageModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}

Future<AllChatsModel?> getAllChats(String chatType) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final queries = {
      'chat_type':chatType, 
      'limit':30.toString(),
      'offset':0.toString()
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
  Future<CreatedChatModel?> createPrivateChat(String userId) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
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

  Future<ChatModel?> getChatHistory(String chatId) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.get(
    Uri.parse('$API/api/v1/chats/$chatId/history'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
    return ChatModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}
}