// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

MapBoxModel welcomeFromJson(String str) => MapBoxModel.fromJson(json.decode(str));

class MapBoxModel {
    String type;
    List<String> query;
    List<Feature> features;
    String attribution;

    MapBoxModel({
        required this.type,
        required this.query,
        required this.features,
        required this.attribution,
    });

    factory MapBoxModel.fromJson(Map<String, dynamic> json) => MapBoxModel(
        type: json["type"],
        query: List<String>.from(json["query"].map((x) => x)),
        features: List<Feature>.from(json["features"].map((x) => Feature.fromJson(x))),
        attribution: json["attribution"],
    );

}

class Feature {
    String id;
    String? type;
    List<String>? placeType;
    num? relevance;
    Properties? properties;
    String? textRu;
    String? languageRu;
    String? placeNameRu;
    String? text;
    String? language;
    String? placeName;
    String? matchingText;
    String? matchingPlaceName;
    List<double>? center;
    Geometry? geometry;
    List<Context>? context;

    Feature({
        required this.id,
        required this.type,
        required this.placeType,
        required this.relevance,
        required this.properties,
        required this.textRu,
        required this.languageRu,
        required this.placeNameRu,
        required this.text,
        required this.language,
        required this.placeName,
        this.matchingText,
        this.matchingPlaceName,
        required this.center,
        required this.geometry,
        this.context,
    });

    factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        id: json["id"],
        type: json["type"],
        placeType: List<String>.from(json["place_type"].map((x) => x)),
        relevance: json["relevance"],
        properties: Properties.fromJson(json["properties"]),
        textRu: json["text_ru"],
        languageRu: json["language_ru"],
        placeNameRu: json["place_name_ru"],
        text: json["text"],
        language: json["language"],
        placeName: json["place_name"],
        matchingText: json["matching_text"],
        matchingPlaceName: json["matching_place_name"],
        center: List<double>.from(json["center"].map((x) => x?.toDouble())),
        geometry: Geometry.fromJson(json["geometry"]),
        context: json["context"] == null ? [] : List<Context>.from(json["context"]!.map((x) => Context.fromJson(x))),
    );

}

class Context {
    String id;
    String? mapboxId;
    String? wikidata;
    String? shortCode;
    String? textRu;
    String? languageRu;
    String? text;
    String? language;

    Context({
        required this.id,
        required this.mapboxId,
        required this.wikidata,
        required this.shortCode,
        required this.textRu,
        required this.languageRu,
        required this.text,
        required this.language,
    });

    factory Context.fromJson(Map<String, dynamic> json) => Context(
        id: json["id"],
        mapboxId: json["mapbox_id"],
        wikidata: json["wikidata"],
        shortCode: json["short_code"],
        textRu: json["text_ru"],
        languageRu: json["language_ru"],
        text: json["text"],
        language: json["language"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "mapbox_id": mapboxId,
        "wikidata": wikidata,
        "short_code": shortCode,
        "text_ru": textRu,
        "language_ru": languageRu,
        "text": text,
        "language": language,
    };
}

class Geometry {
    String type;
    List<double> coordinates;

    Geometry({
        required this.type,
        required this.coordinates,
    });

    factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
        type: json["type"],
        coordinates: List<double>.from(json["coordinates"].map((x) => x?.toDouble())),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
    };
}

class Properties {
    String? mapboxId;
    String? wikidata;
    String? shortCode;

    Properties({
        required this.mapboxId,
        required this.wikidata,
        required this.shortCode,
    });

    factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mapboxId: json["mapbox_id"],
        wikidata: json["wikidata"],
        shortCode: json["short_code"],
    );

    Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "wikidata": wikidata,
        "short_code": shortCode,
    };
}
