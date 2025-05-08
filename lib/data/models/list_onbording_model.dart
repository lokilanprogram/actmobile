// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ListOnbordingModel welcomeFromJson(String str) => ListOnbordingModel.fromJson(json.decode(str));

String welcomeToJson(ListOnbordingModel data) => json.encode(data.toJson());

class ListOnbordingModel {
    List<EventOnboarding> categories;

    ListOnbordingModel({
        required this.categories,
    });

    factory ListOnbordingModel.fromJson(Map<String, dynamic> json) => ListOnbordingModel(
        categories: List<EventOnboarding>.from(json["categories"].map((x) => EventOnboarding.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    };
}

class EventOnboarding {
    String id;
    String name;
    String iconPath;

    EventOnboarding({
        required this.id,
        required this.name,
        required this.iconPath,
    });

    factory EventOnboarding.fromJson(Map<String, dynamic> json) => EventOnboarding(
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
