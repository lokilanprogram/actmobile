import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/popup_event_buttons.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class EventDetailHomeScreen extends StatefulWidget {
  final String eventId;
  const EventDetailHomeScreen({super.key, required this.eventId});

  @override
  State<EventDetailHomeScreen> createState() => _EventDetailHomeScreenState();
}

class _EventDetailHomeScreenState extends State<EventDetailHomeScreen> {
  bool isLoading = false;
  late EventModel eventModel;
  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    setState(() {
      isLoading = true;
    });
    context
        .read<ProfileBloc>()
        .add(ProfileGetEventDetailEvent(eventId: widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if(state is ProfileGotEventDetailState){
          setState(() {
            isLoading = false;
            eventModel = state.eventModel;
          });
        }

        if(state is ProfileGotEventDetailErrorState){
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body:isLoading ? LoaderWidget(): Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(height: MediaQuery.of(context).size.height, decoration: BoxDecoration(color: Colors.white),),
                    Stack(
                      children: [
                        // Фото
                        Image.network(
                          'http://93.183.81.104${eventModel.photos!.first}',
                          width: double.infinity,
                          height:200,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                            top: 50,
                            right: 20,
                            child: PopUpEventButtons(function: () async {})),
                
                        // Индикаторы
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 180,
                      child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        icon: SvgPicture.asset('assets/icons/icon_back_blue.svg')),
                                    SizedBox(
                                      width: 15,
                                    ),
                                   eventModel.price == 0 ?  buildTag('Бесплатное') 
                                   :Container(),
                                   Spacer(),
                                   Padding(
                                     padding: const EdgeInsets.only(right: 30),
                                     child: SvgPicture.asset('assets/icons/icon_adult.svg',width: 34,),
                                   )
                                  ],
                                ),
                      
                                const SizedBox(height: 15),
                      
                                // Автор и участники
                                Row(
                                  children: [
                                     CircleAvatar(
                                      radius: 20,
                                      backgroundImage:  NetworkImage(
                                        '${eventModel.creator.photoUrl}'), // Заменить на нужную
                                    ),
                                    const SizedBox(width: 10),
                                     Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(eventModel.creator.name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17.8,
                                                fontFamily: 'Inter',
                                                color: mainBlueColor)),
                                        Text('Организатор',
                                            style: TextStyle(
                                                fontSize: 16, fontFamily: 'Gilroy')),
                                           
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15,),
                      Center(
                        child: Material(color: Colors.white,
                          elevation: 1.2,
                          borderRadius: BorderRadius.circular(25),
                          child: SizedBox(height: 59,
                                             width: MediaQuery.of(context).size.height * 0.4,
                                             child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                Text('Заявки',style: TextStyle(color: mainBlueColor,
                                                fontFamily: 'Inter',fontSize: 22, fontWeight: FontWeight.bold),),
                                                SvgPicture.asset('assets/icons/icon_next_blue.svg')
                                               ],),
                                             ),
                        ),
                      ),    
                      SizedBox(height: 30,),
                                 Text(
                                  'Обзор',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Gilroy',
                                    height: 1,color: mainBlueColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                      
                                const SizedBox(height: 20),
                      
                                // Дата и время
                                infoRow(
                                  'assets/icons/icon_time.svg',
                                  false,
                                  'Дата и время',
                                  '${DateFormat('dd.MM.yyyy').format(eventModel.dateStart)} | ${eventModel.timeStart.substring(0,5)} – ${eventModel.timeEnd.substring(0,5)}',
                                  trailing: '40 мин',
                                ),
                                 const SizedBox(height: 20),
                      
                                // Место
                                infoRow(
                                  'assets/icons/icon_location.svg',
                                  true,
                                  'Место',
                                  eventModel.address,
                                ),
                      
                                const SizedBox(height: 20),
                      
                                // Места
                                infoRow(
                                  'assets/icons/icon_people.svg',
                                  false,
                                  'Свободно 5 из 10 мест',
                                  '',
                                ),
                      
                                 const SizedBox(height: 20),
                                // Описание
                                 Text(
                                  eventModel.description,
                                  style: TextStyle(
                                      fontSize: 16, fontFamily: 'Gilroy', height: 1),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 60,left: 30,right: 30 ),
              child: buildCancelWidget(),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox buildCancelWidget() {
    return SizedBox(height: 59,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Отменить мероприятие',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.46,
                                  fontFamily: 'Gilroy'),
                            ),
                          ),
                        );
  }

  Widget buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 12.46, fontFamily: 'Gilroy'),
      ),
    );
  }

  Widget infoRow(
      String iconPath, bool isLocation, String title, String subtitle,
      {String? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: SvgPicture.asset(iconPath),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Inter',
                    fontSize: 17.8)),
            if (subtitle.isNotEmpty)
              Row(
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 16,
                        color: isLocation ? Colors.blue : Colors.black),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  if (trailing != null)
                    Text(trailing, style: const TextStyle(color: Colors.grey)),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
