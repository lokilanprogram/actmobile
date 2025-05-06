// import 'package:acti_mobile/domain/screens/maps/map/map_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// final GlobalKey<NavigatorState> rootNavigatorKey =
//     GlobalKey<NavigatorState>(debugLabel: 'root');
// final GlobalKey<NavigatorState> sectionANavigatorKey =
//     GlobalKey<NavigatorState>(debugLabel: 'sectionANav');

// GoRouter? globalGoRouter;

// GoRouter getGoRouter() {
//   return globalGoRouter ??= getRoutes();
// }

// void clearAndNavigate(String path, Object? object) {
//   while (getGoRouter().canPop() == true) {
//     getGoRouter().pop();
//   }
//   getGoRouter().pushReplacement(path, extra: object);
// }

// GoRouter getRoutes() {
//   return GoRouter(
//       navigatorKey: rootNavigatorKey,
//       initialLocation: '/initial',
//       routes: [
//         GoRoute(path: '/initial', builder: (context, state) => MapScreen()),
//         StatefulShellRoute.indexedStack(
//             builder: (BuildContext context, GoRouterState state,
//                 StatefulNavigationShell navigationShell) {
//               // Return the widget that implements the custom shell (in this case
//               // using a BottomNavigationBar). The StatefulNavigationShell is passed
//               // to be able access the state of the shell and to navigate to other
//               // branches in a stateful way.
//               return ScaffoldWithNavBarWidget(navigationShell: navigationShell);
//             },
//             // #enddocregion configuration-builder
//             // #docregion configuration-branches
//             branches: <StatefulShellBranch>[
//               // The route branch for the first tab of the bottom navigation bar.
//               StatefulShellBranch(
//                   navigatorKey: sectionANavigatorKey,
//                   routes: <RouteBase>[
//                     GoRoute(
//                         path: '/adverts_home_list',
//                         routes: [
                          
//                         ],
//                         builder: (context, state) =>
//                             const AdvertsHomeListScreen()),
//                   ]),
//               StatefulShellBranch(routes: <RouteBase>[
//                 GoRoute(
//                     path: '/favorites',
//                     builder: (context, state) {
//                       final isMain = state.extra as bool?;
//                       return FavoritesAdvertScreen(
//                         isMain: isMain,
//                       );
//                     }),
//               ]),]
//               StatefulShellBranch(routes: <RouteBase>[
//                 GoRoute(
//                     path: '/profile_chats',
//                     routes: [
//                       GoRoute(
//                           path: '/profile_chat',
//                           builder: (context, state) {
//                             final chatDataModel = state.extra as ChatDataModel;
//                             return ProfileChatScreen(
//                                 chatDataModel: chatDataModel);
//                           }),
//                     ],
//                     builder: (context, state) {
//                       final isMain = state.extra as bool?;
//                       return ProfileChatsScreen(
//                         isMain: isMain,
//                       );
//                     }),
//               ]),
//               StatefulShellBranch(routes: <RouteBase>[
//                 GoRoute(
//                     path: '/profile',
//                     routes: [
//                       GoRoute(
//                           path: '/notifications',
//                           builder: (context, state) {
//                             return const NotificationsScreen();
//                           }),
//                       GoRoute(
//                           path: '/my_review',
//                           builder: (context, state) {
//                             return const MyReviewScreen();
//                           }),
//                       GoRoute(
//                           path: '/support',
//                           builder: (context, state) {
//                             return const SupportScreen();
//                           }),
//                       GoRoute(
//                           path: '/profile_listing_advert',
//                           builder: (context, state) {
//                             final advert = state.extra as AdvertProfileModel;
//                             return AdvertProfilePage(
//                                 advertProfileModel: advert);
//                           }),
//                       GoRoute(
//                           path: '/editing_profile',
//                           builder: (context, state) {
//                             final profile =
//                                 state.extra as ProfileDataFetchedModel;
//                             return EditingProfileScreen(
//                               profileDataFetchedModel: profile,
//                             );
//                           }),
//                       GoRoute(
//                           path: '/editing_advert',
//                           builder: (context, state) {
//                             final advertFetchedModel =
//                                 state.extra as AdvertDataFetchedModel;
//                             return EditingAdvertScreen(
//                               advertFetchedModel: advertFetchedModel,
//                             );
//                           }),
//                       GoRoute(
//                           path: '/adverts_profile_list',
//                           builder: (context, state) {
//                             return const AdvertsProfileListScreen();
//                           }),
//                     ],
//                     builder: (context, state) {
//                       return const ProfileWrapperScreen();
//                     }),
//               ]),
//             ]),
//       ]);
// }
