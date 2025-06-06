part of 'auth_bloc.dart';

abstract class AuthState {}

final class ActiInitial extends AuthState {}

class AuthLoading extends AuthState {}


class AuthSuccess extends AuthState {
  final TokenResponse response;
  final VoidCallback? onTokenRefreshed;
  final String? savedEventId;

   AuthSuccess(
    this.response,
    this.onTokenRefreshed, {
    this.savedEventId,
  });

  @override
  List<Object> get props => [response];
}

class SocialAuthSuccess extends AuthState {
  final SocialLoginResponse response;

   SocialAuthSuccess(this.response);

  @override
  List<Object> get props => [response];
}

class AuthFailure extends AuthState {
  final String message;

   AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

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