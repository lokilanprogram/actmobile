part of 'acti_bloc.dart';

abstract class ActiState {}

final class ActiInitial extends ActiState {}

class ActiRegisteredState extends ActiState{
  final AuthCodes authCodes;

  ActiRegisteredState({required this.authCodes});
}
class ActiRegisteredErrorState extends ActiState{}