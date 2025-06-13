import 'dart:io';
import 'dart:ui';
import 'dart:developer' as developer;

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/notifications/notifications_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/notifications/notifications_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/settings_screen.dart';
import 'package:acti_mobile/presentation/widgets/blurred.dart';
import 'package:acti_mobile/presentation/widgets/popup_profile_buttons.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../update_profile/update_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class ProfileMenuScreen extends StatefulWidget {
  final Function(bool)? onSettingsChanged;
  const ProfileMenuScreen({super.key, this.onSettingsChanged});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class SettingsPageProvider extends ChangeNotifier {
  int currentPage = 0; // 0 - main, 1 - соглашение, 2 - политика и т.д.
  bool notificationsEnabled = false;
  int? openedFaqIndex;

  void setPage(int page) {
    currentPage = page;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void setOpenedFaqIndex(int? idx) {
    openedFaqIndex = idx;
    notifyListeners();
  }
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  bool isLoading = false;
  late ProfileModel profileModel;
  late List<SimiliarUsersModel> similiarUsersModel;
  bool showSettings = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetEvent());
  }

  void _openSettingsPage() {
    setState(() {
      showSettings = true;
    });
    widget.onSettingsChanged?.call(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileLogoutState || state is ProfileDeleteState) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InitialScreen()));
        }
        if (state is ProfileGotState) {
          setState(() {
            profileModel = state.profileModel;
            similiarUsersModel = state.similiarUsersModel;
          });

          setState(() {
            isLoading = false;
          });
        }
        if (state is ProfileLogoutErrorState ||
            state is ProfileDeleteErrorState) {
          setState(() {
            isLoading = false;
          });

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
        if (state is ProfileGotErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: isLoading
          ? LoaderWidget()
          : Scaffold(
              backgroundColor: Colors.white,
              body: showSettings
                  ? SettingsScreen(
                      notificationsEnabled: profileModel.notificationsEnabled,
                      onBack: () {
                        setState(() {
                          showSettings = false;
                        });
                        widget.onSettingsChanged?.call(false);
                      },
                    )
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    profileModel.photoUrl != null
                                        ? Image.network(profileModel.photoUrl!,
                                            width: double.infinity,
                                            height: 350,
                                            fit: BoxFit.cover, loadingBuilder:
                                                (BuildContext context,
                                                    Widget child,
                                                    ImageChunkEvent?
                                                        loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return SizedBox(
                                              height: 350,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: mainBlueColor,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          })
                                        : Image.asset(
                                            'assets/images/image_profile.png',
                                            width: double.infinity,
                                            height: 350,
                                            fit: BoxFit.cover,
                                          ),
                                    Positioned(
                                        top: 48,
                                        right: 10,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: InkWell(
                                                onTap: () async {
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              NotificationsScreen()));
                                                },
                                                child: Icon(
                                                    Icons
                                                        .notifications_none_outlined,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            PopUpProfileButtons(
                                              deleteFunction: () {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                context
                                                    .read<ProfileBloc>()
                                                    .add(ProfileLogoutEvent());
                                              },
                                              editFunction: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            UpdateProfileScreen(
                                                              profileModel:
                                                                  profileModel,
                                                            )));
                                              },
                                              settingsFunction:
                                                  _openSettingsPage,
                                            ),
                                          ],
                                        )),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: ClipRRect(
                                        child: Container(
                                          height: 120,
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                profileModel.surname != null &&
                                                        profileModel.surname !=
                                                            ""
                                                    ? '${capitalize(profileModel.surname!)} ${capitalize(profileModel.name!)}'
                                                    : capitalize(
                                                        profileModel.name ??
                                                            'Неизвестное имя'),
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                capitalize(profileModel.status),
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 20,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  topRight:
                                                      Radius.circular(20)),
                                              color: Colors.white),
                                        )),
                                  ],
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 5),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Профиль',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.bold,
                                          color: mainBlueColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'О себе',
                                        style: TextStyle(
                                          fontSize: 16.67,
                                          fontFamily: 'Gilroy',
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        profileModel.bio == '' ||
                                                profileModel.bio == null
                                            ? '...'
                                            : profileModel.bio!,
                                        style: TextStyle(
                                            fontFamily: 'Inter', fontSize: 12),
                                      ),
                                      const SizedBox(height: 15),
                                      buildInterestsGrid(
                                        profileModel.categories
                                            .map((e) => e.name)
                                            .toList(),
                                      ),
                                      const SizedBox(height: 25),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 0),
                                        child: const Text(
                                          'Похожие пользователи',
                                          style: TextStyle(
                                            fontSize: 16.67,
                                            fontFamily: 'Gilroy',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Center(
                                          child: similiarUsersModel.isEmpty
                                              ? buildNoUsers()
                                              : SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.9,
                                                  child: Card(
                                                    elevation: 1.2,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25)),
                                                    color: Colors.white,
                                                    child: buildSimiliarUsers(
                                                        context),
                                                  ),
                                                )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Padding buildSimiliarUsers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: similiarUsersModel
            .take(4)
            .map((user) => GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PublicUserScreen(userId: user.id)));
                },
                child: buildAvatar(user.photoUrl, user.name ?? 'Неизвестный')))
            .toList(),
      ),
    );
  }

  Widget buildNoUsers() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 1.2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Text(
            'Здесь скоро появится список людей со схожими интересами',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Gilroy',
                fontSize: 15,
                color: mainBlueColor,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  // Avatar widget
  Widget buildAvatar(String? path, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: path == null
                ? AssetImage('assets/images/image_profile.png')
                : NetworkImage(path),
            radius: 32,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            name,
            style: TextStyle(
                fontFamily: 'Gilroy', fontSize: 9, fontWeight: FontWeight.w400),
          )
        ],
      ),
    );
  }
}
