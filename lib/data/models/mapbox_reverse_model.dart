// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

MapboxReverseModel welcomeFromJson(String str) => MapboxReverseModel.fromJson(json.decode(str));

String welcomeToJson(MapboxReverseModel data) => json.encode(data.toJson());

class MapboxReverseModel {
    String type;
    List<Feature> features;
    String attribution;

    MapboxReverseModel({
        required this.type,
        required this.features,
        required this.attribution,
    });

    factory MapboxReverseModel.fromJson(Map<String, dynamic> json) => MapboxReverseModel(
        type: json["type"],
        features: List<Feature>.from(json["features"].map((x) => Feature.fromJson(x))),
        attribution: json["attribution"],
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "features": List<dynamic>.from(features.map((x) => x.toJson())),
        "attribution": attribution,
    };
}

class Feature {
    String type;
    String id;
    Geometry geometry;
    Properties properties;

    Feature({
        required this.type,
        required this.id,
        required this.geometry,
        required this.properties,
    });

    factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        type: json["type"],
        id: json["id"],
        geometry: Geometry.fromJson(json["geometry"]),
        properties: Properties.fromJson(json["properties"]),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "id": id,
        "geometry": geometry.toJson(),
        "properties": properties.toJson(),
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
    String mapboxId;
    String featureType;
    String fullAddress;
    String name;
    String namePreferred;
    Coordinates coordinates;
    String? placeFormatted;
    Context context;
    List<double>? bbox;

    Properties({
        required this.mapboxId,
        required this.featureType,
        required this.fullAddress,
        required this.name,
        required this.namePreferred,
        required this.coordinates,
        this.placeFormatted,
        required this.context,
        this.bbox,
    });

    factory Properties.fromJson(Map<String, dynamic> json) => Properties(
        mapboxId: json["mapbox_id"],
        featureType: json["feature_type"],
        fullAddress: json["full_address"],
        name: json["name"],
        namePreferred: json["name_preferred"],
        coordinates: Coordinates.fromJson(json["coordinates"]),
        placeFormatted: json["place_formatted"],
        context: Context.fromJson(json["context"]),
        bbox: json["bbox"] == null ? [] : List<double>.from(json["bbox"]!.map((x) => x?.toDouble())),
    );

    Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "feature_type": featureType,
        "full_address": fullAddress,
        "name": name,
        "name_preferred": namePreferred,
        "coordinates": coordinates.toJson(),
        "place_formatted": placeFormatted,
        "context": context.toJson(),
        "bbox": bbox == null ? [] : List<dynamic>.from(bbox!.map((x) => x)),
    };
}

class Context {
    Address? address;
    Postcode? street;
    Postcode? postcode;
    Place? place;
    Region? region;
    Country country;

    Context({
        this.address,
        this.street,
        this.postcode,
        this.place,
        this.region,
        required this.country,
    });

    factory Context.fromJson(Map<String, dynamic> json) => Context(
        address: json["address"] == null ? null : Address.fromJson(json["address"]),
        street: json["street"] == null ? null : Postcode.fromJson(json["street"]),
        postcode: json["postcode"] == null ? null : Postcode.fromJson(json["postcode"]),
        place: json["place"] == null ? null : Place.fromJson(json["place"]),
        region: json["region"] == null ? null : Region.fromJson(json["region"]),
        country: Country.fromJson(json["country"]),
    );

    Map<String, dynamic> toJson() => {
        "address": address?.toJson(),
        "street": street?.toJson(),
        "postcode": postcode?.toJson(),
        "place": place?.toJson(),
        "region": region?.toJson(),
        "country": country.toJson(),
    };
}

class Address {
    String mapboxId;
    String addressNumber;
    String streetName;
    String name;

    Address({
        required this.mapboxId,
        required this.addressNumber,
        required this.streetName,
        required this.name,
    });

    factory Address.fromJson(Map<String, dynamic> json) => Address(
        mapboxId: json["mapbox_id"],
        addressNumber: json["address_number"],
        streetName: json["street_name"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "address_number": addressNumber,
        "street_name": streetName,
        "name": name,
    };
}

class Country {
    String mapboxId;
    String name;
    String wikidataId;
    String countryCode;
    String countryCodeAlpha3;

    Country({
        required this.mapboxId,
        required this.name,
        required this.wikidataId,
        required this.countryCode,
        required this.countryCodeAlpha3,
    });

    factory Country.fromJson(Map<String, dynamic> json) => Country(
        mapboxId: json["mapbox_id"],
        name: json["name"],
        wikidataId: json["wikidata_id"],
        countryCode: json["country_code"],
        countryCodeAlpha3: json["country_code_alpha_3"],
    );

    Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
        "wikidata_id": wikidataId,
        "country_code": countryCode,
        "country_code_alpha_3": countryCodeAlpha3,
    };
}

class Place {
    String mapboxId;
    String name;
    String wikidataId;

    Place({
        required this.mapboxId,
        required this.name,
        required this.wikidataId,
    });

    factory Place.fromJson(Map<String, dynamic> json) => Place(
        mapboxId: json["mapbox_id"],
        name: json["name"],
        wikidataId: json["wikidata_id"],
    );

    Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
        "wikidata_id": wikidataId,
    };
}

class Postcode {
    String mapboxId;
    String name;

    Postcode({
        required this.mapboxId,
        required this.name,
    });

    factory Postcode.fromJson(Map<String, dynamic> json) => Postcode(
        mapboxId: json["mapbox_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
    };
}

class Region {
    String mapboxId;
    String name;
    String wikidataId;
    String regionCode;
    String regionCodeFull;

    Region({
        required this.mapboxId,
        required this.name,
        required this.wikidataId,
        required this.regionCode,
        required this.regionCodeFull,
    });

    factory Region.fromJson(Map<String, dynamic> json) => Region(
        mapboxId: json["mapbox_id"],
        name: json["name"],
        wikidataId: json["wikidata_id"],
        regionCode: json["region_code"],
        regionCodeFull: json["region_code_full"],
    );

    Map<String, dynamic> toJson() => {
        "mapbox_id": mapboxId,
        "name": name,
        "wikidata_id": wikidataId,
        "region_code": regionCode,
        "region_code_full": regionCodeFull,
    };
}

class Coordinates {
    double longitude;
    double latitude;
    String? accuracy;
    List<RoutablePoint>? routablePoints;

    Coordinates({
        required this.longitude,
        required this.latitude,
        this.accuracy,
        this.routablePoints,
    });

    factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
        longitude: json["longitude"]?.toDouble(),
        latitude: json["latitude"]?.toDouble(),
        accuracy: json["accuracy"],
        routablePoints: json["routable_points"] == null ? [] : List<RoutablePoint>.from(json["routable_points"]!.map((x) => RoutablePoint.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "longitude": longitude,
        "latitude": latitude,
        "accuracy": accuracy,
        "routable_points": routablePoints == null ? [] : List<dynamic>.from(routablePoints!.map((x) => x.toJson())),
    };
}

class RoutablePoint {
    String name;
    double latitude;
    double longitude;

    RoutablePoint({
        required this.name,
        required this.latitude,
        required this.longitude,
    });

    factory RoutablePoint.fromJson(Map<String, dynamic> json) => RoutablePoint(
        name: json["name"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "latitude": latitude,
        "longitude": longitude,
    };
}
