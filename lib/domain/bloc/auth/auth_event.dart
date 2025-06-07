part of 'auth_bloc.dart';

abstract class AuthEvent {}

class ActiRegisterEvent extends AuthEvent {
  final String phone;

  ActiRegisterEvent({required this.phone});
}

class ActiVerifyEvent extends AuthEvent {
  final String phone;
  final String code;

  ActiVerifyEvent({required this.phone, required this.code});
}

class ActiGetOnbordingEvent extends AuthEvent {}

class ActiSaveOnbordingEvent extends AuthEvent {
  final List<EventOnboarding> listOnboarding;

  ActiSaveOnbordingEvent({required this.listOnboarding});
}

class ActiCreateActivityEvent extends AuthEvent {
  final AlterEventModel createEventModel;

  ActiCreateActivityEvent({required this.createEventModel});
}

class ActiUpdateActivityEvent extends AuthEvent {
  final AlterEventModel alterEventModel;

  ActiUpdateActivityEvent({required this.alterEventModel});
}

class SocialLoginRequested extends AuthEvent {
  final dynamic request;

  SocialLoginRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class AuthDeleteAccountEvent extends AuthEvent {}
