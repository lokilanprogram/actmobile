import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/maps/event/widgets/popup_event_buttons.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
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
            Stack(
              children: [
                // Фото
                Image.network(
                  'http://93.183.81.104${eventModel.photos!.first}',
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.cover,
                ),
                Positioned(
                    top: 50,
                    right: 20,
                    child: PopUpEventButtons(function: () async {})),

                // Индикаторы
                Positioned(
                  bottom: 10,
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
            Expanded(
              child: Container(
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
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                              IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: SvgPicture.asset('assets/icons/icon_back_blue.svg')),
                          SizedBox(
                            width: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildTag('Бесплатное'),
                              const SizedBox(width: 8),
                              buildTag('Компания'),
                              const SizedBox(width: 36),
                              SvgPicture.asset(
                                'assets/icons/icon_adult.svg',
                                width: 34,
                              )
                            ],
                          ),
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
                          const Spacer(),
                          Image.asset(
                              'assets/images/image_group_people_large.png')
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Divider(),
                      ),
                      // Заголовок
                       Text(
                        eventModel.title ,
                        style: TextStyle(
                          fontSize: 23,
                          fontFamily: 'Gilroy',
                          height: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Дата и время
                      infoRow(
                        'assets/icons/icon_time.svg',
                        false,
                        'Дата и время',
                        '${DateFormat('dd.MM.yyyy').format(eventModel.dateStart)} | ${eventModel.timeStart.substring(0,5)} – ${eventModel.timeEnd.substring(0,5)}',
                        trailing: '40 мин',
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Divider(),
                      ),

                      // Место
                      infoRow(
                        'assets/icons/icon_location.svg',
                        true,
                        'Место',
                        eventModel.address,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Divider(),
                      ),

                      // Места
                      infoRow(
                        'assets/icons/icon_people.svg',
                        false,
                        'Свободно 5 из 10 мест',
                        '',
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Divider(),
                      ),
                      // Описание
                       Text(
                        eventModel.description,
                        style: TextStyle(
                            fontSize: 16, fontFamily: 'Gilroy', height: 1),
                      ),

                      const SizedBox(height: 40),

                      // Кнопка
                      SizedBox(
                        height: 59,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Color.fromRGBO(98, 207, 102, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Пойду',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.46,
                                fontFamily: 'Gilroy'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
