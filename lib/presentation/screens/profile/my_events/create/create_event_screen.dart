import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/mapbox_model.dart';
import 'package:acti_mobile/data/models/mapbox_reverse_model.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geotypes/src/geojson.dart';
import 'package:acti_mobile/data/models/mapbox_model.dart' as mapbox;
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/alter_event_model.dart';
import 'package:acti_mobile/data/models/local_address_model.dart';
import 'package:acti_mobile/data/models/local_city_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/map_picker/map_picker_screen.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/selector_day_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../../data/models/list_onbording_model.dart';

class CreateEventScreen extends StatefulWidget {
  final OrganizedEventModel? organizedEventModel;

  const CreateEventScreen({super.key, required this.organizedEventModel});
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  bool isOnline = false;
  bool isRecurring = false;
  bool is18plus = false;
  bool isKidsAllowed = false;
  bool isPetFriendly = false;
  bool isUnlimited = false;
  bool isGroupChat = false;
  bool isLoading = true;
  int peopleCount = 10;
  int startSelectedHour = 17;
  int startSelectedMinute = 0;
  int endSelectedHour = 18;
  int endSelectedMinute = 0;
  FixedExtentScrollController? startSelectedHourController;
  FixedExtentScrollController? startSelectedMinuteController;
  FixedExtentScrollController? endSelectedHourController;
  FixedExtentScrollController? endSelectedMinuteController;
  EventOnboarding? selectedCategory;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final dateController = TextEditingController();
  final priceController = TextEditingController();
  DateTime? selectedDate;
  LocalAddressModel? selectedAddressModel;

