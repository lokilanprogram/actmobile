
// import 'package:acti_mobile/domain/repositories/auth_repository.dart';
// import 'package:acti_mobile/presentation/screens/auth/screens/verify_email_screen.dart';
// import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
// import 'package:acti_mobile/presentation/screens/maps/public_user/event/event_detail_screen.dart';
// import 'package:flutter/material.dart';

// import 'app_route_path.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';


// class AppRouterDelegate extends RouterDelegate<AppRoutePath>
//     with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoutePath> {
//   final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
//   final AppRoutePath _currentPath = AppRoutePath.splash();

//   // Кэширование виджетов для сохранения состояния
//   MainScreen? _cachedHomeScreen;

//   // Кэшируем часто используемые объекты
//   Dio? _cachedDio;
//   // EventService? _cachedEventService;
//   // UserService? _cachedUserService;

//   // Получаем кэшированный Dio
//   Dio _getDio() {
//     _cachedDio ??= Dio();
//     return _cachedDio!;
//   }

//   // Предварительно создаем и кэшируем сервисы
//   EventService _getEventService() {
//     if (_cachedEventService == null) {
//       final dio = _getDio();
//       const secureStorage = FlutterSecureStorage();
//       final authRepository =
//           RepositoryProvider.of<AuthRepository>(_navigatorKey.currentContext!);
//       _cachedEventService = EventService(dio, secureStorage, authRepository);
//     }
//     return _cachedEventService!;
//   }

//   // UserService _getUserService() {
//   //   if (_cachedUserService == null) {
//   //     final dio = _getDio();
//   //     const secureStorage = FlutterSecureStorage();
//   //     final authRepository =
//   //         RepositoryProvider.of<AuthRepository>(_navigatorKey.currentContext!);
//   //     _cachedUserService = UserService(dio, secureStorage, authRepository);
//   //   }
//   //   return _cachedUserService!;
//   // }

//   @override
//   GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

//   @override
//   Widget build(BuildContext context) {
//     return Navigator(
//       key: navigatorKey,
//       pages: [
//         // if (_currentPath.isSplash)
//         //   MaterialPage(
//         //     key: const ValueKey('SplashScreen'),
//         //     child: SplashScreen(routerDelegate: this),
//         //   )
//        if (_currentPath.isUnknown)
//           const MaterialPage(
//             key: ValueKey('UnknownScreen'),
//             child: Scaffold(
//               body: Center(
//                 child: Text('404 - Страница не найдена'),
//               ),
//             ),
//           )
//         // else if (_currentPath.isOnboarding)
//         //   MaterialPage(
//         //     key: const ValueKey('OnboardingScreen'),
//         //     child: OnboardingScreen(routerDelegate: this),
//         //   )
//         // else if (_currentPath.isAuth)
//         //   MaterialPage(
//         //     key: const ValueKey('AuthScreen'),
//         //     child: AuthScreen(
//         //       tabIndex: _currentPath.tabIndex,
//         //       routerDelegate: this,
//         //     ),
//         //   )


//         // else if (_currentPath.isResetPassword)
//         //   MaterialPage(
//         //     key: const ValueKey('ResetPasswordScreen'),
//         //     child: ResetPasswordScreen(
//         //       token: _currentPath.token,
//         //       routerDelegate: this,
//         //     ),
//         //   )



