// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:acti_mobile/data/models/message_model.dart';

ChatModel welcomeFromJson(String str) => ChatModel.fromJson(json.decode(str));

String welcomeToJson(ChatModel data) => json.encode(data.toJson());

class ChatModel {
    int total;
    int offset;
    int limit;
    List<MessageModel> messages;

    ChatModel({
        required this.total,
        required this.offset,
        required this.limit,
        required this.messages,
    });

    factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        total: json["total"],
        offset: json["offset"],
        limit: json["limit"],
        messages: List<MessageModel>.from(json["messages"].map((x) => MessageModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "offset": offset,
        "limit": limit,
        "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    };
}
