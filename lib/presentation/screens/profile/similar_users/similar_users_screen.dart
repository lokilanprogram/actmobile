import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/chat_detail_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/public_user/screen/public_user_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

class SimilarUsersScreen extends StatefulWidget {
  const SimilarUsersScreen({super.key});

  @override
  State<SimilarUsersScreen> createState() => _SimilarUsersScreenState();
}

class _SimilarUsersScreenState extends State<SimilarUsersScreen> {
  List<SimiliarUsersModel> similiarUsersModel = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    context.read<ProfileBloc>().add(ProfileGetSimiliarUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileGotSimiliarUsersState) {
          setState(() {
            isLoading = false;
            similiarUsersModel = state.similiarUsersModel;
          });
        } else if (state is ProfileGotSimiliarUsersErrorState) {
          setState(() {
            isLoading = false;
          });
          toastification.show(
            context: context,
            title: Text('Ошибка при загрузке похожих пользователей'),
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            autoCloseDuration: const Duration(seconds: 3),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: Text(
            'Похожие пользователи',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        body: isLoading
            ? LoaderWidget()
            : similiarUsersModel.isEmpty
            ? Center(
                child: Text(
                  'Похожих пользователей не найдено',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PublicUserScreen(
                                  userId: similiarUsersModel[index].id,
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: similiarUsersModel[index]
                                        .photoUrl ==
                                    null
                                ? AssetImage('assets/images/image_profile.png')
                                : NetworkImage(
                                    similiarUsersModel[index].photoUrl!),
                            radius: 23.5,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          similiarUsersModel[index].name ?? '',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17.1,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => ChatDetailScreen(
                            //         interlocutorChatId:
                            //             similiarUsersModel[index].id),
                            //   ),
                            // );
                          },
                          child: Container(
                            width: 82,
                            height: 28,
                            decoration: BoxDecoration(
                              color: mainBlueColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'Написать',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: Divider(),
                    );
                  },
                  itemCount: similiarUsersModel.length,
                ),
              ),
      ),
    );
  }
}
