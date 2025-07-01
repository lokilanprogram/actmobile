import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/date_utils.dart';
import 'package:acti_mobile/data/models/notifications_model.dart';
import 'package:acti_mobile/data/models/status_model.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/create_event_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/detail/event_detail_home_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/requests/event_request_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final String userId;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getIcon(notification);
    //final title = _getTitle(notification);
    final subtitle = _getSubtitle(notification);

    return ListTile(
      titleAlignment: ListTileTitleAlignment.top,
      leading: SizedBox(
        width: 60, // Ограничиваем ширину
        child: Align(
          alignment: Alignment.topCenter, // Или Alignment.topCenter и т.п.
          child: icon,
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.content,
            style: TextStyle(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w400,
                fontSize: 17.14,
                letterSpacing: 0,
                color: Colors.black),
          ),
          Text(notification.type),
          Text(
            formattedTimestamp(notification.sentAt.toLocal()),
            style: TextStyle(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: Color.fromARGB(
                  255,
                  137,
                  137,
                  137,
                )),
          ),
          //Text(notification.type),
          SizedBox(height: 5),
          _handleTap(context, notification),
        ],
      ),
      onTap: () => _handleTap(context, notification),
    );
  }

  Widget _getIcon(NotificationModel n) {
    final double radius = 24;

    if (n.sender != null) {
      final photoUrl = n.sender?.photoUrl;
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: _buildImageOrDefault(
          url: photoUrl,
          defaultAsset: 'assets/images/image_profile.png',
          radius: radius,
          isEvent: false,
        ),
      );
    }

    if (n.event != null) {
      final photoUrl = n.event?.photos.first;
      return _buildImageOrDefault(
        url: photoUrl,
        defaultAsset: 'assets/images/image_default_event.png',
        radius: radius,
        isEvent: true,
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundImage:
          const AssetImage('assets/images/image_default_event.png'),
    );
  }

  Widget _buildImageOrDefault({
    required String? url,
    required String defaultAsset,
    required double radius,
    required bool isEvent,
  }) {
    if (url == null || url.isEmpty) {
      return Image.asset(defaultAsset,
          fit: BoxFit.cover, width: radius * 2, height: radius * 2);
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(isEvent ? 10 : 100)),
      child: CachedNetworkImage(
        imageUrl: url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade300,
          width: radius * 2,
          height: radius * 2,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Image.asset(
          defaultAsset,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
        ),
      ),
    );
  }

  Widget _handleTap(BuildContext context, NotificationModel n) {
    final type = n.type;

    switch (type) {
      case 'new_message':
        return NotificationButton(
            text: "К чату",
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                            interlocutorChatId: n.chatId ?? "",
                          )));
            });
      case 'email_verification':
      case 'email_verified':
        return Container();
      case 'event_invite':
        return NotificationButton(
            text: "К заявкам",
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EventRequestScreen(
                          eventId: n.eventId ?? "",
                          participants: [],
                          completedStatus: completedStatus
                              .contains(n.event?.status ?? ""))));
            });
      case 'event_reminder':
        return NotificationButton(
            text: "К заявкам",
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EventDetailHomeScreen(eventId: n.eventId ?? "")));
            });
      case 'event_update':
      case 'new_comment':
      case 'recommendation':
      case 'time_changed':
      case 'price_changed':
        return NotificationButton(
            text: "Событие",
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EventDetailScreen(eventId: n.eventId ?? "")));
            });
      case 'event_cancelled':
      case 'event_pending':
      case 'event_approved':
      case 'event_editing':
      case 'event_rejected':
        return NotificationButton(
            text: "Событие",
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EventDetailHomeScreen(eventId: n.eventId ?? "")));
            });
      case 'event_finished':
        return NotificationButton(
            text: "Событие",
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EventDetailHomeScreen(eventId: n.eventId ?? "")));
            });
      case 'event_edited_by_admin':
        return NotificationButton(
            text: "Событие",
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EventDetailHomeScreen(eventId: n.eventId ?? "")));
            });
      case 'event_deleted_by_admin':
        return NotificationButton(
            text: "Событие",
            onTap: () async {
              await Navigator.push(
                  context, MaterialPageRoute(builder: (_) => MyEventsScreen()));
            });
      case 'report_resolved':
      case 'user_blocked':
      case 'user_banned':
      case 'system':
        return Container();
      default:
        return Container();
    }
  }

  String _getSubtitle(NotificationModel n) {
    return n.content.isNotEmpty ? n.content : 'Нет описания';
  }
}

class NotificationButton extends StatelessWidget {
  final String text;

  final Function() onTap;

  const NotificationButton({
    required this.text,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              width: 180,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 66, 147, 239),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gilroy',
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        SizedBox(width: 60),
      ],
    );
  }
}
