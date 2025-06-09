import 'dart:ui';

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/public_user_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_main/chat_main_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/widgets/blurred.dart';
import 'package:acti_mobile/presentation/widgets/popup_event_buttons.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/widget/my_events_card.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/gradient_text.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/send_message_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PublicUserScreen extends StatefulWidget {
  final String userId;
  const PublicUserScreen({super.key, required this.userId});

  @override
  State<PublicUserScreen> createState() => _PublicUserScreenState();
}

class _PublicUserScreenState extends State<PublicUserScreen> {
  bool isLoading = false;
  bool isBlocked = false;
  late PublicUserModel publicUserModel;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() async {
    setState(() {
      isLoading = true;
    });
    context
        .read<ProfileBloc>()
        .add(ProfileGetPublicUserEvent(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileBlockedUserState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Заблокировали')));
        }
        if (state is ProfileGotPublicUserState) {
          setState(() {
            isLoading = false;
            publicUserModel = state.publicUserModel;
            isBlocked = state.publicUserModel.isBlockedByUser ?? false;
          });
        }
        if (state is ProfileUpdatedState) {
          initialize();
        }

        if (state is ProfileBlockedUserErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
        if (state is ProfileGotPublicUserErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        body: isLoading
            ? LoaderWidget()
            : Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              publicUserModel.photoUrl != null
                                  ? Image.network(publicUserModel.photoUrl!,
                                      width: double.infinity,
                                      height: 350,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: 350,
                                        child: Center(
                                          child: CircularProgressIndicator(
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
                                left: 10,
                                child: IconButton(
                                  icon: SvgPicture.asset(
                                      'assets/icons/icon_back_white.svg'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              // Positioned(
                              //   top: 77,
                              //   right: 60,
                              //   child: Icon(Icons.notifications_none_outlined,
                              //       color: Colors.white),
                              // ),
                              Positioned(
                                top: 48,
                                right: 10,
                                child: PopUpPublicUserButtons(
                                  userId: widget.userId,
                                  blockFunction: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    context.read<ProfileBloc>().add(
                                        ProfileBlockUserEvent(
                                            userId: widget.userId));
                                  },
                                  userName:
                                      publicUserModel.name ?? 'Неизвестный',
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: ClipRRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 20, sigmaY: 20),
                                    child: Container(
                                      height: 120,
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 20, top: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(
                                            0.3), // Тёмный полупрозрачный фон
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            publicUserModel.surname != null &&
                                                    publicUserModel.surname != ""
                                                ? '${capitalize(publicUserModel.surname!)} ${capitalize(publicUserModel.name!)}'
                                                : capitalize(
                                                    publicUserModel.name!),
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            capitalize(publicUserModel.status ??
                                                'Offline'),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20)),
                                        color: Colors.white),
                                  )),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                const SizedBox(height: 10),
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
                                  publicUserModel.bio?.isNotEmpty == true
                                      ? publicUserModel.bio!
                                      : '...',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Интересы
                                buildInterestsGrid(
                                  publicUserModel.categories
                                      .map((e) => e.name)
                                      .toList(),
                                ),

                                const SizedBox(height: 25),

                                // Заголовок и рейтинг
                                Row(
                                  children: [
                                    Text(
                                      'События ${publicUserModel.name}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Gilroy',
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    SvgPicture.asset(
                                        'assets/icons/icon_star.svg'),
                                    const SizedBox(width: 3),
                                    GradientText(
                                      '4.1',
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromRGBO(23, 132, 255, 1),
                                          Color.fromRGBO(42, 244, 72, 1),
                                        ],
                                      ),
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                // Карточки событий
                                Column(
                                  children:
                                      publicUserModel.organizedEvents != null
                                          ? publicUserModel.organizedEvents!
                                              .map((event) => MyCardEventWidget(
                                                    isCompletedEvent: false,
                                                    organizedEvent: event,
                                                    isPublicUser: true,
                                                  ))
                                              .toList()
                                          : [],
                                ),
                                //SizedBox(height:publicUserModel.organizedEvents?.length == 1? 200:0),
                                SizedBox(height: 200),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 60),
                      child: Container(
                        decoration: BoxDecoration(color: Colors.transparent),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SendMessageBarWidget(function: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatDetailScreen(
                                            isPrivateChats: true,
                                            trailingText: null,
                                            interlocutorAvatar:
                                                publicUserModel.photoUrl,
                                            interlocutorName:
                                                publicUserModel.name ??
                                                    'Неизвестный',
                                            interlocutorChatId:
                                                publicUserModel.chatId,
                                            interlocutorUserId: widget.userId,
                                          )));
                            }),
                            SizedBox(
                              height: 15,
                            ),
                            CustomNavBarWidget(
                                selectedIndex: 4,
                                onTabSelected: (index) {
                                  if (index == 0) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MapScreen(
                                                  selectedScreenIndex: 0,
                                                )));
                                  }
                                  if (index == 2) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MapScreen(
                                                  selectedScreenIndex: 2,
                                                )));
                                  }
                                  if (index == 3) {
                                    Navigator.pop(context);
                                  }
                                }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class BlockedInfoWidget extends StatelessWidget {
  const BlockedInfoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Material(
        elevation: 1.2,
        borderRadius: BorderRadius.circular(25),
        child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Color.fromRGBO(235, 235, 235, 1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Text(
                'Данный пользователь вас заблокировал, вы не можете ему написать.',
                style: TextStyle(
                    color: Color.fromRGBO(161, 161, 161, 1),
                    fontFamily: 'Gilroy',
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )),
      ),
    );
  }
}
