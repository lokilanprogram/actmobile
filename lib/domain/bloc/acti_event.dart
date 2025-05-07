part of 'acti_bloc.dart';

abstract class ActiEvent {}

class ActiRegisterEvent extends ActiEvent {
  final String phone;

  ActiRegisterEvent({required this.phone});
}