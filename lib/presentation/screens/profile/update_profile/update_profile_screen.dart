import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_select/events_select_screen.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UpdateProfileScreen extends StatefulWidget {
  final ProfileModel profileModel;
  const UpdateProfileScreen({super.key, required this.profileModel});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  bool isOrganizationRepresentative = false;
  bool isLoading = false;
  String _selectedTab = 'my';
  late List<EventOnboarding> selectedCategories;
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController bioController;
  late TextEditingController emailController;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      nameController = TextEditingController(text: widget.profileModel.name);
      surnameController =
          TextEditingController(text: widget.profileModel.surname);
      bioController = TextEditingController(text: widget.profileModel.bio);
      emailController = TextEditingController(text: widget.profileModel.email);
      selectedCategories = widget.profileModel.categories;
      isOrganizationRepresentative = widget.profileModel.isOrganization;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if(state is ProfileUpdatedState){
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context, state.profileModel);
        }
        if(state is ProfileUpdatedErrorState){
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, size: 22),
            ),
          ),
          title: Text(
            'Профиль',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w300,
              fontSize: 28,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  context.read<ProfileBloc>().add(ProfileUpdateEvent(
                    profileModel: ProfileModel(id: widget.profileModel.id,
                     name: nameController.text.trim(), surname: surnameController.text.trim(), email: 
                     emailController.text.trim(), 
                     bio: bioController.text.trim(), 
                     isOrganization: isOrganizationRepresentative, photoUrl: widget.profileModel.photoUrl, 
                     status: widget.profileModel.status, categories: selectedCategories)
                  ));
                },
                icon: SvgPicture.asset('assets/icons/icon_success_edit.svg'),
              ),
            ),
          ],
        ),
        body: isLoading
            ? LoaderWidget()
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: ListView(
                    children: [
                      Center(
                        child: editableAvatar(widget.profileModel.photoUrl??'assets/images/image_profile.png',
                            () {
                          // действие редактирования фото
                          print("Редактировать фото");
                        }),
                      ),
                      const SizedBox(height: 30),

                      // Новые виджеты добавлены здесь:
                      Text(
                        'Имя',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Введите имя',
                          hintStyle: hintTextStyleEdit,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Фамилия (необязательно)',
                          style: titleTextStyleEdit),
                      SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                        controller: surnameController,
                        decoration: InputDecoration(
                          hintText: 'Введите фамилию',
                          hintStyle: hintTextStyleEdit,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Представитель организации / ИП',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: mainBlueColor),
                          ),
                          SizedBox(width: 8),
                          SvgPicture.asset('assets/icons/icon_info.svg'),
                          SizedBox(width: 24),
                          _buildSwitch()
                        ],
                      ),
                      SizedBox(height: 16),
                      Text('Ваш город (Населённый пункт)',
                          style: titleTextStyleEdit),
                      SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                        decoration: InputDecoration(
                          hintText: 'Введите город',
                          hintStyle: hintTextStyleEdit,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text('Адрес эл. почты', style: titleTextStyleEdit),
                      SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                        controller: emailController,
                        decoration: InputDecoration(
                          hintStyle: hintTextStyleEdit,
                          hintText: 'E-mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'О себе',
                        style: titleTextStyleEdit,
                      ),
                      SizedBox(height: 4),
                      TextFormField(
                        style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
                        maxLines: 3,
                        controller: bioController,
                        decoration: InputDecoration(
                          hintText: 'Напишите что-нибудь о себе...',
                          hintStyle: hintTextStyleEdit,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Скрыть мероприятия:',
                        style: titleTextStyleEdit,
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTab = 'my';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                    color: _selectedTab == 'my'
                                        ? mainBlueColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(25)),
                                child: Center(
                                  child: Text(
                                    'Мои',
                                    style: TextStyle(
                                        color: _selectedTab == 'my'
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 13,
                                        fontFamily: 'Inter'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTab = 'visited';
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                    color: _selectedTab == 'visited'
                                        ? mainBlueColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(25)),
                                child: Center(
                                  child: Text(
                                    'Посещённые',
                                    style: TextStyle(
                                        color: _selectedTab == 'visited'
                                            ? Colors.white
                                            : Colors.black,
                                        fontSize: 13,
                                        fontFamily: 'Inter'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ваши увлечения:', style: titleTextStyleEdit),
                          TextButton(
                            onPressed: ()async {
                            final result = await   Navigator.push(context, MaterialPageRoute(builder: (context)=> EventsSelectScreen(fromUpdate: true,)));
                             if (result != null && result is List<EventOnboarding>) {
  setState(() {
    selectedCategories = result;
  });
}
                            },
                            child: Text(
                              'Изменить',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: mainBlueColor),
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: selectedCategories
                                .map((event) => buildInterestChip(event.name))
                                .toList()),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget editableAvatar(String imagePath, VoidCallback onEdit) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:imagePath == 'assets/images/image_profile.png'? AssetImage(imagePath):NetworkImage(imagePath),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: onEdit,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isOrganizationRepresentative = !isOrganizationRepresentative;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 40.0,
        height: 25.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color:
              isOrganizationRepresentative ? mainBlueColor : Colors.grey[300],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: AnimatedAlign(
            duration: Duration(milliseconds: 300),
            alignment: isOrganizationRepresentative
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInterestButton(String label) {
    return ElevatedButton(
      onPressed: () {
        // TODO: implement interest selection action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.grey[400]!),
        ),
      ),
      child: Text(label),
    );
  }
}
