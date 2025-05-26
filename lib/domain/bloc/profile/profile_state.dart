part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileGotState extends ProfileState {
  final ProfileModel profileModel;
  final List<SimiliarUsersModel> similiarUsersModel;
  ProfileGotState({required this.profileModel,required this.similiarUsersModel});
}

class ProfileGotErrorState extends ProfileState {}

class ProfileUpdatedState extends ProfileState {
  final ProfileModel profileModel;

  ProfileUpdatedState({required this.profileModel});

}

class ProfileUpdatedErrorState extends ProfileState {}

class ProfileLogoutState extends ProfileState{}
class ProfileLogoutErrorState extends ProfileState{}


class ProfileGotListEventsState extends ProfileState {
  final ProfileEventModels? profileEventsModels;
  final ProfileEventModels? profileVisitedEventsModels;
  final bool isVerified;

  ProfileGotListEventsState({required this.profileVisitedEventsModels, required this.profileEventsModels, required this.isVerified});

}

class ProfileJoinedState extends ProfileState{
  final OrganizedEventModel eventModel;
  ProfileJoinedState({required this.eventModel});
}

class ProfileJoinedErrorState extends ProfileState{
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

class InitializeMapErrorState extends ProfileState{}

class SearchedEventsOnMapErrorState extends ProfileState {}

class ProfileReportedEventState extends ProfileState{
}
class ProfileReportedEventErrorState extends ProfileState{
  final String errorText;

  ProfileReportedEventErrorState({required this.errorText});
}
class ProfileLeftState extends ProfileState{
  final OrganizedEventModel eventModel;
  ProfileLeftState({required this.eventModel});}

class ProfileLeftErrorState extends ProfileState{
  final String errorText;

  ProfileLeftErrorState({required this.errorText});
}
class ProfileGotListEventsErrorState extends ProfileState {}

class ProfileGotEventDetailState extends ProfileState {
  final OrganizedEventModel eventModel;

  ProfileGotEventDetailState({required this.eventModel});
}

class ProfileGotEventDetailErrorState extends ProfileState {}

class ProfileGotPublicUserState extends ProfileState {
  final PublicUserModel publicUserModel;

  ProfileGotPublicUserState({required this.publicUserModel});
}

class ProfileGotPublicUserErrorState extends ProfileState {}

class ProfileAcceptedUserOnActivityState extends ProfileState{
  final String userId;
  final List<Participant> participants;

  ProfileAcceptedUserOnActivityState({required this.userId, required this.participants});
}

class ProfileAcceptedUserOnActivityErrorState extends ProfileState{}

class ProfileBlockedUserState extends ProfileState {}

class ProfileBlockedUserErrorState extends ProfileState {}

class ProfileReportedUserState extends ProfileState {}

class ProfileReportedUserErrorState extends ProfileState {
  final String errorText;

  ProfileReportedUserErrorState({required this.errorText});
}

class ProfileCanceledActivityState extends ProfileState {}

class ProfileCanceledActivityErrorState extends ProfileState {
  final String errorText;

  ProfileCanceledActivityErrorState({required this.errorText});
}