// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

MessageModel welcomeFromJson(String str) => MessageModel.fromJson(json.decode(str));

String welcomeToJson(MessageModel data) => json.encode(data.toJson());
// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);
class ChatSnapshotModel {
    String type;
    MessageModel? message;

    ChatSnapshotModel({
        required this.type,
        required this.message,
    });

    factory ChatSnapshotModel.fromJson(Map<String, dynamic> json) => ChatSnapshotModel(
        type: json["type"],
        message:json["message"]!=null?
         MessageModel.fromJson(json["message"]):null,
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "message": message?.toJson(),
    };
}


class MessageModel {
    String id;
    String chatId;
    String userId;
    String content;
    String? attachmentUrl;
    String status;
    String messageType;
    DateTime createdAt;
    User user;

    MessageModel({
        required this.id,
        required this.chatId,
        required this.userId,
        required this.content,
        required this.attachmentUrl,
        required this.status,
        required this.messageType,
        required this.createdAt,
        required this.user,
    });

    factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["id"],
        chatId: json["chat_id"],
        userId: json["user_id"],
        content: json["content"],
        attachmentUrl: json["attachment_url"],
        status: json["status"],
        messageType: json["message_type"],
        createdAt: DateTime.parse(json["created_at"]),
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "chat_id": chatId,
        "user_id": userId,
        "content": content,
        "attachment_url": attachmentUrl,
        "status": status,
        "message_type": messageType,
        "created_at": createdAt.toIso8601String(),
        "user": user.toJson(),
    };
}

class User {
    String name;
    String surname;
    String email;
    String bio;
    bool isOrganization;
    String? photoUrl;
    String status;
    bool isEmailVerified;

    User({
        required this.name,
        required this.surname,
        required this.email,
        required this.bio,
        required this.isOrganization,
        required this.photoUrl,
        required this.status,
        required this.isEmailVerified,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        surname: json["surname"],
        email: json["email"],
        bio: json["bio"],
        isOrganization: json["is_organization"],
        photoUrl: json["photo_url"],
        status: json["status"],
        isEmailVerified: json["is_email_verified"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "surname": surname,
        "email": email,
        "bio": bio,
        "is_organization": isOrganization,
        "photo_url": photoUrl,
        "status": status,
        "is_email_verified": isEmailVerified,
    };
}
