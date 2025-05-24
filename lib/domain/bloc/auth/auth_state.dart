part of 'auth_bloc.dart';

abstract class AuthState {}

final class ActiInitial extends AuthState {}

class ActiRegisteredState extends AuthState{
  final String phone;

  ActiRegisteredState({required this.phone, });
}
class ActiRegisteredErrorState extends AuthState{}

class ActiVerifiedState extends AuthState{}

class ActiVerifiedErrorState extends AuthState{}

class ActiGotOnbordingState extends AuthState {
  final ListOnbordingModel listOnbordingModel;

  ActiGotOnbordingState({required this.listOnbordingModel});
}

class ActiGotOnbordingErrorState extends AuthState {}

class ActiSavedOnbordingState extends AuthState {}

class ActiSavedOnbordingErrorState extends AuthState {}

class ActiCreatedActivityState extends AuthState {}

class ActiCreatedActivityErrorState extends AuthState {}

class ActiUpdatedActivityState extends AuthState {}

class ActiUpdatedActivityErrorState extends AuthState {}