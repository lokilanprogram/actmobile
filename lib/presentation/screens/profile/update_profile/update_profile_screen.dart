import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/presentation/screens/profile/update_profile/update_hobbies.dart';
import 'package:acti_mobile/presentation/widgets/rotating_icon.dart';
import 'package:http/http.dart' as http;
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:acti_mobile/data/models/local_city_model.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/maps/map/widgets/custom_nav_bar.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_select/events_select_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/update_profile/toggle.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';

class UpdateProfileScreen extends StatefulWidget {
  final ProfileModel profileModel;
  const UpdateProfileScreen({super.key, required this.profileModel});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  bool isOrganizationRepresentative = false;
  final _formKey = GlobalKey<FormState>();
  bool _selectedHideMyEvents = false;
  bool _selectedHideAttendedEvents = false;
  late List<EventOnboarding> selectedCategories;
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController cityController;
  late TextEditingController bioController;
  late TextEditingController emailController;
  bool isLoading = false;
  bool isUpdatedPhoto = false;
  XFile? image;

  List<String> _suggestions = [];
  bool _isLoading = false;
  bool isError = false;

  final ScrollController _scrollController = ScrollController();
  ListOnbordingModel? listOnbordingModel;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String city) async {
    if (city.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/$city.json'
          '?language=ru&proximity=-74.70850,40.78375&country=ru'
          '&access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final model = LocalCityModel.fromJson(jsonDecode(response.body));
        setState(() {
          _suggestions = model.cities.take(5).toList(); // max 5
        });
      } else {
        throw Exception('Ошибка: ${response.body}');
      }
    } catch (e) {
      print('Ошибка поиска: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      nameController = TextEditingController(text: widget.profileModel.name);
      cityController = TextEditingController(text: widget.profileModel.city);
      surnameController =
          TextEditingController(text: widget.profileModel.surname);
      bioController = TextEditingController(text: widget.profileModel.bio);
      emailController = TextEditingController(text: widget.profileModel.email);
      selectedCategories = widget.profileModel.categories;
      isOrganizationRepresentative = widget.profileModel.isOrganization;
      _selectedHideMyEvents = widget.profileModel.hideMyEvents != null &&
              widget.profileModel.hideMyEvents != false
          ? true
          : false;
      _selectedHideAttendedEvents =
          widget.profileModel.hideAttendedEvents != null &&
                  widget.profileModel.hideAttendedEvents != false
              ? true
              : false;
    });
    context.read<AuthBloc>().add(ActiGetOnbordingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ActiGotOnbordingState) {
          setState(() {
            listOnbordingModel = state.listOnbordingModel;
          });
        }
      },
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdatedState) {
            setState(() {
              isLoading = false;
            });
            toastification.show(
              context: context,
              title: Text('Профиль успешно обновлен'),
              type: ToastificationType.success,
              style: ToastificationStyle.fillColored,
              autoCloseDuration: const Duration(seconds: 3),
              alignment: Alignment.topRight,
            );
          }
          if (state is ProfileUpdatedWithPhotoErrorState) {
            setState(() {
              isLoading = false;
            });
            toastification.show(
              context: context,
              title: Text('Возникла проблема с фото: ${state.photoError}'),
              type: ToastificationType.warning,
              style: ToastificationStyle.fillColored,
              autoCloseDuration: const Duration(seconds: 5),
              alignment: Alignment.topRight,
            );
          }
          if (state is ProfileUpdatedErrorState) {
            setState(() {
              isLoading = false;
              bioController.text = "Что-то плохое тут написано, прям фу";
              isError = true;
            });
            toastification.show(
              context: context,
              title: Text(state.errorMessage),
              type: ToastificationType.error,
              style: ToastificationStyle.fillColored,
              autoCloseDuration: const Duration(seconds: 5),
              alignment: Alignment.topRight,
            );
          }
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: isLoading
                ? null
                : AppBar(
                    surfaceTintColor: Colors.white,
                    backgroundColor: Colors.white,
                    centerTitle: true,
                    title: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: SvgPicture.asset('assets/texts/text_profile.svg'),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: IconButton(
                          onPressed: () {
                            if (selectedCategories.isEmpty) {
                              toastification.show(
                                context: context,
                                title: Text('Выберите хотя бы одно увлечение'),
                                type: ToastificationType.error,
                                style: ToastificationStyle.fillColored,
                                autoCloseDuration: const Duration(seconds: 3),
                                alignment: Alignment.topRight,
                              );
                            } else if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              setState(() {
                                isLoading = true;
                              });
                              context.read<ProfileBloc>().add(
                                  ProfileUpdateEvent(
                                      profileModel: ProfileModel(
                                          id: widget.profileModel.id,
                                          hideMyEvents: _selectedHideMyEvents,
                                          hideAttendedEvents:
                                              _selectedHideAttendedEvents,
                                          name: nameController.text.trim(),
                                          surname:
                                              surnameController.text.trim(),
                                          email: emailController.text.trim(),
                                          city: cityController.text.trim(),
                                          isEmailVerified: widget
                                              .profileModel.isEmailVerified,
                                          isProfileCompleted: widget
                                              .profileModel.isProfileCompleted,
                                          bio: bioController.text.trim(),
                                          isOrganization:
                                              isOrganizationRepresentative,
                                          photoUrl: image?.path,
                                          status: widget.profileModel.status,
                                          notificationsEnabled: widget
                                              .profileModel
                                              .notificationsEnabled,
                                          categories: selectedCategories)));
                            } else {
                              // Проверяем каждое поле и показываем соответствующие сообщения
                              if (nameController.text.trim().isEmpty) {
                                toastification.show(
                                  context: context,
                                  title: Text('Заполните поле "Имя"'),
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.fillColored,
                                  autoCloseDuration: const Duration(seconds: 3),
                                  alignment: Alignment.topRight,
                                );
                              }
                              if (cityController.text.trim().isEmpty) {
                                toastification.show(
                                  context: context,
                                  title: Text('Заполните поле "Город"'),
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.fillColored,
                                  autoCloseDuration: const Duration(seconds: 3),
                                  alignment: Alignment.topRight,
                                );
                              }
                              if (emailController.text.trim().isEmpty) {
                                toastification.show(
                                  context: context,
                                  title: Text('Заполните поле "Email"'),
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.fillColored,
                                  autoCloseDuration: const Duration(seconds: 3),
                                  alignment: Alignment.topRight,
                                );
                              }
                              if (bioController.text.trim().isEmpty) {
                                toastification.show(
                                  context: context,
                                  title: Text('Заполните поле "О себе"'),
                                  type: ToastificationType.error,
                                  style: ToastificationStyle.fillColored,
                                  autoCloseDuration: const Duration(seconds: 3),
                                  alignment: Alignment.topRight,
                                );
                              }
                            }
                          },
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SvgPicture.asset(
                                'assets/icons/icon_success_edit.svg'),
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
                              padding: EdgeInsets.only(
                                  left: 30,
                                  right: 30,
                                  top: 10,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: ListView(
                                controller: _scrollController,
                                children: [
                                  Center(
                                    child: editableAvatar(
                                        isUpdatedPhoto
                                            ? image!.path
                                            : (widget.profileModel.photoUrl ??
                                                'assets/images/image_profile.png'),
                                        () async {
                                      final xfile = await ImagePicker()
                                          .pickImage(
                                              source: ImageSource.gallery);
                                      if (xfile != null) {
                                        setState(() {
                                          image = xfile;
                                          isUpdatedPhoto = true;
                                        });
                                      }
                                    }, isUpdatedPhoto),
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
                                  TextInputNameWidget(
                                      controller: nameController,
                                      text: 'Введите имя',
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return 'Заполните имя';
                                        }
                                        return null;
                                      }),
                                  SizedBox(height: 16),
                                  Text('Фамилия (необязательно)',
                                      style: titleTextStyleEdit),
                                  SizedBox(height: 4),
                                  TextFormField(
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    controller: surnameController,
                                    decoration: InputDecoration(
                                      hintText: 'Введите фамилию',
                                      hintStyle: hintTextStyleEdit,
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    validator: (val) {
                                      if (val != null && val.isNotEmpty) {
                                        if (!RegExp(r'^[а-яА-ЯёЁa-zA-Z\s-]+$')
                                            .hasMatch(val)) {
                                          return 'Используйте только буквы';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                      OrgToggleTooltip(
                                          scrollController: _scrollController),
                                      Expanded(child: cupertinoSwitch()),
                                    ],
                                  ),

                                  SizedBox(height: 16),
                                  Text('Ваш город (Населённый пункт)',
                                      style: titleTextStyleEdit),
                                  SizedBox(height: 4),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        controller: cityController,
                                        onChanged: _searchLocation,
                                        style: TextStyle(
                                            fontSize: 11, fontFamily: 'Inter'),
                                        decoration: InputDecoration(
                                          hintText: 'Введите город',
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Заполните город';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 4),
                                      if (_isLoading)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Center(
                                              child: CircularProgressIndicator(
                                            color: mainBlueColor,
                                            strokeWidth: 1.2,
                                          )),
                                        )
                                      else if (_suggestions.isNotEmpty)
                                        Container(
                                          constraints:
                                              BoxConstraints(maxHeight: 160),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: _suggestions.length,
                                            itemBuilder: (context, index) {
                                              final city = _suggestions[index];
                                              return ListTile(
                                                dense: true,
                                                title: Text(city,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'Gilroy')),
                                                onTap: () {
                                                  cityController.text = city;
                                                  setState(
                                                      () => _suggestions = []);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Text('Адрес эл. почты',
                                      style: titleTextStyleEdit),
                                  SizedBox(height: 4),
                                  TextInputWidget(
                                    controller: emailController,
                                    text: 'E-mail',
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return 'Заполните e-mail';
                                      }
                                      return null;
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: widget.profileModel.isEmailVerified
                                        ? Text(
                                            'Почта подтверждена ',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400),
                                          )
                                        : Text(
                                            'Почта не подтверждена ',
                                            style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.red,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400),
                                          ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'О себе',
                                    style: titleTextStyleEdit,
                                  ),
                                  SizedBox(height: 4),
                                  TextFormField(
                                    style: TextStyle(
                                        fontSize: 11, fontFamily: 'Inter'),
                                    maxLines: 3,
                                    keyboardType: TextInputType.multiline,
                                    controller: bioController,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Заполните поле "О себе"';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() => isError = false);
                                      if (value.isNotEmpty) {
                                        final formattedValue =
                                            value[0].toUpperCase() +
                                                value.substring(1);
                                        if (formattedValue != value) {
                                          bioController.value =
                                              TextEditingValue(
                                            text: formattedValue,
                                            selection: TextSelection.collapsed(
                                                offset: formattedValue.length),
                                          );
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: isError
                                          ? "Обнаружены недопустимые слова"
                                          : "",
                                      labelStyle: TextStyle(color: Colors.red),
                                      hintText: 'Напишите что-нибудь о себе...',
                                      hintStyle: hintTextStyleEdit.copyWith(
                                        color:
                                            isError ? Colors.red : Colors.black,
                                      ),
                                      enabledBorder: isError
                                          ? OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide:
                                                  BorderSide(color: Colors.red))
                                          : OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide.none),
                                      focusedBorder: isError
                                          ? OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide:
                                                  BorderSide(color: Colors.red))
                                          : OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide.none),
                                      border: isError
                                          ? OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide:
                                                  BorderSide(color: Colors.red))
                                          : OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              borderSide: BorderSide.none),
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
                                            if (_selectedHideMyEvents == true) {
                                              setState(() {
                                                _selectedHideMyEvents = false;
                                              });
                                            } else {
                                              setState(() {
                                                _selectedHideMyEvents = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 20),
                                            decoration: BoxDecoration(
                                                color: _selectedHideMyEvents ==
                                                        true
                                                    ? mainBlueColor
                                                    : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: Center(
                                              child: Text(
                                                'Мои',
                                                style: TextStyle(
                                                    color:
                                                        _selectedHideMyEvents ==
                                                                true
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        _selectedHideMyEvents ==
                                                                true
                                                            ? FontWeight.w800
                                                            : FontWeight.w400,
                                                    fontFamily: 'Gilroy'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 25,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_selectedHideAttendedEvents ==
                                                true) {
                                              setState(() {
                                                _selectedHideAttendedEvents =
                                                    false;
                                              });
                                            } else {
                                              setState(() {
                                                _selectedHideAttendedEvents =
                                                    true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 20),
                                            decoration: BoxDecoration(
                                                color:
                                                    _selectedHideAttendedEvents ==
                                                            true
                                                        ? mainBlueColor
                                                        : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            child: Center(
                                              child: Text(
                                                'Учавствую',
                                                style: TextStyle(
                                                    color:
                                                        _selectedHideAttendedEvents ==
                                                                true
                                                            ? Colors.white
                                                            : Colors.black,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        _selectedHideAttendedEvents ==
                                                                true
                                                            ? FontWeight.w800
                                                            : FontWeight.w400,
                                                    fontFamily: 'Gilroy'),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Ваши увлечения:',
                                          style: titleTextStyleEdit),
                                      TextButton(
                                        onPressed: listOnbordingModel == null
                                            ? null
                                            : () async {
                                                final result =
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                UpdateHobbiesScreen(
                                                                  fromUpdate:
                                                                      true,
                                                                  categories:
                                                                      listOnbordingModel!
                                                                          .categories,
                                                                )));
                                                if (result != null &&
                                                    result is List<
                                                        EventOnboarding>) {
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
                                              color: listOnbordingModel == null
                                                  ? Colors.grey
                                                  : mainBlueColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  buildInterestsGrid(
                                    selectedCategories
                                        .map((e) => e.name)
                                        .toList(),
                                  ),
                                  SizedBox(
                                    height: 150,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget editableAvatar(
      String imagePath, VoidCallback onEdit, bool isUpdatedImage) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: isUpdatedImage
              ? FileImage(File(imagePath))
              : (imagePath == 'assets/images/image_profile.png'
                  ? AssetImage(imagePath)
                  : NetworkImage(imagePath)),
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

  Widget cupertinoSwitch() {
    return CupertinoSwitch(
        activeTrackColor: Colors.blue,
        value: isOrganizationRepresentative,
        onChanged: (val) {
          setState(() {
            isOrganizationRepresentative = !isOrganizationRepresentative;
          });
        });
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
    required this.controller,
    required this.text,
    required this.validator,
  });

  final TextEditingController controller;
  final String text;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
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
    required this.controller,
    required this.text,
    required this.validator,
  });

  final TextEditingController controller;
  final String text;
  final String? Function(String?)? validator;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Заполните поле';
    }
    if (!RegExp(r'^[а-яА-ЯёЁa-zA-Z\s-]+$').hasMatch(value)) {
      return 'Используйте только буквы';
    }
    return null;
  }

  String _formatName(String value) {
    if (value.isEmpty) return value;
    // Удаляем все символы кроме букв, пробелов и дефиса
    value = value.replaceAll(RegExp(r'[^а-яА-ЯёЁa-zA-Z\s-]'), '');
    // Делаем первую букву заглавной
    if (value.isNotEmpty) {
      value = value[0].toUpperCase() + value.substring(1).toLowerCase();
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: 18, fontFamily: 'Inter'),
      controller: controller,
      validator: validator ?? _validateName,
      onChanged: (value) {
        final formattedValue = _formatName(value);
        if (formattedValue != value) {
          controller.value = TextEditingValue(
            text: formattedValue,
            selection: TextSelection.collapsed(offset: formattedValue.length),
          );
        }
      },
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
