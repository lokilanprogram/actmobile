// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

AllChatsModel welcomeFromJson(String str) => AllChatsModel.fromJson(json.decode(str));

String welcomeToJson(AllChatsModel data) => json.encode(data.toJson());

class AllChatsModel {
    int total;
    int offset;
    int limit;
    List<Chat> chats;

    AllChatsModel({
        required this.total,
        required this.offset,
        required this.limit,
        required this.chats,
    });

    factory AllChatsModel.fromJson(Map<String, dynamic> json) => AllChatsModel(
        total: json["total"],
        offset: json["offset"],
        limit: json["limit"],
        chats: List<Chat>.from(json["chats"].map((x) => Chat.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "offset": offset,
        "limit": limit,
        "chats": List<dynamic>.from(chats.map((x) => x.toJson())),
    };
}

class Chat {
    String id;
    String type;
    DateTime createdAt;
    String creatorId;
    dynamic eventId;
    LastMessage? lastMessage;
    List<User> users;
    dynamic event;

    Chat({
        required this.id,
        required this.type,
        required this.createdAt,
        required this.creatorId,
        required this.eventId,
        required this.lastMessage,
        required this.users,
        required this.event,
    });

    factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"],
        type: json["type"],
        createdAt: DateTime.parse(json["created_at"]),
        creatorId: json["creator_id"],
        eventId: json["event_id"],
        lastMessage: json["last_message"] == null ? null : LastMessage.fromJson(json["last_message"]),
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
        event: json["event"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "created_at": createdAt.toIso8601String(),
        "creator_id": creatorId,
        "event_id": eventId,
        "last_message": lastMessage?.toJson(),
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
        "event": event,
    };
}

class LastMessage {
    String id;
    String chatId;
    String userId;
    String content;
    dynamic attachmentUrl;
    String status;
    String messageType;
    DateTime createdAt;
    User user;

    LastMessage({
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

    factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
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
    String? surname;
    String? email;
    String? bio;
    bool? isOrganization;
    String? photoUrl;
    String status;
    bool? isEmailVerified;

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
