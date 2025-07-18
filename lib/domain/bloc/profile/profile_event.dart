part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class ProfileGetEvent extends ProfileEvent {}

class ProfileGetSimiliarUsersEvent extends ProfileEvent {}

class ProfileResendEmailEvent extends ProfileEvent {}

class SearchEventsOnMapEvent extends ProfileEvent {
  final double latitude;
  final double longitude;
  final Map<String, dynamic>? filters;

  SearchEventsOnMapEvent({
    required this.latitude,
    required this.longitude,
    this.filters,
  });
}

class ProfileInviteUserEvent extends ProfileEvent {
  final String userId;
  final String eventId;

  ProfileInviteUserEvent({required this.userId, required this.eventId});
}

class InitializeMapEvent extends ProfileEvent {
  final double latitude;
  final double longitude;

  InitializeMapEvent({required this.latitude, required this.longitude});
}

class ProfileRecommendUsersEvent extends ProfileEvent {
  final String eventId;

  ProfileRecommendUsersEvent({required this.eventId});
}

class ProfileUpdateEvent extends ProfileEvent {
  final ProfileModel profileModel;

  ProfileUpdateEvent({
    required this.profileModel,
  });
}

class ProfileGetListEventsEvent extends ProfileEvent {
  final bool loadMoreMy;
  final bool loadMoreVisited;
  ProfileGetListEventsEvent(
      {this.loadMoreMy = false, this.loadMoreVisited = false});
}

class ProfileGetVerifiedEventsEvent extends ProfileEvent {}

class ProfileGetEventDetailEvent extends ProfileEvent {
  final String eventId;

  ProfileGetEventDetailEvent({required this.eventId});
}

class ProfileGetPublicUserEvent extends ProfileEvent {
  final String userId;

  ProfileGetPublicUserEvent({required this.userId});
}

class ProfileUnblockUserEvent extends ProfileEvent {
  final String userId;
  final bool isBlocked;

  ProfileUnblockUserEvent({required this.userId, required this.isBlocked});
}

class ProfileJoinEvent extends ProfileEvent {
  final String eventId;

  ProfileJoinEvent({required this.eventId});
}

class ProfileLeaveEvent extends ProfileEvent {
  final String eventId;

  ProfileLeaveEvent({required this.eventId});
}

class ProfileBlockUserEvent extends ProfileEvent {
  final String userId;

  ProfileBlockUserEvent({required this.userId});
}

class ProfileReportUser extends ProfileEvent {
  final String? imageUrl;
  final String userId;
  final String title;

  ProfileReportUser(
      {required this.imageUrl, required this.userId, required this.title});
}

class ProfileReportEvent extends ProfileEvent {
  final String? imageUrl;
  final String eventId;
  final String title;
  final String? comment;

  ProfileReportEvent(
      {required this.imageUrl,
      required this.eventId,
      required this.title,
      required this.comment});
}

class ProfileAcceptUserOnActivityEvent extends ProfileEvent {
  final String eventId;
  final String userId;
  final String status;

  ProfileAcceptUserOnActivityEvent(
      {required this.eventId, required this.status, required this.userId});
}

class ProfileCancelActivityEvent extends ProfileEvent {
  final String eventId;
  final bool isRecurring;

  ProfileCancelActivityEvent(
      {required this.eventId, required this.isRecurring});
}

class ProfileLogoutEvent extends ProfileEvent {}

class ProfileDeleteEvent extends ProfileEvent {}

class ProfilePostReviewEvent extends ProfileEvent {
  final ReviewPost reviewPost;
  final String eventId;

  ProfilePostReviewEvent({
    required this.reviewPost,
    required this.eventId,
  });
}

class ProfileLoadMoreMyEventsEvent extends ProfileEvent {}

class ProfileLoadMoreVisitedEventsEvent extends ProfileEvent {}
