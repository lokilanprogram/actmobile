// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ProfileEventModels welcomeFromJson(String str) => ProfileEventModels.fromJson(json.decode(str));

String welcomeToJson(ProfileEventModels data) => json.encode(data.toJson());

class ProfileEventModels {
    int total;
    int limit;
    int offset;
    List<ProfileEventModel> events;

    ProfileEventModels({
        required this.total,
        required this.limit,
        required this.offset,
        required this.events,
    });

    factory ProfileEventModels.fromJson(Map<String, dynamic> json) => ProfileEventModels(
        total: json["total"],
        limit: json["limit"],
        offset: json["offset"],
        events: List<ProfileEventModel>.from(json["events"].map((x) => ProfileEventModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "limit": limit,
        "offset": offset,
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
    };
}

class ProfileEventModel {
    String id;
    String title;
    String description;
    String type;
    String address;
    DateTime dateStart;
    DateTime dateEnd;
    String timeStart;
    String timeEnd;
    int slots;
    int freeSlots;
    double latitude;
    double longitude;
    double price;
    String status;
    List<String> photos;
    List<String> restrictions;
    bool isRecurring;
    Creator creator;
    List<dynamic> participants;

    ProfileEventModel({
        required this.id,
        required this.title,
        required this.description,
        required this.type,
        required this.address,
        required this.dateStart,
        required this.dateEnd,
        required this.timeStart,
        required this.timeEnd,
        required this.slots,
        required this.freeSlots,
        required this.latitude,
        required this.longitude,
        required this.price,
        required this.status,
        required this.photos,
        required this.restrictions,
        required this.isRecurring,
        required this.creator,
        required this.participants,
    });

    factory ProfileEventModel.fromJson(Map<String, dynamic> json) => ProfileEventModel(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        type: json["type"],
        address: json["address"],
        dateStart: DateTime.parse(json["date_start"]),
        dateEnd: DateTime.parse(json["date_end"]),
        timeStart: json["time_start"],
        timeEnd: json["time_end"],
        slots: json["slots"],
        freeSlots: json["free_slots"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        price: json["price"],
        status: json["status"],
        photos: List<String>.from(json["photos"].map((x) => x)),
        restrictions: List<String>.from(json["restrictions"].map((x) => x)),
        isRecurring: json["is_recurring"],
        creator: Creator.fromJson(json["creator"]),
        participants: List<dynamic>.from(json["participants"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "type": type,
        "address": address,
        "date_start": "${dateStart.year.toString().padLeft(4, '0')}-${dateStart.month.toString().padLeft(2, '0')}-${dateStart.day.toString().padLeft(2, '0')}",
        "date_end": "${dateEnd.year.toString().padLeft(4, '0')}-${dateEnd.month.toString().padLeft(2, '0')}-${dateEnd.day.toString().padLeft(2, '0')}",
        "time_start": timeStart,
        "time_end": timeEnd,
        "slots": slots,
        "free_slots": freeSlots,
        "latitude": latitude,
        "longitude": longitude,
        "price": price,
        "status": status,
        "photos": List<dynamic>.from(photos.map((x) => x)),
        "restrictions": List<dynamic>.from(restrictions.map((x) => x)),
        "is_recurring": isRecurring,
        "creator": creator.toJson(),
        "participants": List<dynamic>.from(participants.map((x) => x)),
    };
}

class Creator {
    String name;
    String surname;
    String email;
    String city;
    String bio;
    bool isOrganization;
    String photoUrl;
    String status;
    bool isEmailVerified;
    bool isProfileCompleted;

    Creator({
        required this.name,
        required this.surname,
        required this.email,
        required this.city,
        required this.bio,
        required this.isOrganization,
        required this.photoUrl,
        required this.status,
        required this.isEmailVerified,
        required this.isProfileCompleted,
    });

    factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        name: json["name"],
        surname: json["surname"],
        email: json["email"],
        city: json["city"],
        bio: json["bio"],
        isOrganization: json["is_organization"],
        photoUrl: json["photo_url"],
        status: json["status"],
        isEmailVerified: json["is_email_verified"],
        isProfileCompleted: json["is_profile_completed"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "surname": surname,
        "email": email,
        "city": city,
        "bio": bio,
        "is_organization": isOrganization,
        "photo_url": photoUrl,
        "status": status,
        "is_email_verified": isEmailVerified,
        "is_profile_completed": isProfileCompleted,
    };
}
