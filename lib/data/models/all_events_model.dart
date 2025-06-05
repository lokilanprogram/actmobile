import 'dart:convert';

class AllEventsModel {
  final int total;
  final int limit;
  final int offset;
  final List<Event> events;

  AllEventsModel({
    required this.total,
    required this.limit,
    required this.offset,
    required this.events,
  });

  factory AllEventsModel.fromJson(Map<String, dynamic> json) => AllEventsModel(
        total: json["total"] ?? 0,
        limit: json["limit"] ?? 0,
        offset: json["offset"] ?? 0,
        events: json["events"] != null
            ? List<Event>.from(json["events"].map((x) => Event.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "limit": limit,
        "offset": offset,
        "events": List<dynamic>.from(events.map((x) => x.toJson())),
      };
}

class Event {
  final String id;
  final String creatorId;
  final String categoryId;
  final String title;
  final String description;
  final String type;
  final String? address;
  final double? latitude;
  final double? longitude;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String timeStart;
  final String timeEnd;
  final String status;
  final double price;
  final int slots;
  final bool isRecurring;
  final String? recurringDay;
  final List<String> restrictions;
  final List<String> photos;
  final DateTime createdAt;
  final String? joinStatus;
  final int freeSlots;
  final Category category;
  final Creator creator;

  Event({
    required this.id,
    required this.creatorId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.type,
    this.address,
    this.latitude,
    this.longitude,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
    required this.price,
    required this.slots,
    required this.isRecurring,
    this.recurringDay,
    required this.restrictions,
    required this.photos,
    required this.createdAt,
    this.joinStatus,
    required this.freeSlots,
    required this.category,
    required this.creator,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json["id"],
        creatorId: json["creator_id"],
        categoryId: json["category_id"],
        title: json["title"],
        description: json["description"],
        type: json["type"],
        address: json["address"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        dateStart: DateTime.parse(json["date_start"]),
        dateEnd: DateTime.parse(json["date_end"]),
        timeStart: json["time_start"],
        timeEnd: json["time_end"],
        status: json["status"],
        price: json["price"]?.toDouble() ?? 0.0,
        slots: json["slots"] ?? 0,
        isRecurring: json["is_recurring"] ?? false,
        recurringDay: json["recurring_day"],
        restrictions: List<String>.from(json["restrictions"].map((x) => x)),
        photos: json["photos"] != null
            ? List<String>.from(json["photos"].map((x) => x))
            : [],
        createdAt: DateTime.parse(json["created_at"]),
        joinStatus: json["join_status"],
        freeSlots: json["free_slots"] ?? 0,
        category: Category.fromJson(json["category"]),
        creator: Creator.fromJson(json["creator"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "creator_id": creatorId,
        "category_id": categoryId,
        "title": title,
        "description": description,
        "type": type,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "date_start": dateStart.toIso8601String(),
        "date_end": dateEnd.toIso8601String(),
        "time_start": timeStart,
        "time_end": timeEnd,
        "status": status,
        "price": price,
        "slots": slots,
        "is_recurring": isRecurring,
        "recurring_day": recurringDay,
        "restrictions": List<dynamic>.from(restrictions.map((x) => x)),
        "photos": List<dynamic>.from(photos.map((x) => x)),
        "created_at": createdAt.toIso8601String(),
        "join_status": joinStatus,
        "free_slots": freeSlots,
        "category": category.toJson(),
        "creator": creator.toJson(),
      };
}

class Category {
  final String id;
  final String name;
  final String iconPath;

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
  final String id;
  final String phone;
  final String name;
  final String? surname;
  final String? bio;
  final String? email;
  final String? city;
  final String status;
  final double rating;
  final String? photoUrl;
  final bool isOrganization;
  final DateTime? blockShownUntil;
  final bool hasRecentBan;

  Creator({
    required this.id,
    required this.phone,
    required this.name,
    this.surname,
    this.bio,
    this.email,
    this.city,
    required this.status,
    required this.rating,
    this.photoUrl,
    required this.isOrganization,
    this.blockShownUntil,
    required this.hasRecentBan,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
        id: json["id"],
        phone: json["phone"],
        name: json["name"],
        surname: json["surname"],
        bio: json["bio"],
        email: json["email"],
        city: json["city"],
        status: json["status"],
        rating: json["rating"]?.toDouble() ?? 0.0,
        photoUrl: json["photo_url"],
        isOrganization: json["is_organization"] ?? false,
        blockShownUntil: json["block_shown_until"] != null
            ? DateTime.parse(json["block_shown_until"])
            : null,
        hasRecentBan: json["has_recent_ban"] ?? false,
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
        "block_shown_until": blockShownUntil?.toIso8601String(),
        "has_recent_ban": hasRecentBan,
      };
}

class VoteModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final String time;
  final int votes;
  final bool is18plus;
  final bool userVoted;

  VoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.time,
    required this.votes,
    required this.is18plus,
    required this.userVoted,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) {
    print('VoteModel.fromJson входные данные: $json');
    final timeStart =
        json['time_start']?.toString().split('+')[0].substring(0, 5) ?? '';
    final timeEnd =
        json['time_end']?.toString().split('+')[0].substring(0, 5) ?? '';
    final formattedTime = '$timeStart-$timeEnd';

    final model = VoteModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      imageUrl: json['photos'] ?? '',
      date: DateTime.parse(json['date_start']),
      time: formattedTime,
      votes: json['vote_count'] ?? 0,
      is18plus: json['is18plus'] ?? false,
      userVoted: json['user_voted'] ?? false,
    );
    print('VoteModel.fromJson созданная модель: imageUrl=${model.imageUrl}');
    return model;
  }
}

  // factory VoteModel.fromJson(Map<String, dynamic> json) => VoteModel(
  //       id: json['id'],
  //       title: json['title'],
  //       description: json['description'] ?? '',
  //       imageUrl: json['image_url'] ?? '',
  //       date: DateTime.parse(json['date']),
  //       time: json['time'],
  //       votes: json['votes'] ?? 0,
  //       is18plus: json['is18plus'] ?? false,
  //       userVoted: json['user_voted'] ?? false,
  //     );
// }
