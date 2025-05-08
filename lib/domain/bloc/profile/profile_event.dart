part of 'profile_bloc.dart';

@immutable
abstract class ProfileEvent {}

class ProfileGetEvent extends ProfileEvent {}

class ProfileUpdateEvent extends ProfileEvent {
  final ProfileModel profileModel;

  ProfileUpdateEvent({required this.profileModel});
}