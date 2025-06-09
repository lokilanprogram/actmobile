part of 'notifications_bloc.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationsState {}

class NotificationLoading extends NotificationsState {}

class NotificationLoaded extends NotificationsState {
  final List<NotificationModel> notifications;
  final bool hasReachedMax;

  const NotificationLoaded({
    required this.notifications,
    required this.hasReachedMax,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    bool? hasReachedMax,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object> get props => [notifications, hasReachedMax];
}

class NotificationError extends NotificationsState {
  final String message;

  const NotificationError(this.message);
}
