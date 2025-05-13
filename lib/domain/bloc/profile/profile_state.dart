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


class ProfileGotListEventsState extends ProfileState {
  final ProfileEventModels profileEventsModels;

  ProfileGotListEventsState({required this.profileEventsModels});

}

class ProfileGotListEventsErrorState extends ProfileState {}

class ProfileGotEventDetailState extends ProfileState {
  final EventModel eventModel;

  ProfileGotEventDetailState({required this.eventModel});
}

class ProfileGotEventDetailErrorState extends ProfileState {}