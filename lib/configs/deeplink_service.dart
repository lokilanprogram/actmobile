import 'dart:async';
import 'package:acti_mobile/main.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:app_links/app_links.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class DeeplinkService {
  static final DeeplinkService _instance = DeeplinkService._internal();
  factory DeeplinkService() => _instance;
  DeeplinkService._internal();

  StreamSubscription? _sub;
  late AppLinks _appLinks;
  bool _isInitialized = false;

  /// Инициализация сервиса deep links
  Future<void> initDeeplink() async {
    if (_isInitialized) return;

    try {
      _appLinks = AppLinks();

      // Обработка ссылок, когда приложение запущено
      _sub = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          developer.log('Deep link received: $uri', name: 'DEEPLINK_SERVICE');
          _handleDeeplink(uri);
        },
        onError: (err) {
          developer.log('Deep link error: $err', name: 'DEEPLINK_SERVICE');
        },
      );

      // Обработка ссылки, которая открыла приложение
      try {
        final initialUri = await _appLinks.getInitialAppLink();
        if (initialUri != null) {
          developer.log('Initial deep link: $initialUri',
              name: 'DEEPLINK_SERVICE');
          _handleDeeplink(initialUri);
        }
      } catch (e) {
        developer.log('Initial deeplink error: $e', name: 'DEEPLINK_SERVICE');
      }

      _isInitialized = true;
      developer.log('Deep link service initialized successfully',
          name: 'DEEPLINK_SERVICE');
    } catch (e) {
      developer.log('Failed to initialize deep link service: $e',
          name: 'DEEPLINK_SERVICE');
    }
  }

  /// Обработка deep link
  void _handleDeeplink(Uri uri) {
    developer.log('Processing deep link: $uri', name: 'DEEPLINK_SERVICE');

    // Обработка кастомной схемы acti://api.actiadmin.ru/event/{eventId}
    if (uri.scheme == 'acti' && uri.host == 'api.actiadmin.ru') {
      if (uri.pathSegments[0] == 'event') {
        final eventId = uri.pathSegments[1];
        if (eventId.isNotEmpty) {
          _navigateToEvent(eventId);
          return;
        }
      } else if (uri.pathSegments.length >= 2 &&
          uri.pathSegments[3] == "verify-email") {
        _navigateToMain(uri);
        return;
      }
    }

    // Обработка universal links https://api.actiadmin.ru/event/{eventId}
    if (uri.scheme == 'https' && uri.host == 'api.actiadmin.ru') {
      if (uri.pathSegments[0] == 'event') {
        final eventId = uri.pathSegments[1];
        if (eventId.isNotEmpty) {
          _navigateToEvent(eventId);
          return;
        }
      } else if (uri.pathSegments.length >= 2 &&
          uri.pathSegments[3] == "verify-email") {
        _navigateToMain(uri);
        return;
      }
    }

    // Обработка Yandex OAuth callback
    if (uri.scheme == 'acti' &&
        uri.host == 'auth' &&
        uri.path.contains('yandex_callback')) {
      developer.log('Yandex OAuth callback detected', name: 'DEEPLINK_SERVICE');
      // Здесь можно добавить обработку OAuth callback если нужно
      return;
    }

    developer.log('Unknown deep link format: $uri', name: 'DEEPLINK_SERVICE');
  }

  /// Навигация к событию
  void _navigateToEvent(String eventId) {
    developer.log('Navigating to event: $eventId', name: 'DEEPLINK_SERVICE');

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => EventDetailScreen(eventId: eventId),
        ),
      );
    } else {
      developer.log('Navigator not available', name: 'DEEPLINK_SERVICE');
    }
  }

  void _navigateToMain(Uri uri) async {
    developer.log('Navigating to main', name: 'DEEPLINK_SERVICE');
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
    });

    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    } else {
      developer.log('Navigator not available', name: 'DEEPLINK_SERVICE');
    }
  }

  /// Генерация ссылки на событие
  String generateEventLink(String eventId) {
    // Возвращаем universal link для лучшей совместимости
    return 'https://api.actiadmin.ru/event/$eventId';
  }

  /// Генерация deep link на событие
  String generateDeepLink(String eventId) {
    // Возвращаем кастомную схему для прямого открытия приложения
    return 'acti://api.actiadmin.ru/event/$eventId';
  }

  /// Очистка ресурсов
  void dispose() {
    _sub?.cancel();
    _isInitialized = false;
    developer.log('Deep link service disposed', name: 'DEEPLINK_SERVICE');
  }
}
