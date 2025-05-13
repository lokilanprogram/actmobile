import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/profile/profile_menu/widgets/popup_profile_buttons.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../update_profile/update_profile_screen.dart';

class ProfileMenuScreen extends StatefulWidget {
  const ProfileMenuScreen({super.key});

  @override
  State<ProfileMenuScreen> createState() => _ProfileMenuScreenState();
}

class _ProfileMenuScreenState extends State<ProfileMenuScreen> {
  bool isLoading = false;
  late ProfileModel profileModel;
  late List<SimiliarUsersModel> similiarUsersModel;

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

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is ProfileGotState) {
          setState(() {
            isLoading = false;
            profileModel = state.profileModel;
            similiarUsersModel = state.similiarUsersModel;
          });

          if (!profileModel.isProfileCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Заполните профиль и подтвердите email для полного доступа'),
              backgroundColor: Colors.green,
            ));
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => UpdateProfileScreen(
                          profileModel: profileModel,
                        )));
            if (result != null && result is ProfileModel) {
              setState(() {
                profileModel = result;
              });
            }
          }
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
            body: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(color: Colors.white),
                    ),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(25),
                              topLeft: Radius.circular(25),),
                          child: profileModel.photoUrl != null
                              ? Image.network(
                                  profileModel.photoUrl!,
                                  width: double.infinity,
                                  height: 350,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/image_profile.png',
                                  width: double.infinity,
                                  height: 350,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 77,
                          left: 39,
                          child: SvgPicture.asset('assets/icons/icon_back_white.svg')
                        ),
                        Positioned(
                          top: 77,
                          right: 60,
                          child: Icon(Icons.notifications_none_outlined,
                              color: Colors.white),
                        ),
                        Positioned(
                            top: 77,
                            right: 20,
                            child: PopUpProfileButtons(
                              function: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => UpdateProfileScreen(
                                              profileModel: profileModel,
                                            )));
                                if (result != null && result is ProfileModel) {
                                  setState(() {
                                    profileModel = result;
                                  });
                                }
                              },
                            )),
                        Positioned(
                          bottom: 60,
                          left: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profileModel.name ?? 'Неизвестное имя',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                capitalize(profileModel.status),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 300,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25),
                          ),
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
                            const SizedBox(height: 15),
                            // Interests
                            Center(
                              child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: profileModel.categories
                                      .map((event) => buildInterestChip(event.name))
                                      .toList()),
                            ),
                      
                            const SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: const Text(
                                'Похожие пользователи',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Gilroy'),
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Similar users row
                            Center(
                              child: buildNoUsers(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }

  Widget buildNoUsers(){
    return Card(
         shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white70, width: 1),
        borderRadius: BorderRadius.circular(30),
      ),
        elevation: 1.2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal:25, vertical: 20),
          child: Text('Здесь скоро появится список людей со схожими интересами',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Gilroy',fontSize: 15, color: mainBlueColor,
          fontWeight: FontWeight.w500),),
        ),
      );
  }

  // Avatar widget
  Widget buildAvatar(String path, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(path),
            radius: 28,
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
