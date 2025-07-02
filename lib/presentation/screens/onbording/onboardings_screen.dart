import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/presentation/screens/main/main_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_around/events_around_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_create/events_create_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_list/events_list_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_select/events_select_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_start/events_start_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/widgets/pop_nav_button.dart';
import 'package:acti_mobile/presentation/screens/profile/update_profile/update_profile_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class OnboardingsScreen extends StatefulWidget {
  const OnboardingsScreen({super.key});

  @override
  State<OnboardingsScreen> createState() => _OnboardingsScreenState();
}

class _OnboardingsScreenState extends State<OnboardingsScreen> {
  late List<Widget> _pages;
  int _currentPage = 0;
  bool isLoading = false;
  bool isFinishing = false;
  List<EventOnboarding> selectedCategories = [];
  ListOnbordingModel? listOnbordingModel;
  late ProfileModel profileModel;

  @override
  void initState() {
    super.initState();
    _initializePages();
    _loadCategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage("assets/images/image_start_events.png"),
        context,
      );
    });
  }

  void _initializePages() {
    _pages = [
      EventsAroundScreen(),
      EventsListScreen(),
      EventsCreateScreen(),
      EventsSelectScreen(
        fromUpdate: false,
        onCategoriesSelected: (categories) {
          setState(() {
            selectedCategories = categories;
          });
        },
        categories: listOnbordingModel?.categories ?? [],
        selectedCategories: selectedCategories,
      ),
      EventsStartScreen(),
    ];
  }

  void _loadCategories() {
    setState(() {
      isLoading = true;
    });
    context.read<AuthBloc>().add(ActiGetOnbordingEvent());
  }

  void _onPageChanged(int page) {
    if (!mounted) return;
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage == 3) {
      // Страница выбора категорий
      if (selectedCategories.isEmpty) {
        showTopSnackBar(
          Overlay.of(context),
          CustomSnackBar.info(
            message:
                "Для продолжения необходимо выбрать хотя бы одну категорию",
            backgroundColor: Color.fromARGB(255, 66, 147, 239),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          displayDuration: const Duration(seconds: 3),
        );
        return;
      }
      setState(() {
        isLoading = true;
      });
      context
          .read<AuthBloc>()
          .add(ActiSaveOnbordingEvent(listOnboarding: selectedCategories));
    } else if (_currentPage == _pages.length - 1) {
      // На последнем слайде — переход на MainScreen
      setState(() {
        isFinishing = true;
      });
      ProfileApi().getProfile().then((profile) {
        if (profile != null) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => MainScreen(
                initialIndex: 3,
                showUpdateProfileOnStart: true,
                profileModel: profile,
              ),
            ),
            (route) => false,
          );
        }
      });
    } else if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (!mounted) return;
        if (state is ActiSavedOnbordingState) {
          setState(() {
            isLoading = false;
            isFinishing = false;
            _currentPage = _pages.length - 1;
          });
        }
        if (state is ActiSavedOnbordingErrorState) {
          setState(() {
            isLoading = false;
          });
        }
        if (state is ActiGotOnbordingState) {
          setState(() {
            isLoading = false;
            listOnbordingModel = state.listOnbordingModel;
            _pages[3] = EventsSelectScreen(
              fromUpdate: false,
              onCategoriesSelected: (categories) {
                setState(() {
                  selectedCategories = categories;
                });
              },
              categories: listOnbordingModel!.categories,
              selectedCategories: selectedCategories,
            );
          });
        }
        if (state is ActiGotOnbordingErrorState) {
          setState(() {
            isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isLoading || isFinishing
            ? LoaderWidget()
            : Stack(
                children: [
                  IndexedStack(
                    index: _currentPage,
                    children: _pages,
                  ),
                  Positioned(
                    left: 35,
                    right: 35,
                    bottom: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (_currentPage > 0)
                          PopNavButton(
                            text: 'Назад',
                            function: _previousPage,
                          )
                        else
                          SizedBox(width: 47),
                        PopNavButton(
                          text: _currentPage == _pages.length - 1
                              ? 'Далее'
                              : 'Далее',
                          function: _nextPage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
