// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:acti_mobile/data/models/list_onbording_model.dart';

List<SimiliarUsersModel> welcomeFromJson(String str) =>
    List<SimiliarUsersModel>.from(
        json.decode(str).map((x) => SimiliarUsersModel.fromJson(x)));

String welcomeToJson(List<SimiliarUsersModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SimiliarUsersModel {
  String id;
  String? name;
  String? surname;
  dynamic city;
  String? photoUrl;
  int commonCategories;
  List<EventOnboarding> categories;
  Chat? chat;

  SimiliarUsersModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.city,
    required this.photoUrl,
    required this.commonCategories,
    required this.categories,
    required this.chat,
  });

  factory SimiliarUsersModel.fromJson(Map<String, dynamic> json) =>
      SimiliarUsersModel(
        id: json["id"],
        name: json["name"],
        surname: json["surname"],
        city: json["city"],
        photoUrl: json["photo_url"],
        commonCategories: json["common_categories"],
        categories: List<EventOnboarding>.from(
            json["categories"].map((x) => EventOnboarding.fromJson(x))),
        chat: json["chat"] != null ? Chat.fromJson(json["chat"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "surname": surname,
        "city": city,
        "photo_url": photoUrl,
        "common_categories": commonCategories,
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
      };
}

class Chat {
  String id;
  String type;
  String? eventId;

  Chat({
    required this.id,
    required this.type,
    required this.eventId,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json["id"],
        type: json["type"],
        eventId: json["event_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "event_id": eventId,
      };
}