//         else if (_currentPath.isVerifyEmail && _currentPath.token != null)
//           MaterialPage(
//             key: const ValueKey('VerifyEmailScreen'),
//             child: VerifyEmailScreen(
//               token: _currentPath.token!,
//               email: _currentPath.email!,
//               routerDelegate: this,
//             ),
//           )
//         // else if (_currentPath.isCreateEvent)
//         //   MaterialPage(
//         //     key: const ValueKey('CreateEventScreen'),
//         //     child: _buildCreateEventScreen(),
//         //   )
//         // else if (_currentPath.isEditProfile)
//         //   MaterialPage(
//         //     key: const ValueKey('EditProfileScreen'),
//         //     child: BlocProvider.value(
//         //       value: context.read<UserProfileBloc>(),
//         //       child: RepositoryProvider.value(
//         //         value: context.read<UserRepository>(),
//         //         child: EditProfileScreen(
//         //           profile: context.read<UserProfileBloc>().state.profile,
//         //           routerDelegate: this,
//         //         ),
//         //       ),
//         //     ),
//         //   )
//         // else if (_currentPath.isUserProfile)
//         //   MaterialPage(
//         //     key: const ValueKey('UserProfileScreen'),
//         //     child: _buildProfileScreen(context),
//         //   )
//         else if (_currentPath.isEventDetail && _currentPath.eventData != null)
//           MaterialPage(
//             key: const ValueKey('EventDetailScreen'),
//             child: EventDetailScreen(
//               eventId: _currentPath.eventData,
//               routerDelegate: this,
//             ),
//           )
//         else if (_currentPath.isEventDetail && _currentPath.eventId != null)
//           MaterialPage(
//             key: ValueKey('EventDetailScreen-${_currentPath.eventId}'),
//             child: FutureBuilder<EventModel>(
//               future: _getEventService().getEventDetails(_currentPath.eventId!),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Scaffold(
//                     body: Center(child: CircularProgressIndicator()),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   return Scaffold(
//                     body: Center(
//                       child: Text('Ошибка загрузки события: ${snapshot.error}'),
//                     ),
//                   );
//                 }
//                 final event = snapshot.data!;
//                 final nearbyEvent = NearbyEventModel(
//                   id: event.id,
//                   title: event.title,
//                   description: event.description,
//                   type: event.type,
//                   lat: event.lat,
//                   lon: event.lon,
//                   date: event.dateStart,
//                   distance: 0,
//                   categoryId: event.categoryId,
//                   isFree: event.isFree,
//                   photo: event.photo,
//                 );
//                 return EventDetailScreen(
//                   event: nearbyEvent,
//                   routerDelegate: this,
//                 );
//               },
//             ),
//           )
//       //   else if (_currentPath.isOrganizerProfile &&
//       //       _currentPath.organizerId != null)
//       //     MaterialPage(
//       //       key: ValueKey('OrganizerScreen-${_currentPath.organizerId}'),
//       //       child: _buildOrganizerScreen(context),
//       //     )
//       //   else if (_currentPath.isMyEvents)
//       //     MaterialPage(
//       //       key: const ValueKey('MyEventsScreen'),
//       //       child: MyEventsScreen(routerDelegate: this),
//       //     )
//       //   else
//       //     MaterialPage(
//       //       key: const ValueKey('HomeScreen'),
//       //       child: _getHomeScreen(context),
//       //     ),
//       // ],
//       // onPopPage: (route, result) {
//       //   if (!route.didPop(result)) {
//       //     return false;
//       //   }

//         // После закрытия страницы, возвращаемся к предыдущему состоянию
//         if (_currentPath.isCreateEvent ||
//             _currentPath.isUserProfile ||
//             _currentPath.isEditProfile ||
//             _currentPath.isEventDetail) {
//           setNewRoutePath(AppRoutePath.home());
//         } else if (_currentPath.isAuth ||
//             _currentPath.isOnboarding ||
//             _currentPath.isResetPassword ||
//             _currentPath.isVerifyEmail) {
//           setNewRoutePath(AppRoutePath.home());
//         }
//         return true;
//       },
//     );
//   }

//   @override
//   Future<void> setNewRoutePath(AppRoutePath path) async {
//     // Оптимизация: не уведомляем, если путь не изменился
//     if (_pathsAreEqual(_currentPath, path)) {
//       return;
//     }

//     _currentPath = path;
//     notifyListeners();
//   }

//   // Проверка равенства путей для избежания лишних обновлений
//   bool _pathsAreEqual(AppRoutePath path1, AppRoutePath path2) {
//     // Сравниваем основные флаги путей
//     if (path1.isHome != path2.isHome ||
//         path1.isAuth != path2.isAuth ||
//         path1.isUserProfile != path2.isUserProfile ||
//         path1.isCreateEvent != path2.isCreateEvent ||
//         path1.isEventDetail != path2.isEventDetail ||
//         path1.isEditProfile != path2.isEditProfile) {
//       return false;
//     }

