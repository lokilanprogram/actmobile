class AllChatsSnapshotModel {
  String type;
  Data? data;
  String? chatId;
  String eventType;
  String? timestamp;

  AllChatsSnapshotModel({
    required this.type,
    this.data,
    this.chatId,
    required this.eventType,
    this.timestamp,
  });

  factory AllChatsSnapshotModel.fromJson(Map<String, dynamic> json) =>
      AllChatsSnapshotModel(
        type: json["type"],
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        chatId: json["chat_id"],
        eventType: json["event_type"] ?? "",
        timestamp:
            json["timestamp"] != null ? json["timestamp"].toString() : "",
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "message": data?.toJson(),
      };
}

class Data {
  String? chatId;
  String? userId;
  String? type;
  String? eventId;
  List<String>? participants;
  String? contentPreview;

  Data(
      {this.chatId,
      this.type,
      this.eventId,
      this.participants,
      this.userId,
      this.contentPreview});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
      chatId: json['chat_id'] ?? "",
      type: json['type'] ?? "",
      eventId: json['event_id'] ?? "",
      participants: json['participants'] != null
          ? List<String>.from(json['participants'])
          : null,
      userId: json["user_id"] ?? "",
      contentPreview: json["content_preview"] ?? "");

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'type': type,
      'event_id': eventId,
      'participants': participants,
    };
  }
}
