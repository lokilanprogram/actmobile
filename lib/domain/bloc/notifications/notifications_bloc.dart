import 'package:acti_mobile/data/models/notifications_model.dart';
import 'package:acti_mobile/domain/api/notifications/notifications_api.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationApi _notificationApi;

  int _offset = 0;
  final int _limit = 20;
  bool _isFetching = false;

  NotificationBloc({NotificationApi? notificationApi})
      : _notificationApi = notificationApi ?? NotificationApi(),
        super(NotificationInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<FetchNextPage>(_onFetchNextPage);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onFetchNotifications(
      FetchNotifications event, Emitter<NotificationsState> emit) async {
    emit(NotificationLoading());
    _offset = 0;

    try {
      final notifications = await _fetchNotifications(_offset);
      _offset += notifications.length;

      emit(NotificationLoaded(
        notifications: notifications,
        hasReachedMax: notifications.length < _limit,
      ));
    } catch (e) {
      debugPrint('FetchNotifications error: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onFetchNextPage(
      FetchNextPage event, Emitter<NotificationsState> emit) async {
    final currentState = state;

    if (currentState is NotificationLoaded &&
        !_isFetching &&
        !currentState.hasReachedMax) {
      _isFetching = true;

      try {
        final newNotifications = await _fetchNotifications(_offset);
        final allNotifications = [
          ...currentState.notifications,
          ...newNotifications
        ];

        emit(NotificationLoaded(
          notifications: allNotifications,
          hasReachedMax: newNotifications.length < _limit,
        ));

        _offset += newNotifications.length;
      } catch (e) {
        debugPrint('FetchNextPage error: $e');
        // Keep previous loaded state; optionally log or show snackbar in UI
      } finally {
        _isFetching = false;
      }
    }
  }

  Future<void> _onRefreshNotifications(
      RefreshNotifications event, Emitter<NotificationsState> emit) async {
    _offset = 0;

    try {
      final notifications = await _fetchNotifications(_offset);
      _offset += notifications.length;

      emit(NotificationLoaded(
        notifications: notifications,
        hasReachedMax: notifications.length < _limit,
      ));
    } catch (e) {
      debugPrint('RefreshNotifications error: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<List<NotificationModel>> _fetchNotifications(int offset) async {
    final response = await _notificationApi.getNotifications(
      offset: offset,
      limit: _limit,
    );
    return response?.notifications ?? [];
  }
}
