// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ChatInfoModel welcomeFromJson(String str) => ChatInfoModel.fromJson(json.decode(str));

String welcomeToJson(ChatInfoModel data) => json.encode(data.toJson());

class ChatInfoModel {
    String id;
    String type;
    DateTime createdAt;
    String creatorId;
    String? eventId;
    int unreadCount;
    LastMessage lastMessage;
    List<User> users;
    Event? event;

    ChatInfoModel({
        required this.id,
        required this.type,
        required this.createdAt,
        required this.creatorId,
        required this.eventId,
        required this.unreadCount,
        required this.lastMessage,
        required this.users,
        required this.event,
    });

    factory ChatInfoModel.fromJson(Map<String, dynamic> json) => ChatInfoModel(
        id: json["id"],
        type: json["type"],
        createdAt: DateTime.parse(json["created_at"]),
        creatorId: json["creator_id"],
        eventId: json["event_id"]!= null? json["event_id"]:null,
        unreadCount: json["unread_count"],
        lastMessage: LastMessage.fromJson(json["last_message"]),
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
        event:json["event"]!= null? Event.fromJson(json["event"]):null,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "created_at": createdAt.toIso8601String(),
        "creator_id": creatorId,
        "event_id": eventId,
        "unread_count": unreadCount,
        "last_message": lastMessage.toJson(),
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
        "event": event?.toJson(),
    };
}

class Event {
    String title;
    String description;
    String address;
    DateTime dateStart;
    DateTime dateEnd;
    String timeStart;
    String timeEnd;
    double price;
    int slots;
    double? latitude;
    double? longitude;
    List<String>? photos;
    List<String> restrictions;
    bool isRecurring;

    Event({
        required this.title,
        required this.description,
        required this.address,
        required this.dateStart,
        required this.dateEnd,
        required this.timeStart,
        required this.timeEnd,
        required this.price,
        required this.slots,
        required this.latitude,
        required this.longitude,
        required this.photos,
        required this.restrictions,
        required this.isRecurring,
    });

    factory Event.fromJson(Map<String, dynamic> json) => Event(
        title: json["title"],
        description: json["description"],
        address: json["address"],
        dateStart: DateTime.parse(json["date_start"]),
        dateEnd: DateTime.parse(json["date_end"]),
        timeStart: json["time_start"],
        timeEnd: json["time_end"],
        price: json["price"],
        slots: json["slots"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        photos:json["photos"]!=null?
         List<String>.from(json["photos"].map((x) => x)):[],
        restrictions: List<String>.from(json["restrictions"].map((x) => x)),
        isRecurring: json["is_recurring"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "address": address,
        "date_start": "${dateStart.year.toString().padLeft(4, '0')}-${dateStart.month.toString().padLeft(2, '0')}-${dateStart.day.toString().padLeft(2, '0')}",
        "date_end": "${dateEnd.year.toString().padLeft(4, '0')}-${dateEnd.month.toString().padLeft(2, '0')}-${dateEnd.day.toString().padLeft(2, '0')}",
        "time_start": timeStart,
        "time_end": timeEnd,
        "price": price,
        "slots": slots,
        "latitude": latitude,
        "longitude": longitude,
        "restrictions": List<dynamic>.from(restrictions.map((x) => x)),
        "is_recurring": isRecurring,
    };
}

class LastMessage {
    String id;
    String chatId;
    String userId;
    String content;
    String? attachmentUrl;
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
    String id;
    String name;
    String? surname;
    String? email;
    String? bio;
    bool? isOrganization;
    String? photoUrl;
    String? status;
    bool? isEmailVerified;

    User({
        required this.id,
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
        id: json["id"],
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
        "id": id,
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
