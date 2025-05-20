import 'dart:io';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/data/models/create_event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/domain/bloc/acti_bloc.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
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

  const CreateEventScreen({super.key,required this.organizedEventModel});
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  bool isOnline = false;
  bool isRecurring = false;
  bool is18plus = false;
  bool isPetFriendly = false;
  bool isUnlimited = false;
  bool isGroupChat = false;
  bool isLoading = true;
  int peopleCount = 10;
  int startSelectedHour = 18;
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

  final _formKey = GlobalKey<FormState>();
  late List<EventOnboarding> eventCategories; 
  final dateFormatter = MaskTextInputFormatter(
  mask: '##.##.####',
  filter: {"#": RegExp(r'[0-9]')},
);
  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2026),
    );

    setState(() {
      selectedDate = pickedDate;
      dateController.text = formatDate('${pickedDate!.day}.${pickedDate!.month}.${pickedDate!.year}');
    });
  }

    final List<XFile> _images = [];
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _images.add(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }


  @override
  void initState() {
    initialize();
    super.initState();
  }
  initialize()async{
     setState(() {
      isLoading = true;
    });
    context.read<ActiBloc>().add(ActiGetOnbordingEvent());
    final event = widget.organizedEventModel;
 
    if(event!=null){
  // Преобразуем строку в DateTime
DateTime startParsedTime = DateFormat("HH:mm:ss").parse(event.timeStart);
DateTime endParsedTime = DateFormat("HH:mm:ss").parse(event.timeEnd);

// Получаем часы и минуты
int startHourIndex = startParsedTime.hour;
int startMinuteIndex = startParsedTime.minute;
int endHourIndex = endParsedTime.hour;
int endMinuteIndex = endParsedTime.minute;
        for(var photo in event.photos){
         final xFileNet = await getImageXFileByUrl('http://93.183.81.104$photo');
         _images.add(xFileNet);
        }
      setState(() {
        titleController.text = event.title;
        descriptionController.text = event.description;
        isRecurring = event.isRecurring;
        isOnline = event.type == 'online'?true:false;
        addressController.text = event.address;
        dateController.text = DateFormat('dd.MM.yyyy').format(event.dateStart);
        priceController.text =event.price!= 0?  event.price.toString():'';
        peopleCount = event.slots;
        startSelectedHourController = FixedExtentScrollController(initialItem: startHourIndex);
        startSelectedMinuteController = FixedExtentScrollController(initialItem:startMinuteIndex);
        endSelectedHourController = FixedExtentScrollController(initialItem: endHourIndex);
        endSelectedMinuteController = FixedExtentScrollController(initialItem: endMinuteIndex);
      });
    }else{
setState(() {
        startSelectedHourController = FixedExtentScrollController(initialItem: startSelectedHour);
        startSelectedMinuteController = FixedExtentScrollController(initialItem: startSelectedMinute);
        endSelectedHourController = FixedExtentScrollController(initialItem: endSelectedHour);
        endSelectedMinuteController = FixedExtentScrollController(initialItem: endSelectedMinute);
  
});
    }
  }

 
 @override
  Widget build(BuildContext context) {
       List<Widget> bottomGrid = [];
    if (_images.length > 1) {
      for (int i = 1; i < _images.length; i++) {
        bottomGrid.add(_buildImage(_images[i], i, 80, 80));
      }
    }
    return BlocListener<ActiBloc, ActiState>(
      listener: (context, state) {
        if(state is ActiCreatedActivityState){
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
          showAlertOKDialog(context, 'Ваше событие отредактировано и отправлено на проверку. Будет опубликовано после модерации.', isTitled: true, title: 'Событие на проверке!');
        }
        if(state is ActiCreatedActivityErrorState){
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка')));
        }
        if(state is ActiGotOnbordingState){
          setState(() {
           isLoading = false;
            eventCategories = state.listOnbordingModel.categories;
          });
        }
          if(state is ActiGotOnbordingErrorState){
          setState(() {
           isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWidget(title: "Создание активности"),
        body:isLoading?LoaderWidget(): SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(key: _formKey,
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
                _buildImage(_images[0], 0,MediaQuery.of(context).size.height * 0.24, 118),
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
                Text(
                  'Название события',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildTextField((val){
                  if(val!.isEmpty){
                    return 'Заполните название';
                  }
                  return null;
                },"Введите название вашего события",controller: titleController),
                const SizedBox(height: 20),
                _buildSwitchTile("Событие ОНЛАЙН", isOnline,
                    (v) => setState(() => isOnline = v)),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          
                            validator: (val){
                              if(val!.isEmpty){
                                return 'Заполните адрес';
                              }
                            },
                            maxLines: 1,controller: addressController,
                            decoration: InputDecoration(
                              fillColor: Colors.grey[200],
                              filled: true,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none),
                                hintText: 'Адрес',
                                hintStyle: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400)),
                          ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: 49,
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 15),
                          child: SvgPicture.asset('assets/icons/icon_map.svg'),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildSwitchTile("Повторяющееся событие", isRecurring,
                    (v) => setState(() => isRecurring = v)),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
  maxLines: 1,
  controller: dateController,
  inputFormatters: [dateFormatter],
  validator: (val) {
    if (val!.isEmpty) {
      return 'Заполните адрес';
    }
    return null;
  },
  decoration: InputDecoration(
    hintText: 'Дата',
    hintStyle: TextStyle(
      fontFamily: 'Gilroy',
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.grey[200],
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide.none,
    ),
  ),
)
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          selectDate();
                        },
                        child: Container(
                          width: 49,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 15),
                            child: SvgPicture.asset(
                                'assets/icons/icon_calendar_activity.svg'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
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
                _buildTextField((val){
                  if(val!.isEmpty){
                    return 'Заполните цену';
                  }
                  return null;
                },"Введите цену",isPrice: true, suffixText: "₽",controller: priceController),
                const SizedBox(height: 24),
                _buildSwitchTile("Ограничение 18+", is18plus,
                    (v) => setState(() => is18plus = v)),
                const SizedBox(height: 10),
                _buildSwitchTile("Можно с животными", isPetFriendly,
                    (v) => setState(() => isPetFriendly = v)),
                const SizedBox(height: 10),
                _buildSwitchTile("Количество человек неограниченно", isUnlimited,
                    (v) => setState(() => isUnlimited = v)),
                const SizedBox(height: 24),
                 Text(
                  'Количество человек',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildPeopleCounter(),
                const SizedBox(height: 24),
                _buildSwitchTile("Создать групповой чат", isGroupChat,
                    (v) => setState(() => isGroupChat = v)),
                const SizedBox(height: 24),
                 Text(
                  'Описание',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildTextField((val){
                  if(val!.isEmpty){
                    return 'Заполните описание';
                  }
                  return null;
                },"Опишите ваше событие", maxLines: 4,controller: descriptionController),
                const SizedBox(height: 28),
                   Text(
                  'Категория:',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
                const SizedBox(height: 8),
                _buildCategoryChips(),
                const SizedBox(height: 28),
                _buildSaveButton(),
                const SizedBox(height: 28),
              ],
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

  Widget _buildTextField(
  final String? Function(String?)? validator, String label, {int maxLines = 1,bool isPrice = false, String? suffixText,required TextEditingController controller}) {
    return TextFormField(
          inputFormatters:isPrice? [FilteringTextInputFormatter.digitsOnly]:null,
          maxLines: maxLines,controller: controller,
          keyboardType: isPrice? TextInputType.number:null,
          validator: validator,
          decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none),
              suffixIcon: suffixText != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: Text(
                        suffixText,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                      ),
                    )
                  : null,
              suffixStyle: TextStyle(color: Colors.black),
              hintText: label, 
              hintStyle: TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  fontWeight: FontWeight.w400)),
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
      decoration: BoxDecoration(color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: ()=>setState(() => peopleCount--),
            child: Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child:Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Icon(Icons.arrow_back_ios,size: 32,),
                      ),),
                    )),
          ),
          Text('$peopleCount', style: const TextStyle(fontSize: 45, fontFamily: 'Inter')),
           GestureDetector(
            onTap: ()=>setState(() => peopleCount++),
            child: Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child:  Icon(Icons.arrow_forward_ios,size: 32,),),
                    )),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return  Center(
                                child: Wrap(alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: eventCategories
                                      .map((event) => GestureDetector(
                                        onTap: (){
                                          setState(() {
                                          selectedCategory = (selectedCategory == event) ? null : event;

                                          });
                                        },
                                        child: _buildCategoryChip(event)))
                                      .toList(),
                                ),
                              );
  }
 Widget _buildCategoryChip(EventOnboarding event) {
    final isSelected = selectedCategory == event;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF4A8EFF) : Colors.transparent,
        border: Border.all(
          color: isSelected ? Color(0xFF4A8EFF) : Color(0xFF4A8EFF),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        event.name,
        style: TextStyle(
          color: isSelected ? Colors.white : Color(0xFF4A8EFF),
          fontSize: 11,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

    Widget _buildSaveButton() {
    return SizedBox(height: 59,
      child: ElevatedButton(
        onPressed: () {
          if(_formKey.currentState!.validate()){
            _formKey.currentState!.save();
        final timeStart = utcTime('$startSelectedHour:$startSelectedMinute');
        final timeEnd = utcTime('$endSelectedHour:$endSelectedMinute');
        final dateStart = utcDate(dateController.text.trim());
        final now = DateTime.now();

// 1. Получаем дату
final selectedDate = DateFormat('dd.MM.yyyy').parse(dateController.text.trim());

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

// 3. Проверки
if (startDateTime.isAfter(endDateTime)) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Время начала должно быть раньше времени конца')),
  );
} else if (selectedDate.isBefore(now)) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Дата события должна быть в будущем')),
  );
} else if (_images.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Выберите фотографию')),
  );
} else if(selectedCategory != null){
            setState(() {
            isLoading = true;
          });
          context.read<ActiBloc>().add(ActiCreateActivityEvent(
            createEventModel: CreateEventModel(
              isGroupChat: isGroupChat,
              isUnlimited: isUnlimited,
              is18plus: is18plus,
              withAnimals: isPetFriendly,
              price:double.parse( priceController.text.trim()),
              slots: peopleCount,
              title:
             titleController.text.trim(), description: descriptionController.text.trim(), type: isOnline?'online':'offline',
              address: addressController.text.trim(), dateStart: dateStart, timeStart:
               timeStart, timeEnd: timeEnd, isRecurring: isRecurring, 
               categoryId: selectedCategory!.id, updateRecurring: false,
               photos:_images )
          ));
          }else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите категорию')));
          }
          }
  
           
          

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromRGBO(98, 207, 102,1),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child:  Text("Сохранить", style: TextStyle(fontSize: 16.46,fontFamily: 'Gilroy',
        color: Colors.white)),
      ),
    );
  }

   Widget _buildImage(XFile image, int index, double width,double height) {
    return Padding(
      padding: const EdgeInsets.only(left: 3),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(image.path),
              width: width,
              height: height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(width: 20,
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
          height: 118,width: 128,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(width: 0.4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/take_photo.svg'),
              SizedBox(height: 10,),
              Text('Добавить',style: TextStyle(fontFamily: 'Inter',fontSize: 15,fontWeight: FontWeight.w400),)
            ],
          ),
        )
      ),
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


