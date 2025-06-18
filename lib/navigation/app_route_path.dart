import 'package:flutter/foundation.dart';

class AppRoutePath {
  final bool isUnknown;
  final bool isAuth;
  final bool isResetPassword;
  final bool isVerifyEmail;
  final bool isSplash;
  final bool isOnboarding;
  final bool isHome;
  final int tabIndex;
  final String? token;
  final String? email;
  final bool isCreateEvent;
  final bool isUserProfile;
  final bool isEditProfile;
  final bool isEventDetail;
  final bool isOrganizerProfile;
  final String? organizerId;
  final dynamic eventData;
  final bool isMyEvents;
  final String? location;
  final String? eventId;

  AppRoutePath({
    this.isUnknown = false,
    this.isAuth = false,
    this.isResetPassword = false,
    this.isVerifyEmail = false,
    this.isSplash = false,
    this.isOnboarding = false,
    this.isHome = false,
    this.tabIndex = 0,
    this.token,
    this.email,
    this.isCreateEvent = false,
    this.isUserProfile = false,
    this.isEditProfile = false,
    this.isEventDetail = false,
    this.isOrganizerProfile = false,
    this.organizerId,
    this.eventData,
    this.isMyEvents = false,
    this.location,
    this.eventId,
  });

  factory AppRoutePath.unknown() => AppRoutePath(isUnknown: true);
  factory AppRoutePath.splash() => AppRoutePath(isSplash: true);
  factory AppRoutePath.onboarding() => AppRoutePath(isOnboarding: true);
  factory AppRoutePath.auth([int tabIndex = 0]) =>
      AppRoutePath(isAuth: true, tabIndex: tabIndex);
  factory AppRoutePath.resetPassword({String? token}) {
    debugPrint('Creating ResetPassword route with token: $token');
    return AppRoutePath(isResetPassword: true, token: token);
  }
  factory AppRoutePath.verifyEmail(String token, String email) =>
      AppRoutePath(isVerifyEmail: true, token: token, email: email);
  factory AppRoutePath.home([int tabIndex = 0]) =>
      AppRoutePath(isHome: true, tabIndex: tabIndex);
  factory AppRoutePath.createEvent() => AppRoutePath(isCreateEvent: true);
  factory AppRoutePath.userProfile() => AppRoutePath(isUserProfile: true);
  factory AppRoutePath.editProfile() => AppRoutePath(isEditProfile: true);
  factory AppRoutePath.eventDetail(dynamic event) =>
      AppRoutePath(isEventDetail: true, eventData: event);
  factory AppRoutePath.organizerProfile(String organizerId) =>
      AppRoutePath(isOrganizerProfile: true, organizerId: organizerId);
  factory AppRoutePath.myEvents() => AppRoutePath(isMyEvents: true);
  factory AppRoutePath.eventDetails(String eventId) {
    return AppRoutePath(
      isEventDetail: true,
      eventId: eventId,
    );
  }

  bool get isInitial => isSplash;
  bool get isHomePage => location == '/';
  bool get isAuthPage => location == '/auth';
  bool get isSplashPage => location == '/splash';
  bool get isVerifyEmailPage => location == '/verify-email';
  bool get isResetPasswordPage => location == '/reset-password';
  bool get isEventDetailsPage => location?.startsWith('/events/') ?? false;
}
