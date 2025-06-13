import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_main/chat_main_screen.dart';
import 'package:acti_mobile/presentation/screens/events/screens/events_screen.dart';
import 'package:acti_mobile/presentation/screens/events/screens/votes_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/get/my_events_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/profile_menu_screen.dart';
import 'package:acti_mobile/presentation/widgets/activity_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/my_events_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:provider/provider.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen_provider.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 1});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final bool _showSettings = false;
  bool _isVerified = false;
  bool _isProfileCompleted = false;

  final List<Widget> _screens = [
    MapScreen(),
    const EventsScreen(),
    const ChatMainScreen(),
    ProfileMenuScreen(onSettingsChanged: null),
    const MyEventsScreen(),
    const VotesScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Устанавливаем начальный индекс
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MainScreenProvider>(context, listen: false)
          .setIndex(widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileGotListEventsState) {
          setState(() {
            _isVerified = state.isVerified;
            _isProfileCompleted = state.isProfileCompleted;
          });
        }
      },
      child: Consumer<MainScreenProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            body: Stack(
              children: [
                IndexedStack(
                  index: provider.currentIndex,
                  children: _screens,
                ),
                if (provider.currentIndex == 1)
                  Positioned(
                    left: 30,
                    right: 30,
                    bottom: 120,
                    child: ActivityBarWidget(
                      isVerified: _isVerified,
                      isProfileCompleted: _isProfileCompleted,
                    ),
                  ),
                if (provider.currentIndex == 3)
                  Positioned(
                    left: 30,
                    right: 30,
                    bottom: 120,
                    child: MyEventsWidget(
                      onTap: () {
                        provider.setIndex(4);
                      },
                    ),
                  ),
                Positioned(
                  left: 30,
                  right: 30,
                  bottom: 30,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: mainBlueColor.withAlpha(180),
                          blurRadius: 100,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: CustomNavBarWidget(
                      selectedIndex: provider.currentIndex == 5
                          ? 1
                          : provider.currentIndex,
                      onTabSelected: (index) {
                        if (index == 1) {
                          provider.setIndex(1);
                        } else if (index == 5) {
                          provider.setIndex(5);
                        } else {
                          provider.setIndex(index);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
