import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:flutter/material.dart';

class DeeplinkService {
  static final DeeplinkService _instance = DeeplinkService._internal();
  factory DeeplinkService() => _instance;
  DeeplinkService._internal();

  StreamSubscription? _sub;
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  Future<void> initDeeplink() async {
    _appLinks = AppLinks();

    // Обработка ссылок, когда приложение запущено
    _sub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeeplink(uri);
    }, onError: (err) {
      print('Deeplink error: $err');
    });

    // Обработка ссылки, которая открыла приложение
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleDeeplink(initialUri);
      }
    } catch (e) {
      print('Initial deeplink error: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  void _handleDeeplink(Uri uri) {
    if (uri.host == 'www.acti.com') {
      if (uri.pathSegments.first == 'event') {
        final eventId = uri.pathSegments.last;
        if (eventId.isNotEmpty) {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: eventId),
            ),
          );
        }
      }
    }
  }

  String generateEventLink(String eventId) {
    // Используем только кастомную схему, которая откроет приложение напрямую
    return 'https://www.acti.com/event/$eventId';
  }
}
