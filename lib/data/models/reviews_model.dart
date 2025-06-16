import 'dart:convert';

class ReviewsModel {
  final int total;
  final int offset;
  final int limit;
  final List<Review> reviews;

  ReviewsModel({
    required this.total,
    required this.offset,
    required this.limit,
    required this.reviews,
  });

  factory ReviewsModel.fromJson(Map<String, dynamic> json) {
    return ReviewsModel(
      total: json['total'] as int,
      offset: json['offset'] as int,
      limit: json['limit'] as int,
      reviews: (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'offset': offset,
      'limit': limit,
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }
}

class Review {
  final String id;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final ReviewUser user;
  final String eventId;

  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.user,
    required this.eventId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      rating: json['rating'] as double,
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: ReviewUser.fromJson(json['user'] as Map<String, dynamic>),
      eventId: json['event_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'user': user.toJson(),
      'event_id': eventId,
    };
  }
}

class ReviewUser {
  final String id;
  final String phone;
  final String name;
  final String surname;
  final String bio;
  final String email;
  final String status;
  final double rating;
  final String? photoUrl;
  final DateTime? blockShownUntil;
  final bool hasRecentBan;

  ReviewUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.surname,
    required this.bio,
    required this.email,
    required this.status,
    required this.rating,
    required this.photoUrl,
    this.blockShownUntil,
    required this.hasRecentBan,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      bio: json['bio'] as String,
      email: json['email'] as String,
      status: json['status'] as String,
      rating: json['rating'] as double,
      photoUrl: json['photo_url'] ?? "",
      blockShownUntil: json['block_shown_until'] != null
          ? DateTime.parse(json['block_shown_until'] as String)
          : null,
      hasRecentBan: json['has_recent_ban'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'surname': surname,
      'bio': bio,
      'email': email,
      'status': status,
      'rating': rating,
      'photo_url': photoUrl,
      'block_shown_until': blockShownUntil?.toIso8601String(),
      'has_recent_ban': hasRecentBan,
    };
  }
}

class ReviewPost {
  final int rating;
  final String comment;

  ReviewPost({required this.rating, required this.comment});

  factory ReviewPost.fromJson(Map<String, dynamic> json) {
    return ReviewPost(
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}