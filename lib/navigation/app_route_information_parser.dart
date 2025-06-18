import 'package:flutter/material.dart';
import 'app_route_path.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRoutePath> {
  @override
  Future<AppRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '');

    if (uri.pathSegments.isEmpty) {
      return AppRoutePath.splash();
    }

    switch ('/${uri.pathSegments.first}') {
      case '/splash':
        return AppRoutePath.splash();
      case '/onboarding':
        return AppRoutePath.onboarding();
      case '/auth':
        return AppRoutePath.auth();
      // case '/reset-password':
      //   return AppRoutePath.resetPassword(uri.queryParameters['token']);
      default:
        return AppRoutePath.splash();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(AppRoutePath configuration) {
    if (configuration.isSplash) {
      return const RouteInformation(location: '/splash');
    }
    if (configuration.isOnboarding) {
      return const RouteInformation(location: '/onboarding');
    }
    if (configuration.isAuth) {
      return const RouteInformation(location: '/auth');
    }
    if (configuration.isResetPassword) {
      // return RouteInformation(location: '/reset-password?token=${configuration.arguments ?? ''}');
    }
    return const RouteInformation(location: '/splash');
  }
}