  final _formKey = GlobalKey<FormState>();
  late List<EventOnboarding> eventCategories;
  List<String> deletedImages = [];
  String? recurringDay = 'Вторник';
  final dateFormatter = MaskTextInputFormatter(
    mask: '##.##.####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  List<MapBoxSuggestion> _suggestions = [];
  bool _isLoading = false;
  final FocusNode dateFocusNode = FocusNode();

  bool isError = false;

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2025),
        lastDate: DateTime(2026),
        locale: const Locale('ru'));

    setState(() {
      selectedDate = pickedDate;
      if (pickedDate == null) {
        final date = DateTime.now();
        dateController.text =
            formatDate('${date.day}.${date.month}.${date.year}');
      }
      if (selectedDate == null) {
        final pickedDateNow = DateTime.now();
        dateController.text = formatDate(
            '${pickedDateNow!.day}.${pickedDateNow.month}.${pickedDateNow.year}');
      } else {
        dateController.text = formatDate(
            '${pickedDate!.day}.${pickedDate.month}.${pickedDate.year}');
      }
    });
    Future.delayed(Duration.zero, () {
      dateFocusNode.requestFocus();
    });
  }

  final List<String> _images = [];
  final picker = ImagePicker();

  Future<void> _searchLocation(String place) async {
    if (place.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final RegExp regExp = RegExp(
        r'(\d+)\s*(корпус|кор|к)\s*(\d+)',
        caseSensitive: false,
      );
      place = place.replaceAllMapped(regExp, (match) {
        final houseNumber = match.group(1);
        final buildingNumber = match.group(3);
        return '$houseNumberк$buildingNumber';
      });
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$place.json'
          '?language=ru&proximity=-74.70850,40.78375&country=ru&types=address,place,neighborhood,district,locality'
          '&access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List features = data['features'] ?? [];
        setState(() {
          _suggestions =
              features.map((f) => MapBoxSuggestion.fromJson(f)).toList();
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

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _images.add(picked.path);
      });
    }
  }

  void _removeImage(String imagePath) {
    setState(() {
      if (imagePath.contains('http://93.183.81.104')) {
        deletedImages.add(imagePath);
      }
      _images.removeWhere((image) => image == imagePath);
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    dateFocusNode.dispose();
    super.dispose();
  }

  initialize() async {
    setState(() {
      isLoading = true;
    });
    final event = widget.organizedEventModel;

    if (event != null) {
      DateTime startParsedTime = DateFormat("HH:mm:ss").parse(event.timeStart);
      DateTime endParsedTime = DateFormat("HH:mm:ss").parse(event.timeEnd);

      int startHourIndex = startParsedTime.hour;
      int startMinuteIndex = startParsedTime.minute;
      int endHourIndex = endParsedTime.hour;
      int endMinuteIndex = endParsedTime.minute;
      for (var photo in event.photos) {
        _images.add(photo);
      }
      for (var restrict in event.restrictions) {
        if (restrict == 'isKidsNotAllowed') {
          setState(() {
            is18plus = true;
          });
        }
        if (restrict == 'withKids') {
          setState(() {
            isKidsAllowed = true;
          });
        }
        if (restrict == 'withAnimals') {
          setState(() {
            isPetFriendly = true;
          });
        }
        if (restrict == 'isUnlimited') {
          setState(() {
            isUnlimited = true;
            peopleCount = 0;
          });
        }
      }
      setState(() {
        selectedAddressModel = LocalAddressModel(
            address: event.address,
            latitude: event.latitude,
            longitude: event.longitude,
            properties: null);
        titleController.text = event.title;
        descriptionController.text = event.description;
        isRecurring = event.isRecurring;
        isOnline = event.type == 'online' ? true : false;
        addressController.text = event.address;
        dateController.text = DateFormat('dd.MM.yyyy').format(event.dateStart);
        priceController.text = event.price != 0 ? event.price.toString() : '';
        peopleCount = event.slots;
        startSelectedHourController =
            FixedExtentScrollController(initialItem: startHourIndex);
        startSelectedMinuteController =
            FixedExtentScrollController(initialItem: startMinuteIndex);
        endSelectedHourController =
            FixedExtentScrollController(initialItem: endHourIndex);
        endSelectedMinuteController =
            FixedExtentScrollController(initialItem: endMinuteIndex);
      });
    } else {
      setState(() {
        startSelectedHourController =
            FixedExtentScrollController(initialItem: startSelectedHour);
        startSelectedMinuteController =
            FixedExtentScrollController(initialItem: startSelectedMinute);
        endSelectedHourController =
            FixedExtentScrollController(initialItem: endSelectedHour);
        endSelectedMinuteController =
            FixedExtentScrollController(initialItem: endSelectedMinute);
      });
    }
    context.read<AuthBloc>().add(ActiGetOnbordingEvent());
  }

  String errorText = '';
  @override
  Widget build(BuildContext context) {
    List<Widget> bottomGrid = [];
    if (_images.length > 1) {
      for (int i = 1; i < _images.length; i++) {
        bottomGrid.add(_buildImage(_images[i], 80, 80));
      }
    }
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ActiCreatedActivityState) {
          context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
          showAlertOKDialog(context,
              'Ваше событие отправлено на проверку. Будет опубликовано после модерации.',
              isTitled: true, title: 'Событие на проверке!');
        }
        if (state is ActiUpdatedActivityState) {
          context.read<ProfileBloc>().add(ProfileGetListEventsEvent());
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context, widget.organizedEventModel);
          showAlertOKDialog(context, 'Ваше событие успешно отредактировано.',
              isTitled: true, title: 'Событие отредактировано');
        }
        if (state is ActiCreatedActivityErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }

        if (state is ActiUpdatedActivityErrorState) {
          setState(() {
            isLoading = false;
            if (state.message ==
                "Название или описание содержит запрещенные слова") {
              isError = true;
            }
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is ActiGotOnbordingState) {
          setState(() {
            isLoading = false;
            eventCategories = state.listOnbordingModel.categories;
            selectedCategory = widget.organizedEventModel != null
                ? state.listOnbordingModel.categories.firstWhere((category) =>
                    category.id == widget.organizedEventModel!.category_id)
                : null;
          });
        }
        if (state is ActiGotOnbordingErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // скрыть клавиатуру
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: isLoading
              ? null
              : AppBar(
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  scrolledUnderElevation: 0,
                  backgroundColor: Colors.transparent,
                  title: Text(widget.organizedEventModel != null
                      ? 'Обновление активности'
                      : "Создание активности"),
                ),
          body: isLoading
              ? LoaderWidget()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_images.isEmpty) ...[
                              _buildLargeAddButton(),
                            ] else ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildImage(
                                      _images[0],
                                      MediaQuery.of(context).size.height * 0.24,
                                      118),
                                  const SizedBox(width: 14),
                                  _buildSmallAddButton(),
                                ],
                              ),
                            ],
                            const SizedBox(height: 16),
                            if (bottomGrid.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: bottomGrid,
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (widget.organizedEventModel?.status != 'completed' &&
                            widget.organizedEventModel?.status != 'canceled' &&
                            widget.organizedEventModel?.status !=
                                'rejected') ...[
                          Text(
                            'Название события',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField("Введите название вашего события",
                              controller: titleController),
                          const SizedBox(height: 20),
                          _buildSwitchTile("Событие ОНЛАЙН", isOnline,
                              (v) => setState(() => isOnline = v)),
                          isOnline
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 5, bottom: 5, left: 5),
                                  child: Text(
                                    'Для онлайн-события укажите в описании ссылку на подключение или иной способ доступа.',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                        color: Color.fromRGBO(137, 137, 137, 1),
                                        height: 1),
                                  ),
                                )
                              : Container(),
                          const SizedBox(height: 14),
                          !isOnline
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              onChanged: _searchLocation,
                                              maxLines: 1,
                                              controller: addressController,
                                              decoration: InputDecoration(
                                                  fillColor: Colors.grey[200],
                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      borderSide:
                                                          BorderSide.none),
                                                  hintText: 'Адрес',
                                                  hintStyle: TextStyle(
                                                      fontFamily: 'Gilroy',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              LocalAddressModel?
                                                  localAddressModel =
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MapPickerScreen(
                                                                isCreated: true,
                                                                position: selectedAddressModel?.latitude !=
                                                                        null
                                                                    ? Position(
                                                                        selectedAddressModel!
                                                                            .longitude!,
                                                                        selectedAddressModel!
                                                                            .latitude!)
                                                                    : null,
                                                                address: null,
                                                              )));
                                              if (localAddressModel != null) {
                                                setState(() {
                                                  addressController.text =
                                                      localAddressModel
                                                              .address ??
                                                          "";
                                                  selectedAddressModel =
                                                      localAddressModel;
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: 49,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[200],
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15, bottom: 15),
                                                child: SvgPicture.asset(
                                                    'assets/icons/icon_map.svg'),
                                              ),
                                            ),
                                          )
                                        ],
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
                                                title: Text(city.placeName,
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'Gilroy')),
                                                onTap: () {
                                                  final parts = city.placeName
                                                      ?.split(', ');
                                                  if (parts!.length == 6) {
                                                    addressController.text =
                                                        'г. ${parts[2]}, ${parts[5]}';
                                                  } else {
                                                    addressController.text =
                                                        city.shortAddress;
                                                  }
                                                  setState(() {
                                                    _suggestions = [];
                                                    selectedAddressModel =
                                                        LocalAddressModel(
                                                            address:
                                                                addressController
                                                                    .text
                                                                    .trim(),
                                                            latitude:
                                                                city.latitude,
                                                            longitude:
                                                                city.longitude,
                                                            properties: null);
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : Container(),
                          SizedBox(height: isOnline ? 0 : 14),
                          _buildSwitchTile("Повторяющееся событие", isRecurring,
                              (v) => setState(() => isRecurring = v)),
                          const SizedBox(height: 14),
                          !isRecurring
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: TextFormField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        maxLines: 1,
                                        focusNode: dateFocusNode,
                                        controller: dateController,
                                        inputFormatters: [dateFormatter],
                                        decoration: InputDecoration(
                                          hintText: 'Дата',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Gilroy',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[200],
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 16),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      )),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Future.delayed(Duration.zero, () {
                                            dateFocusNode.requestFocus();
                                          });
                                          selectDate();
                                        },
                                        child: Container(
                                          width: 49,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 15, bottom: 15),
                                            child: SvgPicture.asset(
                                                'assets/icons/icon_calendar_activity.svg'),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : DayOfWeekSelector(
                                  selectedDay: recurringDay!,
                                  onChanged: (val) {
                                    setState(() {
                                      recurringDay = val!;
                                    });
                                  }),
                          const SizedBox(height: 28),
                          Text(
                            'Время начала:',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          startTimePicker(),
                          const SizedBox(height: 28),
                          Text(
                            'Время конца:',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          endTimePicker(),
                          const SizedBox(height: 28),
                          Text(
                            'Стоимость участия',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField("Введите цену",
                              isPrice: true,
                              suffixText: "₽",
                              controller: priceController),
                          const SizedBox(height: 24),
                          _buildSwitchTile("Ограничение 18+", is18plus, (v) {
                            setState(() {
                              is18plus = v;
                              if (v) isKidsAllowed = false;
                            });
                          }),
                          const SizedBox(height: 10),
                          _buildSwitchTile("Можно с детьми", isKidsAllowed,
                              (v) {
                            setState(() {
                              isKidsAllowed = v;
                              if (v) is18plus = false;
                              if (isKidsAllowed) {
                                showKidsAlertDialog(context, '');
                              }
                            });
                          }),
                          const SizedBox(height: 10),
                          _buildSwitchTile("Можно с животными", isPetFriendly,
                              (v) => setState(() => isPetFriendly = v)),
                          const SizedBox(height: 10),
                          _buildSwitchTile(
                              "Количество человек неограниченно",
                              isUnlimited,
                              (v) => setState(() => isUnlimited = v)),
                          SizedBox(height: isUnlimited ? 0 : 24),
                          isUnlimited == true
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Количество человек',
                                      style: TextStyle(
                                          fontFamily: 'Inter', fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPeopleCounter(),
                                  ],
                                ),
                          SizedBox(height: isUnlimited ? 10 : 24),
                          widget.organizedEventModel == null
                              ? _buildSwitchTile(
                                  "Создать групповой чат",
                                  isGroupChat,
                                  (v) => setState(() => isGroupChat = v))
                              : Container(),
                          SizedBox(
                              height:
                                  widget.organizedEventModel != null ? 12 : 24),
                          Text(
                            'Описание',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 4,
                            onChanged: (value) =>
                                setState(() => isError = false),
                            autofocus: true,
                            controller: descriptionController,
                            keyboardType: TextInputType.multiline,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: isError
                                  ? "Обнаружены недопустимые слова"
                                  : "",
                              labelStyle: TextStyle(color: Colors.red),
                              filled: true,
                              fillColor: Colors.grey[200],
                              enabledBorder: isError
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(color: Colors.red))
                                  : OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none),
                              focusedBorder: isError
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(color: Colors.red))
                                  : OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none),
                              border: isError
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(color: Colors.red))
                                  : OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none),
                              suffixIconConstraints:
                                  BoxConstraints(minWidth: 0, minHeight: 0),
                              suffixStyle: TextStyle(color: Colors.black),
                              hintText: "Опишите ваше событие",
                              hintStyle: TextStyle(
                                  color: isError ? Colors.red : Colors.black,
                                  fontFamily: 'Gilroy',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400),
                              errorStyle: TextStyle(color: Colors.red),
                            ),
                          ),
                          // _buildTextField("Опишите ваше событие",
                          //     maxLines: 4, controller: descriptionController),
                          const SizedBox(height: 28),
                          Text(
                            'Категория:',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          _buildCategoryChips(),
                          const SizedBox(height: 28),
                        ],
                        _buildSaveButton(),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget startTimePicker() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: startSelectedHourController,
              itemExtent: 48,
              onSelectedItemChanged: (int index) {
                setState(() {
                  startSelectedHour = index;
                });
              },
              children: List<Widget>.generate(24, (index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 32, fontFamily: 'Inter'),
                  ),
                );
              }),
            ),
          ),
          Text(':',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 48,
              scrollController: startSelectedMinuteController,
              onSelectedItemChanged: (int index) {
                setState(() {
                  startSelectedMinute = index;
                });
              },
              children: List<Widget>.generate(60, (index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 32, fontFamily: 'Inter'),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget endTimePicker() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: endSelectedHourController,
              itemExtent: 48,
              onSelectedItemChanged: (int index) {
                setState(() {
                  endSelectedHour = index;
                });
              },
              children: List<Widget>.generate(24, (index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 32, fontFamily: 'Inter'),
                  ),
                );
              }),
            ),
          ),
          Text(':',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoPicker(
              scrollController: endSelectedMinuteController,
              itemExtent: 48,
              onSelectedItemChanged: (int index) {
                setState(() {
                  endSelectedMinute = index;
                });
              },
              children: List<Widget>.generate(60, (index) {
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 32, fontFamily: 'Inter'),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label,
      {int maxLines = 1,
      bool isPrice = false,
      String? suffixText,
      required TextEditingController controller}) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      inputFormatters:
          isPrice ? [FilteringTextInputFormatter.digitsOnly] : null,
      maxLines: maxLines,
      autofocus: true,
      controller: controller,
      keyboardType: isPrice ? TextInputType.number : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
        suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixText != null
            ? Padding(
                padding: EdgeInsets.only(right: 30),
                child: Text(
                  suffixText,
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                ),
              )
            : null,
        suffixStyle: TextStyle(color: Colors.black),
        hintText: label,
        hintStyle: TextStyle(
            fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w400),
        errorStyle: TextStyle(color: Colors.red),
      ),
      validator: (value) {
        if (value == "Что-то плохое тут написано, прям фу") {
          return "";
        }
        if (value == null || value.isEmpty) {
          return "Обнаружены недопустимые слова";
        }
        return null;
      },
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: Colors.blue,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          title,
          style: TextStyle(fontFamily: 'Inter', fontSize: 13),
        )
      ],
    );
  }

  Widget _buildPeopleCounter() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(25)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (peopleCount > 1) setState(() => peopleCount--);
            },
            child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 32,
                      ),
                    ),
                  ),
                )),
          ),
          Text('$peopleCount',
              style: const TextStyle(fontSize: 45, fontFamily: 'Inter')),
          GestureDetector(
            onTap: () => setState(() => peopleCount++),
            child: Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 32,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final chunks = chunkList(eventCategories, 3);

    return Center(
      child: Column(
        children: chunks.map((chunk) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                for (int i = 0; i < chunk.length; i++) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory =
                              (selectedCategory == chunk[i]) ? null : chunk[i];
                        });
                      },
                      child: _buildCategoryChip(chunk[i]),
                    ),
                  ),
                  if (i != chunk.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(EventOnboarding event) {
    final isSelected = selectedCategory == event;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF4A8EFF) : Colors.transparent,
        border: Border.all(
          color: isSelected ? Color(0xFF4A8EFF) : Color(0xFF4A8EFF),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          event.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF4A8EFF),
            fontSize: 11,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 59,
      child: ElevatedButton(
        onPressed: () async {
          if (dateController.text.isEmpty && !isRecurring) {
            showAlertOKDialog(context, null,
                isTitled: true, title: 'Выберите дату');
          } else if (titleController.text.isEmpty) {
            showAlertOKDialog(context, null,
                isTitled: true, title: 'Заполните название события');
          } else if (addressController.text.isEmpty && isOnline == false) {
            showAlertOKDialog(context, null,
                isTitled: true, title: 'Заполните адрес');
          } else if (peopleCount == 0 && isUnlimited == false) {
            showAlertOKDialog(context, null,
                isTitled: true,
                title: 'В событие должен быть минимум 1 человек');
          } else if (descriptionController.text.isEmpty) {
            showAlertOKDialog(context, null,
                isTitled: true, title: 'Заполните описание');
          } else {
            final timeStart =
                utcTime('$startSelectedHour:$startSelectedMinute');
            final timeEnd = utcTime('$endSelectedHour:$endSelectedMinute');
            final dateStart = dateController.text.isNotEmpty
                ? utcDate(dateController.text.trim())
                : null;
            final now = DateTime.now();

            if (!isRecurring) {
              // 1. Получаем дату
              final selectedDate =
                  DateFormat('dd.MM.yyyy').parse(dateController.text.trim());

// 2. Собираем DateTime из даты + времени
              final startDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                startSelectedHour,
                startSelectedMinute,
              );

              final endDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                endSelectedHour,
                endSelectedMinute,
              );
              if (startDateTime.isAfter(endDateTime) &&
                  widget.organizedEventModel?.status != 'completed' &&
                  widget.organizedEventModel?.status != 'canceled' &&
                  widget.organizedEventModel?.status != 'rejected') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Время начала должно быть раньше времени конца')),
                );
              } else if (startDateTime.isBefore(now) &&
                  widget.organizedEventModel?.status != 'completed' &&
                  widget.organizedEventModel?.status != 'canceled' &&
                  widget.organizedEventModel?.status != 'rejected') {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Дата события должна быть в будущем')),
                );
              } else if (selectedCategory != null) {
                if (_images.isEmpty) {
                  final defaultImage = await getImageFileFromAssets(
                      'assets/images/image_default_event.png');
                  _images.add(defaultImage.path);
                }
                if (isOnline) {
                  addressController.text = '';
                }
                context.read<AuthBloc>().add(widget.organizedEventModel != null
                    ? ActiUpdateActivityEvent(
                        alterEventModel:
                            eventmodel(dateStart, timeStart, timeEnd))
                    : ActiCreateActivityEvent(
                        createEventModel:
                            eventmodel(dateStart, timeStart, timeEnd)));
                setState(() {
                  isLoading = true;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Выберите категорию')));
              }
            } else {
              if (selectedCategory != null) {
                if (_images.isEmpty) {
                  final defaultImage = await getImageFileFromAssets(
                      'assets/images/image_default_event.png');
                  _images.add(defaultImage.path);
                }
                if (isOnline) {
                  addressController.text = '';
                }
                context.read<AuthBloc>().add(widget.organizedEventModel != null
                    ? ActiUpdateActivityEvent(
                        alterEventModel:
                            eventmodel(dateStart, timeStart, timeEnd))
                    : ActiCreateActivityEvent(
                        createEventModel:
                            eventmodel(dateStart, timeStart, timeEnd)));
                setState(() {
                  isLoading = true;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Выберите категорию')));
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(98, 207, 102, 1),
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Text("Сохранить",
            style: TextStyle(
                fontSize: 16.46, fontFamily: 'Gilroy', color: Colors.white)),
      ),
    );
  }

  AlterEventModel eventmodel(
      String? dateStart, String timeStart, String timeEnd) {
    return AlterEventModel(
        selectedAddressModel: selectedAddressModel,
        isOnline: isOnline,
        isKidsAllowed: isKidsAllowed,
        recurringDay: getNextDateForWeekday(recurringDay),
        deletedImages: deletedImages,
        id: widget.organizedEventModel?.id,
        isGroupChat: isGroupChat,
        isUnlimited: isUnlimited,
        is18plus: is18plus,
        withAnimals: isPetFriendly,
        price: priceController.text.trim() != ''
            ? double.parse(priceController.text.trim())
            : null,
        slots: peopleCount,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        type: isOnline ? 'online' : 'offline',
        address: addressController.text.trim(),
        dateStart: dateStart,
        timeStart: timeStart,
        timeEnd: timeEnd,
        isRecurring: isRecurring,
        categoryId: selectedCategory!.id,
        updateRecurring: false,
        images: _images);
  }

  Widget _buildImage(String imagePath, double width, double height) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath.contains('http://93.183.81.104')
                ? Image.network(
                    imagePath,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(imagePath),
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _removeImage(imagePath),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallAddButton() {
    return Expanded(
      child: GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 118,
            width: 128,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(width: 0.4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/images/take_photo.svg'),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Добавить',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400),
                )
              ],
            ),
          )),
    );
  }

  Widget _buildLargeAddButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: SvgPicture.asset(
        'assets/icons/icon_add_photo_activity.svg',
      ),
    );
  }
}
