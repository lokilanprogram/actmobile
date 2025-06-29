import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/recommendated_user_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/error_widget.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EventRequestScreen extends StatefulWidget {
  final List<Participant> participants;
  final String eventId;
  final bool completedStatus;

  const EventRequestScreen(
      {super.key,
      required this.participants,
      required this.eventId,
      required this.completedStatus});

  @override
  State<EventRequestScreen> createState() => _EventRequestScreenState();
}

class _EventRequestScreenState extends State<EventRequestScreen> {
  late List<Participant> participants;
  RecommendatedUsersModel? recommendatedUsersModel;
  bool isLoading = false;
  bool isError = false;
  String selectedTab = 'mine';
  bool isRequests = true;
  @override
  void initState() {
    setState(() {
      participants = widget.participants;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileInvitedUserState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Пользователь успешно приглашен',
              style: TextStyle(fontFamily: 'Inter', color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ));
        }
        if (state is ProfileRecommentedUsersState) {
          setState(() {
            recommendatedUsersModel = state.recommendatedUsersModel;
            selectedTab = 'notMine';
            isRequests = false;
            isLoading = false;
          });
        }
        if (state is ProfileAcceptedUserOnActivityState) {
          setState(() {
            participants = state.participants;
            selectedTab = 'mine';
            isLoading = false;
          });
        }
        if (state is ProfileInvitedUserErrorState) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }

        if (state is ProfileAcceptedUserOnActivityErrorState) {
          setState(() {
            isLoading = false;
            isError = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: isError ? null : AppBarWidget(title: 'Заявки'),
        body: isError
            ? ErrorWidgetWithRetry(onRetry: () {
                Navigator.pop(context);
              })
            : isLoading
                ? LoaderWidget()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Column(
                      children: [
                        TabBarWidget(
                            firshTabText: 'Заявки',
                            secondTabText: 'Рекомендации',
                            selectedTab: selectedTab,
                            onTapMine: () {
                              setState(() {
                                isRequests = true;
                              });
                            },
                            onTapVisited: () {
                              setState(() {
                                isLoading = true;
                              });
                              context.read<ProfileBloc>().add(
                                  ProfileRecommendUsersEvent(
                                      eventId: widget.eventId));
                            },
                            requestLentgh: participants
                                .where((particapant) =>
                                    particapant.status == 'pending' ||
                                    particapant.status == 'rejected')
                                .length,
                            recommendedLentgh: 0),
                        SizedBox(
                          height: 25,
                        ),
                        isRequests
                            ? isRequests == true && participants.isEmpty
                                ? buildNoUsers()
                                : ListView.separated(
                                    shrinkWrap: true,
                                    primary: true,
                                    itemCount: participants.length,
                                    itemBuilder: (context, index) {
                                      final participant = participants[index];
                                      return ListTile(
                                          trailing: participant.status ==
                                                  'pending'
                                              ? InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    context.read<ProfileBloc>().add(
                                                        ProfileAcceptUserOnActivityEvent(
                                                            eventId:
                                                                widget.eventId,
                                                            status: 'confirmed',
                                                            userId: participant
                                                                .user.id!));
                                                  },
                                                  child: SvgPicture.asset(
                                                      'assets/icons/icon_accept.svg'))
                                              : participant.status ==
                                                      'confirmed'
                                                  ? InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        context
                                                            .read<ProfileBloc>()
                                                            .add(ProfileAcceptUserOnActivityEvent(
                                                                eventId: widget
                                                                    .eventId,
                                                                status:
                                                                    'rejected',
                                                                userId:
                                                                    participant
                                                                        .user
                                                                        .id!));
                                                      },
                                                      child: SvgPicture.asset(
                                                          'assets/icons/icon_accepted.svg'))
                                                  : InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          isLoading = true;
                                                        });
                                                        context
                                                            .read<ProfileBloc>()
                                                            .add(ProfileAcceptUserOnActivityEvent(
                                                                eventId: widget
                                                                    .eventId,
                                                                status:
                                                                    'confirmed',
                                                                userId:
                                                                    participant
                                                                        .user
                                                                        .id!));
                                                      },
                                                      child: SvgPicture.asset(
                                                          'assets/icons/icon_accept.svg')),
                                          leading: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PublicUserScreen(
                                                              userId:
                                                                  participant
                                                                      .user
                                                                      .id!)));
                                            },
                                            child: CircleAvatar(
                                              radius: 32,
                                              backgroundImage: participant
                                                          .user.photoUrl !=
                                                      null
                                                  ? NetworkImage(participant
                                                      .user.photoUrl!)
                                                  : AssetImage(
                                                      'assets/images/image_profile.png'),
                                            ),
                                          ),
                                          horizontalTitleGap: 12,
                                          title: Text(
                                            participant.user.name,
                                            style: TextStyle(
                                                fontSize: 17.14,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: participant
                                                      .user.hasRecentBan !=
                                                  null
                                              ? participant.user.hasRecentBan!
                                                  ? (Text(
                                                      'На данного пользователя поступали жалобы, будьте бдительны.',
                                                      style: TextStyle(
                                                          fontFamily: 'Gilroy',
                                                          fontSize: 8.85,
                                                          color: Colors.red,
                                                          height: 1),
                                                    ))
                                                  : null
                                              : null);
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, top: 5),
                                        child: Divider(),
                                      );
                                    },
                                  )
                            : recommendatedUsersModel != null
                                ? isRequests == false &&
                                        recommendatedUsersModel!.users.isEmpty
                                    ? buildNoUsers()
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        primary: true,
                                        itemCount: recommendatedUsersModel!
                                                .users.length ??
                                            0,
                                        itemBuilder: (context, index) {
                                          final recUser =
                                              recommendatedUsersModel!
                                                  .users[index];
                                          {
                                            return ListTile(
                                                trailing: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    context
                                                        .read<ProfileBloc>()
                                                        .add(
                                                            ProfileInviteUserEvent(
                                                                userId:
                                                                    recUser.id,
                                                                eventId: widget
                                                                    .eventId));
                                                  },
                                                  child: SvgPicture.asset(
                                                      'assets/icons/icon_invite.svg'),
                                                ),
                                                leading: CircleAvatar(
                                                  radius: 32,
                                                  backgroundImage: recUser
                                                              .photoUrl !=
                                                          null
                                                      ? NetworkImage(
                                                          recUser.photoUrl!)
                                                      : AssetImage(
                                                          'assets/images/image_profile.png'),
                                                ),
                                                horizontalTitleGap: 12,
                                                title: Text(
                                                  recUser.name ?? 'Неизвестный',
                                                  style: TextStyle(
                                                      fontSize: 17.14,
                                                      fontFamily: 'Inter',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                subtitle: recUser
                                                            .hasRecentBan !=
                                                        null
                                                    ? recUser.hasRecentBan!
                                                        ? (Text(
                                                            'На данного пользователя поступали жалобы, будьте бдительны.',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Gilroy',
                                                                fontSize: 8.85,
                                                                color:
                                                                    Colors.red,
                                                                height: 1),
                                                          ))
                                                        : null
                                                    : null);
                                          }
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20, right: 20, top: 5),
                                            child: Divider(),
                                          );
                                        },
                                      )
                                : Container()
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget buildNoUsers() {
    return SizedBox(
      //width: MediaQuery.of(context).size.width * 0.8,
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
            'Пока что ничего нет, пригласите ваших друзей',
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
}
