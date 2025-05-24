class LocalCityModel {
  final List<String> cities;

  LocalCityModel({required this.cities});

  factory LocalCityModel.fromJson(Map<String, dynamic> json) {
    final features = json['features'] as List;
    final cities = features.map((f) => f['place_name'] as String).toList();
    return LocalCityModel(cities: cities);
  }
}