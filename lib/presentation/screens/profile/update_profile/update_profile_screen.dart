import 'dart:io';

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_select/events_select_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/update_profile/toggle.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  final ProfileModel profileModel;
  const UpdateProfileScreen({super.key, required this.profileModel});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  bool isOrganizationRepresentative = false;
  final _formKey = GlobalKey<FormState>();
  String _selectedTab = 'my';
  late List<EventOnboarding> selectedCategories;
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController cityController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  bool isLoading = false;
  bool isUpdatedPhoto = false;
  XFile? image;
  

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      nameController = TextEditingController(text: widget.profileModel.name);
      cityController = TextEditingController(text:  widget.profileModel.city);
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
          if(widget.profileModel.email != state.profileModel.email){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Проверьте почту и перейдите по ссылке для активации'),backgroundColor: Colors.green,));
          }
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
        appBar:isLoading?null:  AppBar(
          backgroundColor: Colors.white,
          leading: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: IconButton(
              onPressed: () {
                if(!widget.profileModel.isProfileCompleted){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=> MapScreen()));
                }else{
                  Navigator.pop(context);
                }
              },
              icon: SvgPicture.asset('assets/icons/icon_back.svg'),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: SvgPicture.asset('assets/texts/text_profile.svg'),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                onPressed: () {
                if(selectedCategories.isEmpty){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите увлечения')));
                }else if(_formKey.currentState!.validate()){
                  _formKey.currentState!.save();
                   setState(() {
                    isLoading = true;
                  });
                  context.read<ProfileBloc>().add(ProfileUpdateEvent(
                    profileModel: ProfileModel(id: widget.profileModel.id,
                     name: nameController.text.trim(), surname: surnameController.text.trim(), email: 
                     emailController.text.trim(), 
                     city: cityController.text.trim(),
                     isEmailVerified: widget.profileModel.isEmailVerified,
                     isProfileCompleted: widget.profileModel.isProfileCompleted,
                     bio: bioController.text.trim(), 
                     isOrganization: isOrganizationRepresentative, photoUrl: image?.path , 
                     status: widget.profileModel.status, categories: selectedCategories)
                  ));
                 }
                },
                icon: Padding(
            padding: const EdgeInsets.only(bottom: 4),
                  child: SvgPicture.asset('assets/icons/icon_success_edit.svg'),
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? LoaderWidget()
            : Form(
              key: _formKey,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 30, top: 10, bottom: 10),
                          child: ListView(
                            children: [
                              Center(
                                child: 
                               editableAvatar(
                                  isUpdatedPhoto ? image!.path :(widget.profileModel.photoUrl??'assets/images/image_profile.png'),
                                    () async{
                                   final xfile = await ImagePicker()
                                                  .pickImage(
                                                      source: ImageSource.gallery);
                                              if (xfile != null) {
                                                setState(() {
                                                  image = xfile;
                                                  isUpdatedPhoto = true;
                                                });
                                              } 
                                },isUpdatedPhoto),
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
                              TextInputNameWidget(controller: nameController,text: 'Введите имя',
                              validator: (val){
                                if(val!.isEmpty){
                                return 'Заполните имя';
                                }
                                return null;
                              }),
                              SizedBox(height: 16),
                              Text('Фамилия (необязательно)',
                                  style: titleTextStyleEdit),
                              SizedBox(height: 4),
                              TextInputNameWidget(controller: surnameController,text: 'Введите фамилию',
                              validator: (val){
                                if(val!.isEmpty){
                                return 'Заполните фамилию';
                                }
                              },),
                              SizedBox(height: 16),
                             Row(
                                 crossAxisAlignment: CrossAxisAlignment.center,
                                 children: [
                                   Text(
                                     'Представитель организации / ИП',
                                     style: TextStyle(
                                       fontFamily: 'Inter',
                                       fontSize: 13,
                                       color: mainBlueColor,
                                     ),
                                   ),
                                   SizedBox(width: 8),
                                   OrgToggleTooltip(),
                                   SizedBox(width: 24),
                                   _buildSwitch(),
                                 ],
                               ),
                             
                              SizedBox(height: 16),
                              Text('Ваш город (Населённый пункт)',
                                  style: titleTextStyleEdit),
                              SizedBox(height: 4),
                              TextInputWidget(controller: cityController, text: 'Введите город',validator: null,),
                              SizedBox(height: 16),
                              Text('Адрес эл. почты', style: titleTextStyleEdit),
                              SizedBox(height: 4),
                              TextInputWidget(controller: emailController, text: 'E-mail',validator: (val){
                                if(val!.isEmpty){
                                  return 'Заполните e-mail';
                                }
                              },),
                              SizedBox(height: 16),
                              Text(
                                'О себе',
                                style: titleTextStyleEdit,
                              ),
                              SizedBox(height: 4),
                              TextFormField(
                                style: TextStyle(fontSize: 11, fontFamily: 'Inter'),
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
                                            vertical: 12, horizontal: 20),
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
                                  SizedBox(width: 25,),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedTab = 'visited';
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 20),
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
                              SizedBox(height: 100,),
                            ],
                          ),
                        ),
                      ),
                  ),
                  Align(
           alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
                child: CustomNavBarWidget(selectedIndex: 4, onTabSelected: (index){
                if(index == 0){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> 
                  MapScreen()));
                }
              }),
            )),
                ],
              ),
            ),
      ),
    );
  }

  Widget editableAvatar(String imagePath, VoidCallback onEdit, bool isUpdatedImage) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:isUpdatedImage ? FileImage(File(imagePath)): (imagePath 
          == 'assets/images/image_profile.png'? 
          AssetImage(imagePath):NetworkImage(imagePath)),
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

}

class TextInputWidget extends StatelessWidget {
  const TextInputWidget({
    super.key,
    required this.controller, required this.text,required this.validator,
  });

  final TextEditingController controller;
  final String text;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontSize: 11, fontFamily: 'Inter'),
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        
        hintText: text,
        hintStyle: hintTextStyleEdit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

class TextInputNameWidget extends StatelessWidget {
  const TextInputNameWidget({
    super.key,
    required this.controller, required this.text,required this.validator,
  });

  final TextEditingController controller;
  final String text;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        
        hintText: text,
        hintStyle: hintTextStyleEdit,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
