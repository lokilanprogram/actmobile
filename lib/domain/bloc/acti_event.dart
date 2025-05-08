part of 'acti_bloc.dart';

abstract class ActiEvent {}

class ActiRegisterEvent extends ActiEvent {
  final String phone;

  ActiRegisterEvent({required this.phone});
}

class ActiVerifyEvent extends ActiEvent {
  final String phone;
  final AuthCodesModel authCodes;

  ActiVerifyEvent({required this.phone, required this.authCodes});
}
class ActiGetOnbordingEvent extends ActiEvent {}

class ActiSaveOnbordingEvent extends ActiEvent {
  final List<EventOnboarding> listOnboarding;

  ActiSaveOnbordingEvent({required this.listOnboarding});
}