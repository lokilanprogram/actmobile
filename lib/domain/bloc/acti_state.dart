part of 'acti_bloc.dart';

abstract class ActiState {}

final class ActiInitial extends ActiState {}

class ActiRegisteredState extends ActiState{
  final String phone;

  ActiRegisteredState({required this.phone, });
}
class ActiRegisteredErrorState extends ActiState{}

class ActiVerifiedState extends ActiState{}

class ActiVerifiedErrorState extends ActiState{}

class ActiGotOnbordingState extends ActiState {
  final ListOnbordingModel listOnbordingModel;

  ActiGotOnbordingState({required this.listOnbordingModel});
}

class ActiGotOnbordingErrorState extends ActiState {}

class ActiSavedOnbordingState extends ActiState {}

class ActiSavedOnbordingErrorState extends ActiState {}