//     // Дополнительно проверяем данные события, если оба пути - детали события
//     if (path1.isEventDetail && path2.isEventDetail) {
//       if (path1.eventData is NearbyEventModel &&
//           path2.eventData is NearbyEventModel) {
//         final event1 = path1.eventData as NearbyEventModel;
//         final event2 = path2.eventData as NearbyEventModel;
//         return event1.id == event2.id;
//       }
//     }

//     return true;
//   }

//   // Метод для получения кэшированного HomeScreen, или создания нового, если нет
//   Widget _getHomeScreen(BuildContext context) {
//     return MainScreen(
//       initialIndex: _currentPath.tabIndex,
//       routerDelegate: this,
//     );
//   }

//   // Метод для создания экрана создания события с необходимыми зависимостями (оптимизирован)
//   // Widget _buildCreateEventScreen() {
//   //   final eventService = _getEventService();
//   //   final eventRepository = EventRepository(eventService);

//   //   return BlocProvider(
//   //     create: (context) => CreateEventBloc(eventRepository),
//   //     child: CreateEventScreen(
//   //       routerDelegate: this,
//   //       eventData: const {},
//   //       onDataUpdate: (data) {},
//   //     ),
//   //   );
//   // }

//   // Метод для создания экрана профиля с необходимыми зависимостями (оптимизирован)
//   // Widget _buildProfileScreen(BuildContext context) {
//   //   final userService = _getUserService();
//   //   final dio = _getDio();
//   //   final userRepository = UserRepository(userService, dio);
//   //   final authBloc = context.read<AuthBloc>();
//   //   final userProfileBloc = UserProfileBloc(userRepository, authBloc);

//   //   return BlocProvider(
//   //     create: (context) => userProfileBloc,
//   //     child: ProfileScreen(
//   //       routerDelegate: this,
//   //       tokenInterceptor: context.read<TokenInterceptor>(),
//   //     ),
//   //   );
//   // }

//   // Widget _buildOrganizerScreen(BuildContext context) {
//   //   final userService = _getUserService();
//   //   final dio = _getDio();
//   //   final userRepository = UserRepository(userService, dio);

//   //   return BlocProvider(
//   //     create: (context) => OrganizerProfileBloc(userRepository),
//   //     child: OrganizerScreen(
//   //       userId: _currentPath.organizerId!,
//   //       routerDelegate: this,
//   //     ),
//   //   );
//   // }

//   // Метод для принудительной перезагрузки HomeScreen
//   void clearHomeScreenCache() {
//     _cachedHomeScreen = null;
//     notifyListeners();
//   }

//   Widget _buildRoute(AppRoutePath path) {
//     if (path.isSplashPage) {
//       return SplashScreen(routerDelegate: this);
//     } else if (path.isAuthPage) {
//       return AuthScreen(routerDelegate: this);
//     } else if (path.isVerifyEmailPage) {
//       return VerifyEmailScreen(
//         token: path.token ?? '',
//         email: path.email ?? '',
//         routerDelegate: this,
//       );
//     } else if (path.isResetPasswordPage) {
//       return ResetPasswordScreen(
//         token: path.token ?? '',
//         routerDelegate: this,
//       );
//     } else if (path.isEventDetail && path.eventId != null) {
//       final eventService = EventService(
//         Dio(),
//         const FlutterSecureStorage(),
//         RepositoryProvider.of<AuthRepository>(_navigatorKey.currentContext!),
//       );
//       return FutureBuilder<EventModel>(
//         future: eventService.getEventDetails(path.eventId!),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           if (snapshot.hasError) {
//             return Scaffold(
//               body: Center(
//                 child: Text('Ошибка загрузки события: ${snapshot.error}'),
//               ),
//             );
//           }
//           final event = snapshot.data!;
//           final nearbyEvent = NearbyEventModel(
//             id: event.id,
//             title: event.title,
//             description: event.description,
//             type: event.type,
//             lat: event.lat,
//             lon: event.lon,
//             date: event.dateStart,
//             distance: 0,
//             categoryId: event.categoryId,
//             isFree: event.isFree,
//             photo: event.photo,
//           );
//           return EventDetailScreen(
//             event: nearbyEvent,
//             routerDelegate: this,
//           );
//         },
//       );
//     } else {
//       return MainScreen(
//         initialIndex: path.tabIndex,
//         routerDelegate: this,
//       );
//     }
//   }
// }
