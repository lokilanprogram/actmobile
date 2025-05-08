import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
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
      listener: (context, state) {
        if(state is ProfileGotState){
          setState(() {
          isLoading = false;
          profileModel = state.profileModel;
        });
        }
        if(state is ProfileGotErrorState){
          setState(() {
         isLoading = false;
          });
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child:isLoading?LoaderWidget(): SingleChildScrollView(
        child: Column(
          children: [
            // Top Image with name and status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(25),
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  child:profileModel.photoUrl != null? Image.network(
                    profileModel.photoUrl!,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  ): Image.asset(
                    'assets/images/image_profile.png',
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 70,
                  left: 16,
                  child: Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
                Positioned(
                  top: 70,
                  right: 60,
                  child: Icon(Icons.notifications_none_outlined,
                      color: Colors.white),
                ),
                Positioned(
                  top: 70,
                  right: 16,
                  child: PopupMenuButton<int>(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      offset: const Offset(-10, 50),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<int>(
          value: 0,
          onTap: ()async{
           final result = await Navigator.push(context, MaterialPageRoute(builder: (_)=> UpdateProfileScreen(profileModel: profileModel,)));
          if (result != null && result is ProfileModel) {
  setState(() {
    profileModel = result;
  });
}
          },
          child: Row(
            children:  [
              SvgPicture.asset('assets/icons/icon_edit.svg'),
              SizedBox(width: 10),
              Text("Редактировать профиль",style: TextStyle(
                fontFamily: 'Gilroy',fontSize: 13
              ),),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children:  [
              SvgPicture.asset('assets/icons/icon_settings.svg'),
              SizedBox(width: 10),
              Text("Настройки",style: TextStyle(
                fontFamily: 'Gilroy',fontSize: 13
              ),),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Row(
            children:  [
              SvgPicture.asset('assets/icons/icon_exit.svg'),
              SizedBox(width: 10),
              Text("Выход",style: TextStyle(
                fontFamily: 'Gilroy',fontSize: 13
              ),),
            ],
          ),
        ),
      ],
      child: const Icon(Icons.more_vert, color: Colors.white),
    )
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
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
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
                  const SizedBox(height: 10),
                  const Text(
                    'О себе',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                   Text(
                    profileModel.bio ?? 'Пока пусто...',
                    style: TextStyle(
                        fontSize: 12, fontFamily: 'Inter', height: 1.2),
                  ),
                  const SizedBox(height: 25),
                  // Interests
                  Center(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: profileModel.categories.map((event)=>buildInterestChip(event.name)).toList()
                    ),
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
                    child: ClipRRect(
                      child: Card(
                        elevation: 1.2,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(similarUsers.length, (index) {
                              final user = similarUsers[index];
                              return _buildAvatar(
                                  user['image']!, user['name']!);
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 250),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Avatar widget
  Widget _buildAvatar(String path, String name) {
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


