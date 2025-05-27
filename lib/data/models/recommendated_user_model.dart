// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

RecommendatedUsersModel welcomeFromJson(String str) => RecommendatedUsersModel.fromJson(json.decode(str));

String welcomeToJson(RecommendatedUsersModel data) => json.encode(data.toJson());

class RecommendatedUsersModel {
    int total;
    int limit;
    int offset;
    List<RecUser> users;

    RecommendatedUsersModel({
        required this.total,
        required this.limit,
        required this.offset,
        required this.users,
    });

    factory RecommendatedUsersModel.fromJson(Map<String, dynamic> json) => RecommendatedUsersModel(
        total: json["total"],
        limit: json["limit"],
        offset: json["offset"],
        users: List<RecUser>.from(json["users"].map((x) => RecUser.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "limit": limit,
        "offset": offset,
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
    };
}

class RecUser {
    String id;
    String? phone;
    String? name;
    String? surname;
    String? bio;
    String? email;
    String? city;
    String? status;
    num? rating;
    String? photoUrl;
    bool? isOrganization;
    DateTime? blockShownUntil;
    bool? hasRecentBan;

    RecUser({
        required this.id,
        required this.phone,
        required this.name,
        required this.surname,
        required this.bio,
        required this.email,
        required this.city,
        required this.status,
        required this.rating,
        required this.photoUrl,
        required this.isOrganization,
        required this.blockShownUntil,
        required this.hasRecentBan,
    });

    factory RecUser.fromJson(Map<String, dynamic> json) => RecUser(
        id: json["id"],
        phone: json["phone"],
        name: json["name"],
        surname: json["surname"],
        bio: json["bio"],
        email: json["email"],
        city: json["city"],
        status: json["status"],
        rating: json["rating"],
        photoUrl: json["photo_url"],
        isOrganization: json["is_organization"],
        blockShownUntil:json["block_shown_until"]!= null?
         DateTime.parse(json["block_shown_until"]):null,
        hasRecentBan: json["has_recent_ban"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "name": name,
        "surname": surname,
        "bio": bio,
        "email": email,
        "city": city,
        "status": status,
        "rating": rating,
        "photo_url": photoUrl,
        "is_organization": isOrganization,
        "has_recent_ban": hasRecentBan,
    };
}
