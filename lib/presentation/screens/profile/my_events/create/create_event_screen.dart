import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/domain/bloc/acti_bloc.dart';
import 'package:acti_mobile/presentation/widgets/app_bar_widget.dart';
import 'package:acti_mobile/presentation/widgets/build_interest_chip.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:acti_mobile/presentation/widgets/photo_picker_activity.dart';
import 'package:acti_mobile/presentation/widgets/time_picker_cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../data/models/list_onbording_model.dart';

class CreateEventScreen extends StatefulWidget {
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
  int selectedHour = 18;
  int selectedMinute = 0;
  EventOnboarding? selectedCategory;
  DateTime? selectedDate;

  late List<EventOnboarding> eventCategories; 

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2021, 7, 25),
      firstDate: DateTime(2021),
      lastDate: DateTime(2022),
    );

    setState(() {
      selectedDate = pickedDate;
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiBloc, ActiState>(
      listener: (context, state) {
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
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWidget(title: "Создание активности"),
        body:isLoading?LoaderWidget(): SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoPickerWidget(),
              const SizedBox(height: 16),
              Text(
                'Название события',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13),
              ),
              const SizedBox(height: 8),
              _buildTextField("Введите название вашего события"),
              const SizedBox(height: 20),
              _buildSwitchTile("Событие ОНЛАЙН", isOnline,
                  (v) => setState(() => isOnline = v)),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          maxLines: 1,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none),
                              hintText: 'Адрес',
                              hintStyle: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400)),
                        ),
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
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10)),
                        child: TextFormField(
                          maxLines: 1,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none),
                              hintText: 'Дата',
                              hintStyle: TextStyle(
                                  fontFamily: 'Gilroy',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ),
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
              _buildTextField("Введите цену", suffixText: "₽"),
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
              _buildTextField("Опишите ваше событие", maxLines: 4),
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
              itemExtent: 48,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedHour = index;
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
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedMinute = index;
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
              itemExtent: 48,
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedHour = index;
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
              onSelectedItemChanged: (int index) {
                setState(() {
                  selectedMinute = index;
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

  Widget _buildTextField(String label, {int maxLines = 1, String? suffixText}) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
        child: TextFormField(
          maxLines: maxLines,
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
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
        ),
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
                      child: Center(child:Icon(Icons.arrow_back_ios,size: 32,),),
                    )),
          ),
          Text('$peopleCount', style: const TextStyle(fontSize: 45, fontFamily: 'Inter')),
           GestureDetector(
            onTap: ()=>setState(() => peopleCount--),
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
}
  Widget _buildSaveButton() {
    return SizedBox(height: 59,
      child: ElevatedButton(
        onPressed: () {},
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

