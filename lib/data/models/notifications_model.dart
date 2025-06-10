class NotificationsResponse {
  final int total;
  final int offset;
  final int limit;
  final List<NotificationModel> notifications;

  NotificationsResponse({
    required this.total,
    required this.offset,
    required this.limit,
    required this.notifications,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      total: json['total'] ?? 0,
      offset: json['offset'] ?? 0,
      limit: json['limit'] ?? 0,
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'offset': offset,
        'limit': limit,
        'notifications': notifications.map((e) => e.toJson()).toList(),
      };
}

class NotificationModel {
  final String id;
  final String type;
  final String content;
  final String userId;
  final String? eventId;
  final String? senderId;
  final String? chatId;
  final DateTime createdAt;
  final DateTime sentAt;
  final bool isRead;
  final EventModel? event;
  final SenderModel? sender;

  NotificationModel({
    required this.id,
    required this.type,
    required this.content,
    required this.userId,
    this.eventId,
    this.senderId,
    this.chatId,
    required this.createdAt,
    required this.sentAt,
    required this.isRead,
    this.event,
    this.sender,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      userId: json['user_id'],
      eventId: json['event_id'],
      senderId: json['sender_id'],
      createdAt: DateTime.parse(json['created_at']),
      sentAt: DateTime.parse(json['sent_at']),
      isRead: json['is_read'] ?? false,
      event: json['event'] != null ? EventModel.fromJson(json['event']) : null,
      sender:
          json['sender'] != null ? SenderModel.fromJson(json['sender']) : null,
      chatId: json["chat_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'content': content,
        'user_id': userId,
        'event_id': eventId,
        'sender_id': senderId,
        'created_at': createdAt.toIso8601String(),
        'sent_at': sentAt.toIso8601String(),
        'is_read': isRead,
        'event': event?.toJson(),
        'sender': sender?.toJson(),
      };
}

class EventModel {
  final String title;
  final String description;
  final String type;
  final String? address;
  final String dateStart;
  final String dateEnd;
  final String timeStart;
  final String timeEnd;
  final String status;
  final double price;
  final int slots;
  final double? latitude;
  final double? longitude;
  final List<String> photos;
  final List<String> restrictions;
  final bool? isRecurring;
  final String? rejectionReason;

  EventModel({
    required this.title,
    required this.description,
    required this.type,
    required this.address,
    required this.dateStart,
    required this.dateEnd,
    required this.timeStart,
    required this.timeEnd,
    required this.status,
    required this.price,
    required this.slots,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.restrictions,
    required this.isRecurring,
    required this.rejectionReason,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      title: json['title'],
      description: json['description'],
      type: json['type'],
      address: json['address'],
      dateStart: json['date_start'],
      dateEnd: json['date_end'],
      timeStart: json['time_start'],
      timeEnd: json['time_end'],
      status: json['status'],
      price: json["price"]?.toDouble() ?? 0.0,
      slots: json["slots"] ?? 0,
      latitude: json["latitude"]?.toDouble(),
      longitude: json["longitude"]?.toDouble(),
      restrictions: List<String>.from(json["restrictions"].map((x) => x)),
      photos: json["photos"] != null
          ? List<String>.from(json["photos"].map((x) => x))
          : [],
      isRecurring: json["is_recurring"] ?? false,
      rejectionReason: json['rejection_reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'type': type,
        'address': address,
        'date_start': dateStart,
        'date_end': dateEnd,
        'time_start': timeStart,
        'time_end': timeEnd,
        'status': status,
        'price': price,
        'slots': slots,
        'latitude': latitude,
        'longitude': longitude,
        'photos': photos,
        'restrictions': restrictions,
        'is_recurring': isRecurring,
        'rejection_reason': rejectionReason,
      };
}

class SenderModel {
  final String id;
  final String name;
  final String? surname;
  final String? email;
  final String? city;
  final String? bio;
  final bool isOrganization;
  final String? photoUrl;
  final String status;
  final bool isEmailVerified;
  final bool isProfileCompleted;
  final bool hideMyEvents;
  final bool hideAttendedEvents;
  final DateTime? blockShownUntil;
  final bool hasRecentBan;

  SenderModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.email,
    required this.city,
    required this.bio,
    required this.isOrganization,
    required this.photoUrl,
    required this.status,
    required this.isEmailVerified,
    required this.isProfileCompleted,
    required this.hideMyEvents,
    required this.hideAttendedEvents,
    required this.blockShownUntil,
    required this.hasRecentBan,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      city: json['city'],
      bio: json['bio'],
      isOrganization: json['is_organization'],
      photoUrl: json['photo_url'],
      status: json['status'],
      isEmailVerified: json['is_email_verified'],
      isProfileCompleted: json['is_profile_completed'],
      hideMyEvents: json['hide_my_events'],
      hideAttendedEvents: json['hide_attended_events'],
      blockShownUntil: json["block_shown_until"] != null
          ? DateTime.parse(json["block_shown_until"])
          : null,
      hasRecentBan: json["has_recent_ban"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'surname': surname,
        'email': email,
        'city': city,
        'bio': bio,
        'is_organization': isOrganization,
        'photo_url': photoUrl,
        'status': status,
        'is_email_verified': isEmailVerified,
        'is_profile_completed': isProfileCompleted,
        'hide_my_events': hideMyEvents,
        'hide_attended_events': hideAttendedEvents,
        'block_shown_until': blockShownUntil?.toIso8601String(),
        'has_recent_ban': hasRecentBan,
      };
}
