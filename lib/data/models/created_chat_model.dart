// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

CreatedChatModel welcomeFromJson(String str) => CreatedChatModel.fromJson(json.decode(str));

String welcomeToJson(CreatedChatModel data) => json.encode(data.toJson());

class CreatedChatModel {
    String id;
    String type;
    DateTime createdAt;
    String creatorId;
    String? eventId;

    CreatedChatModel({
        required this.id,
        required this.type,
        required this.createdAt,
        required this.creatorId,
        required this.eventId,
    });

    factory CreatedChatModel.fromJson(Map<String, dynamic> json) => CreatedChatModel(
        id: json["id"],
        type: json["type"],
        createdAt: DateTime.parse(json["created_at"]),
        creatorId: json["creator_id"],
        eventId: json["event_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "created_at": createdAt.toIso8601String(),
        "creator_id": creatorId,
        "event_id": eventId,
    };
}
