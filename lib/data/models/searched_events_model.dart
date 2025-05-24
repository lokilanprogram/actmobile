// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:acti_mobile/data/models/profile_event_model.dart';

SearchedEventsModel welcomeFromJson(String str) => SearchedEventsModel.fromJson(json.decode(str));

String welcomeToJson(SearchedEventsModel data) => json.encode(data.toJson());

class SearchedEventsModel {
    int total;
    int limit;
    int offset;
    List<OrganizedEventModel> events;

    SearchedEventsModel({
        required this.total,
        required this.limit,
        required this.offset,
        required this.events,
    });

    factory SearchedEventsModel.fromJson(Map<String, dynamic> json) => SearchedEventsModel(
        total: json["total"],
        limit: json["limit"],
        offset: json["offset"],
        events: List<OrganizedEventModel>.from(json["events"].map((x) => OrganizedEventModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "limit": limit,
        "offset": offset,
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
    };
}
