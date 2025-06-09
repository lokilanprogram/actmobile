part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class FetchNotifications extends NotificationsEvent {}

class RefreshNotifications extends NotificationsEvent {}

class FetchNextPage extends NotificationsEvent {}