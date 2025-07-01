import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/domain/bloc/notifications/notifications_bloc.dart';
import 'package:acti_mobile/domain/services/token_refresh_service.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/notifications/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final ScrollController _scrollController;
  late final SecureStorageService service;
  String userId = '';

  @override
  void initState() {
    super.initState();
    service = SecureStorageService();
    initService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(FetchNotifications());
    });
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void initService() async {
    userId = await service.getUserId() ?? '';
    if (userId.isEmpty) {
      await service.deleteAll();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const InitialScreen()),
        (route) => false,
      );
    }
  }

  void _onScroll() {
    final bloc = context.read<NotificationBloc>();
    final state = bloc.state;
    if (state is NotificationLoaded && !state.hasReachedMax) {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        bloc.add(FetchNextPage());
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              'Уведомления',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 23,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text('Нет уведомлений.'));
            }

            return SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(RefreshNotifications());
                },
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: state.notifications.length +
                      (state.hasReachedMax ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index >= state.notifications.length) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    final notification = state.notifications[index];
                    return NotificationTile(
                        notification: notification, userId: userId);
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 5),
                      child: Divider(),
                    );
                  },
                ),
              ),
            );
          } else if (state is NotificationError) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
