// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:acti_mobile/data/models/list_onbording_model.dart';

ProfileModel welcomeFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String welcomeToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
    String id;
    String? name;
    String? surname;
    String? email;
    String? city;
    String? bio;
    bool isOrganization;
    String? photoUrl;
    String status;
    List<EventOnboarding> categories;
    bool isEmailVerified;
    bool isProfileCompleted;
    bool? hideMyEvents;
    bool? hideAttendedEvents;
    bool notificationsEnabled;
    

    ProfileModel({
        required this.id,
        required this.name,
        required this.hideMyEvents,
        required this.hideAttendedEvents,
        required this.surname,
        required this.email,
        required this.city,
        required this.bio,
        required this.isOrganization,
        required this.photoUrl,
        required this.status,
        required this.categories,
        required this.isEmailVerified,
        required this.isProfileCompleted,
        required this.notificationsEnabled
    });

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json["id"],
        name: json["name"],
        surname: json["surname"],
        hideMyEvents: json["hide_my_events"],
        hideAttendedEvents: json["hide_attended_events"],
        email: json["email"],
        city: json["city"],
        bio: json["bio"],
        isOrganization: json["is_organization"],
        photoUrl: json["photo_url"],
        status: json["status"],
        categories: List<EventOnboarding>.from(json["categories"].map((x) => EventOnboarding.fromJson(x))),
        isEmailVerified: json["is_email_verified"],
        isProfileCompleted: json["is_profile_completed"],
        notificationsEnabled: json["notifications_enabled"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "surname": surname,
        "email": email,
        "city": city,
        "bio": bio,
        "is_organization": isOrganization,
        "photo_url": photoUrl,
        "status": status,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "is_email_verified": isEmailVerified,
        "is_profile_completed": isProfileCompleted,
        "notifications_enabled": notificationsEnabled,
    };
}

