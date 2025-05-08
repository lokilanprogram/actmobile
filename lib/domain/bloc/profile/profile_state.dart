part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileGotState extends ProfileState {
  final ProfileModel profileModel;

  ProfileGotState({required this.profileModel});
}

class ProfileGotErrorState extends ProfileState {}

class ProfileUpdatedState extends ProfileState {
  final ProfileModel profileModel;

  ProfileUpdatedState({required this.profileModel});

}

class ProfileUpdatedErrorState extends ProfileState {}