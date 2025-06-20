part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileGotState extends ProfileState {
  final ProfileModel profileModel;
  final List<SimiliarUsersModel> similiarUsersModel;
  ProfileGotState(
      {required this.profileModel, required this.similiarUsersModel});
}

class ProfileResendEmailState extends ProfileState {}

class ProfileResendEmailErrorState extends ProfileState {
  final String message;

  ProfileResendEmailErrorState({required this.message});
}

class ProfileGotErrorState extends ProfileState {}

class ProfileUpdatedState extends ProfileState {
  final ProfileModel profileModel;

  ProfileUpdatedState({required this.profileModel});
}

class ProfileBlockedAdminState extends ProfileState {
  final ProfileModel profileModel;
  ProfileBlockedAdminState({required this.profileModel});
}

class ProfileDeleteAdminState extends ProfileState {
  final ProfileModel profileModel;
  ProfileDeleteAdminState({required this.profileModel});
}

class ProfileUpdatedWithPhotoErrorState extends ProfileState {
  final ProfileModel profileModel;
  final String photoError;

  ProfileUpdatedWithPhotoErrorState({
    required this.profileModel,
    required this.photoError,
  });
}

class ProfileUpdatedErrorState extends ProfileState {
  final String errorMessage;

  ProfileUpdatedErrorState(
      {this.errorMessage = 'Произошла ошибка при обновлении профиля'});
}

class ProfileLogoutState extends ProfileState {}

class ProfileLogoutErrorState extends ProfileState {}

class ProfileDeleteState extends ProfileState {}

class ProfileDeleteErrorState extends ProfileState {}

class ProfileGotListEventsState extends ProfileState {
  final ProfileEventModels? profileEventsModels;
  final ProfileEventModels? profileVisitedEventsModels;
  final bool isVerified;
  final bool isProfileCompleted;
  final bool hasMoreEvents;
  final bool hasMoreVisitedEvents;

  ProfileGotListEventsState({
    required this.profileVisitedEventsModels,
    required this.profileEventsModels,
    required this.isVerified,
    required this.isProfileCompleted,
    this.hasMoreEvents = true,
    this.hasMoreVisitedEvents = true,
  });
}

class ProfileJoinedState extends ProfileState {
  final OrganizedEventModel eventModel;
  ProfileJoinedState({required this.eventModel});
}

class ProfileJoinedErrorState extends ProfileState {
  final String errorText;

  ProfileJoinedErrorState({required this.errorText});
}

class SearchedEventsOnMapState extends ProfileState {
  final SearchedEventsModel searchedEventsModel;

  SearchedEventsOnMapState({required this.searchedEventsModel});
}

class InitializeMapState extends ProfileState {
  final SearchedEventsModel searchedEventsModel;

  InitializeMapState({required this.searchedEventsModel});
}

class InitializeMapErrorState extends ProfileState {}

class SearchedEventsOnMapErrorState extends ProfileState {}

class ProfileReportedEventState extends ProfileState {}

class ProfileReportedEventErrorState extends ProfileState {
  final String errorText;

  ProfileReportedEventErrorState({required this.errorText});
}

class ProfileLeftState extends ProfileState {
  final OrganizedEventModel eventModel;
  ProfileLeftState({required this.eventModel});
}

class ProfileLeftErrorState extends ProfileState {
  final String errorText;

  ProfileLeftErrorState({required this.errorText});
}

class ProfileGotListEventsErrorState extends ProfileState {}

class ProfileGotEventDetailState extends ProfileState {
  final OrganizedEventModel eventModel;
  final ProfileModel profileModel;
  final ReviewsModel rewiews;

  ProfileGotEventDetailState(
      {required this.eventModel,
      required this.profileModel,
      required this.rewiews});
}

class ProfileGotEventDetailErrorState extends ProfileState {
  final String message;

  ProfileGotEventDetailErrorState(this.message);
}

class ProfileGotPublicUserState extends ProfileState {
  final PublicUserModel publicUserModel;

  ProfileGotPublicUserState({required this.publicUserModel});
}

class ProfileGotPublicUserErrorState extends ProfileState {
  final String message;

  ProfileGotPublicUserErrorState({required this.message});
}

class ProfileAcceptedUserOnActivityState extends ProfileState {
  final String userId;
  final List<Participant> participants;

  ProfileAcceptedUserOnActivityState(
      {required this.userId, required this.participants});
}

class ProfileAcceptedUserOnActivityErrorState extends ProfileState {}

class ProfileBlockedUserState extends ProfileState {}

class ProfileBlockedUserErrorState extends ProfileState {}

class ProfileReportedUserState extends ProfileState {}

class ProfileReportedUserErrorState extends ProfileState {
  final String errorText;

  ProfileReportedUserErrorState({required this.errorText});
}

class ProfileInvitedUserState extends ProfileState {}

class ProfileInvitedUserErrorState extends ProfileState {}

class ProfileCanceledActivityState extends ProfileState {}

class ProfileCanceledActivityErrorState extends ProfileState {
  final String errorText;

  ProfileCanceledActivityErrorState({required this.errorText});
}

class ProfileRecommentedUsersState extends ProfileState {
  final RecommendatedUsersModel recommendatedUsersModel;

  ProfileRecommentedUsersState({required this.recommendatedUsersModel});
}

class ProfileRecommentedUsersErrorState extends ProfileState {
  final String errorText;

  ProfileRecommentedUsersErrorState({required this.errorText});
}

class ProfilePostedReviewState extends ProfileState {}

class ProfilePostedReviewErrorState extends ProfileState {
  final String errorText;

  ProfilePostedReviewErrorState({required this.errorText});
}
