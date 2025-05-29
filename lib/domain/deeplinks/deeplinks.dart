import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final GlobalKey<NavigatorState> navigatorKey;
StreamSubscription<Uri>? _linkSubscription;

  DeepLinkService(this.navigatorKey);

   Future<void> initDeepLinks() async {
    // Handle links
   AppLinks().uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      _handleLink(uri);
    });
  }


  void _handleLink(Uri uri) {
    if (uri.scheme == 'acti' && uri.host == 'events') {
      final eventId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (eventId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: eventId)),
        );
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
