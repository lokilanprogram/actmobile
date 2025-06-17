// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:acti_mobile/data/models/profile_event_model.dart';

PublicUserModel welcomeFromJson(String str) => PublicUserModel.fromJson(json.decode(str));

String welcomeToJson(PublicUserModel data) => json.encode(data.toJson());

class PublicUserModel {
  String? userId;
    String? name;
    String? surname;
    String? email;
    String? city;
    String? bio;
    bool isOrganization;
    String? photoUrl;
    String? status;
    List<Category> categories;
    List<OrganizedEventModel>? organizedEvents;
    List<Review> reviews;
    bool? hideMyEvents;
    bool? hideAttendedEvents;
    bool? isBlockedByUser;
    String? chatId;
    double? rating;

    PublicUserModel({
      required this.userId,
      required this.chatId,
      required this.isBlockedByUser,
        required this.name,
        required this.surname,
        required this.email,
        required this.city,
        required this.bio,
        required this.isOrganization,
        required this.photoUrl,
        required this.status,
        required this.categories,
        required this.organizedEvents,
        required this.reviews,
        required this.hideMyEvents,
        required this.hideAttendedEvents,
        required this.rating,
    });

    factory PublicUserModel.fromJson(Map<String, dynamic> json) => PublicUserModel(
        name: json["name"],
        isBlockedByUser: json["is_blocked_by_user"],
        surname: json["surname"],
        email: json["email"],
        city: json["city"],
        chatId: json["chat_id"],
        bio: json["bio"],
        isOrganization: json["is_organization"],
        photoUrl: json["photo_url"],
        status: json["status"],
        categories: List<Category>.from(json["categories"].map((x) => Category.fromJson(x))),
        organizedEvents: json["organized_events"]!=null?
         List<OrganizedEventModel>.from(json["organized_events"].map((x) => OrganizedEventModel.fromJson(x))):[],
        reviews: List<Review>.from(json["reviews"].map((x) => Review.fromJson(x))),
        hideMyEvents: json["hide_my_events"],
        hideAttendedEvents: json["hide_attended_events"], userId: json['user_id'],
        rating: json["rating"]?.toDouble(),
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
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "reviews": List<dynamic>.from(reviews.map((x) => x.toJson())),
        "hide_my_events": hideMyEvents,
        "hide_attended_events": hideAttendedEvents,
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
    String name;
    String surname;
    String email;
    String city;
    String bio;
    bool isOrganization;
    String? photoUrl;
    String status;
    bool? isProfileCompleted;
    String? id;
    List<Category>? categories;

    Creator({
        required this.name,
        required this.surname,
        required this.email,
        required this.city,
        required this.bio,
        required this.isOrganization,
        required this.photoUrl,
        required this.status,
        this.isProfileCompleted,
        this.id,
        this.categories,
    });

    factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        name: json["name"],
        surname: json["surname"],
        email: json["email"],
        city: json["city"],
        bio: json["bio"],
        isOrganization: json["is_organization"],
        photoUrl: json["photo_url"] ?? '',
        status: json["status"],
        isProfileCompleted: json["is_profile_completed"],
        id: json["id"],
        //categories: json["categories"] == null ? [] : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
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
        "is_profile_completed": isProfileCompleted,
        "id": id,
        "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    };
}

class Review {
    double rating;
    String comment;
    DateTime createdAt;
    Creator user;

    Review({
        required this.rating,
        required this.comment,
        required this.createdAt,
        required this.user,
    });

    factory Review.fromJson(Map<String, dynamic> json) => Review(
        rating: json["rating"]?.toDouble(),
        comment: json["comment"],
        createdAt: DateTime.parse(json["created_at"]),
        user: Creator.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "rating": rating,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
        "user": user.toJson(),
    };
}
