part of 'acti_bloc.dart';

abstract class ActiEvent {}

class ActiRegisterEvent extends ActiEvent {
  final String phone;

  ActiRegisterEvent({required this.phone});
}



class ActiVerifyEvent extends ActiEvent {
  final String phone;
  final String code;

  ActiVerifyEvent({required this.phone, required this.code});
}
class ActiGetOnbordingEvent extends ActiEvent {}

class ActiSaveOnbordingEvent extends ActiEvent {
  final List<EventOnboarding> listOnboarding;

  ActiSaveOnbordingEvent({required this.listOnboarding});
}

class ActiCreateActivityEvent extends ActiEvent{
  final AlterEventModel  createEventModel;

  ActiCreateActivityEvent({required this.createEventModel});
}

class ActiUpdateActivityEvent extends ActiEvent{
  final AlterEventModel  alterEventModel;

  ActiUpdateActivityEvent({required this.alterEventModel});
}