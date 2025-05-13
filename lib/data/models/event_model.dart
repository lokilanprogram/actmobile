// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

EventModel welcomeFromJson(String str) => EventModel.fromJson(json.decode(str));

String welcomeToJson(EventModel data) => json.encode(data.toJson());

class EventModel {
    String title;
    String description;
    String type;
    String address;
    DateTime dateStart;
    DateTime dateEnd;
    String timeStart;
    String timeEnd;
    String status;
    double price;
    int slots;
    double latitude;
    double longitude;
  List<String>? photos;
    List<String> restrictions;
    bool isRecurring;
    String id;
    String creatorId;
    String categoryId;
    DateTime createdAt;
    List<dynamic> participants;
    int freeSlots;
    Category category;
    Creator creator;

    EventModel({
        required this.title,
        required this.description,
        required this.type,
        required this.address,
        required this.dateStart,
        required this.dateEnd,
        required this.timeStart,
        required this.timeEnd,
        required this.status,
        required this.price,
        required this.slots,
        required this.latitude,
        required this.longitude,
        required this.photos,
        required this.restrictions,
        required this.isRecurring,
        required this.id,
        required this.creatorId,
        required this.categoryId,
        required this.createdAt,
        required this.participants,
        required this.freeSlots,
        required this.category,
        required this.creator,
    });

    factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        title: json["title"],
        description: json["description"],
        type: json["type"],
        address: json["address"],
        dateStart: DateTime.parse(json["date_start"]),
        dateEnd: DateTime.parse(json["date_end"]),
        timeStart: json["time_start"],
        timeEnd: json["time_end"],
        status: json["status"],
        price: json["price"],
        slots: json["slots"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        photos: List<String>.from(json["photos"].map((x) => x)),
        restrictions: List<String>.from(json["restrictions"].map((x) => x)),
        isRecurring: json["is_recurring"],
        id: json["id"],
        creatorId: json["creator_id"],
        categoryId: json["category_id"],
        createdAt: DateTime.parse(json["created_at"]),
        participants: List<dynamic>.from(json["participants"].map((x) => x)),
        freeSlots: json["free_slots"],
        category: Category.fromJson(json["category"]),
        creator: Creator.fromJson(json["creator"]),
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
        "type": type,
        "address": address,
        "date_start": "${dateStart.year.toString().padLeft(4, '0')}-${dateStart.month.toString().padLeft(2, '0')}-${dateStart.day.toString().padLeft(2, '0')}",
        "date_end": "${dateEnd.year.toString().padLeft(4, '0')}-${dateEnd.month.toString().padLeft(2, '0')}-${dateEnd.day.toString().padLeft(2, '0')}",
        "time_start": timeStart,
        "time_end": timeEnd,
        "status": status,
        "price": price,
        "slots": slots,
        "latitude": latitude,
        "longitude": longitude,
        "photos": photos,
        "restrictions": List<dynamic>.from(restrictions.map((x) => x)),
        "is_recurring": isRecurring,
        "id": id,
        "creator_id": creatorId,
        "category_id": categoryId,
        "created_at": createdAt.toIso8601String(),
        "participants": List<dynamic>.from(participants.map((x) => x)),
        "free_slots": freeSlots,
        "category": category.toJson(),
        "creator": creator.toJson(),
    };
}

class Category {
    String id;
    String name;
    String iconPath;

    Category({
        required this.id,
        required this.name,
        required this.iconPath,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        iconPath: json["icon_path"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon_path": iconPath,
    };
}

class Creator {
    String id;
    String phone;
    String name;
    String surname;
    String bio;
    String email;
    String status;
    double rating;
    String? photoUrl;

    Creator({
        required this.id,
        required this.phone,
        required this.name,
        required this.surname,
        required this.bio,
        required this.email,
        required this.status,
        required this.rating,
        required this.photoUrl,
    });

    factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["id"],
        phone: json["phone"],
        name: json["name"],
        surname: json["surname"],
        bio: json["bio"],
        email: json["email"],
        status: json["status"],
        rating: json["rating"],
        photoUrl: json["photo_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "name": name,
        "surname": surname,
        "bio": bio,
        "email": email,
        "status": status,
        "rating": rating,
        "photo_url": photoUrl,
    };
}
