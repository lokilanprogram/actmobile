// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:acti_mobile/data/models/message_model.dart';

ChatMessagesModel welcomeFromJson(String str) => ChatMessagesModel.fromJson(json.decode(str));

String welcomeToJson(ChatMessagesModel data) => json.encode(data.toJson());

class ChatMessagesModel {
    int total;
    int offset;
    int limit;
    List<MessageModel> messages;

    ChatMessagesModel({
        required this.total,
        required this.offset,
        required this.limit,
        required this.messages,
    });

    factory ChatMessagesModel.fromJson(Map<String, dynamic> json) => ChatMessagesModel(
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
