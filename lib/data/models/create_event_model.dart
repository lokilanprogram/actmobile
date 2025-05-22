import 'package:image_picker/image_picker.dart';

class AlterEventModel {
  final String? id;
  final String title;
  final String description;
  final String type;
  final String address;
  final String? dateStart;
  final String? dateEnd;
  final String timeStart;
  final String timeEnd;
  final String? recurringDay;
  final double? price;
  final int? slots;
  final bool is18plus;
  final bool isOnline;
  final bool isGroupChat;
  final bool isUnlimited;
  final bool isKidsAllowed;
  final bool withAnimals;
  final double? latitude;
  final double? longitude;
  final List<String>? restrictions;
  final bool isRecurring;
  final String categoryId;
  final bool updateRecurring;
  final List<String> images;
  final List<String> deletedImages;

  AlterEventModel({
    required this.isOnline,
    required this.deletedImages,
    required this.id,
    required this.isGroupChat,
    required this.isUnlimited,
    required this.isKidsAllowed,
    required this.is18plus, 
    required this.recurringDay, 
    required this.withAnimals,
    required this.title,
    required this.description,
    required this.type,
    required this.address,
    required this.dateStart,
    this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    this.price,
    this.slots,
    this.latitude,
    this.longitude,
    this.restrictions,
    required this.isRecurring,
    required this.categoryId,
    required this.updateRecurring,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "type": type,
      "address": address,
      "date_start": dateStart,
      if (dateEnd != null) "date_end": dateEnd,
      "time_start": timeStart,
      "time_end": timeEnd,
      if (price != null) "price": price,
      if (slots != null) "slots": slots,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
      if (restrictions != null) "restrictions": restrictions,
      "is_recurring": isRecurring,
      "category_id": categoryId,
      "update_recurring": updateRecurring,
      // photos не включаем сюда напрямую — они пойдут отдельно в FormData
    };
  }
}
