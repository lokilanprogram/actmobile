import 'dart:io';

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/function.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class ReportEventSheetWidget extends StatefulWidget {
  final String eventId;
  const ReportEventSheetWidget({
    super.key,required this.eventId
  });

  @override
  State<ReportEventSheetWidget> createState() => _ReportEventSheetWidgetState();
}

class _ReportEventSheetWidgetState extends State<ReportEventSheetWidget> {
  bool isSpecific = false;
  bool removeReasons = false;
  bool isLoading = false;
  bool isUpdatedPhoto = false;
  XFile? image;
  int? selectedIndex;
  final commentController = TextEditingController();
  List<Map<String,String>> complaints = [];
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.3,
      maxChildSize: 1,
      builder: (_, controller) {
        return BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if(state is ProfileReportedEventState){
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context);
                    showAlertOKDialog(context, 'Ваша жалоба отправлена. Спасибо, что помогаете нам становиться лучше.');

                  }

                    if(state is ProfileReportedEventErrorState){
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorText)));
                  }
                },
                child:isLoading
            ? LoaderWidget()
            :  Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: isSpecific
                      ? SingleChildScrollView(
                          child: scrollableBlockSheet(controller, context),
                        )
                      : scrollableBlockSheet(controller, context),
                ),
              );
      },
    );
  }

  Widget scrollableBlockSheet(
      ScrollController controller, BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Indicator
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),

        // Title
        Text(
          isSpecific
              ? 'На что вы хотите пожаловаться?'
              : 'Что именно вам кажется\nнедопустимым в этом мероприятии?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),

        // List
        isSpecific
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  removeReasons
                      ? Container()
                      : Column(
                          children:
                              complaints.asMap().entries.map((entry) {
                            final index = entry.key;
                            final complaint = entry.value;

                            return ListTile(
                              leading: Transform.scale(
                                scale: 1.5,
                                child: Checkbox(
                                  activeColor: mainBlueColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  value: selectedIndex == index,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedIndex = index;
                                    });
                                  },
                                ),
                              ),
                              title: Text(
                                complaint['title']!,
                                style: const TextStyle(
                                    fontFamily: 'Inter', fontSize: 18),
                              ),
                              subtitle: complaint['subtitle'] != null &&
                                      complaint['subtitle']!.isNotEmpty
                                  ? Text(
                                      complaint['subtitle']!,
                                      style: const TextStyle(
                                          fontFamily: 'Inter', fontSize: 12),
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                  SizedBox(
                    height: removeReasons ? 15 : 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Комментарий (необязательно)',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                        ),
                        TextFormField(
                          controller: commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Опишите причину жалобы',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                       isUpdatedPhoto ? Stack(
                         children: [
                           ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                             child: Center(
                               child: Image.file(
                                File(image!.path),
                                height: 250,
                               ),
                             ),
                           ),
                           Positioned(
                            right: 60,
                            top: -10,
                            child: IconButton(onPressed: (){
                            setState(() {
                              isUpdatedPhoto = false;
                              image = null;
                            });
                           }, icon: Icon(Icons.close,color: Colors.red,)))
                         ],
                       ): InkWell(
                          onTap: ()async{
                              final xfile = await ImagePicker()
                                            .pickImage(
                                                source: ImageSource.gallery);
                                        if (xfile != null) {
                                          setState(() {
                                            image = xfile;
                                            isUpdatedPhoto = true;
                                          });
                                        } 
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(25)),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                      'assets/icons/icon_add_block_photo.svg'),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Прикрепите медиафайл',
                                    style: TextStyle(
                                        fontFamily: 'Gilroy', fontSize: 18),
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              )
            : Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    buildOption('Спам', context, () {
                      setState(() {
                        isSpecific = true;
                        complaints = complainSpam;
                      });
                    }),
                    buildOption('Обман', context, () {
                       setState(() {
                        isSpecific = true;
                        complaints = complainLie;
                      });
                    }),
                    buildOption('Насилие и вражда', context, () { setState(() {
                        isSpecific = true;
                        complaints = complainViolence;
                      });}),
                    buildOption('Продажа запрещённых товаров', context, () { setState(() {
                        isSpecific = true;
                        complaints = complainItems;
                      });}),
                    buildOption('Подозрительная активность', context, () { setState(() {
                        isSpecific = true;
                        complaints = complainSuspect;
                      });}),
                    buildOption('Откровенное изображение', context, () { setState(() {
                        isSpecific = true;
                        complaints = complainPhoto;
                      });}),
                    buildOption('Другое', context, () {
                      setState(() {
                        isSpecific = true;
                        removeReasons = true;
                      });
                    }),
                  ],
                ),
              ),
        SizedBox(
          height: removeReasons ? 200 : 45,
        ),
        TextButton(
          onPressed: () {
            // Навигация к правилам
          },
          child: Text.rich(
            TextSpan(
              text: 'Узнайте больше ',
              style: TextStyle(
                  color: Colors.blue, fontFamily: 'Inter', fontSize: 13),
              children: [
                TextSpan(
                  text: 'о правилах Acti',
                  style: TextStyle(
                      color: Colors.black, fontFamily: 'Inter', fontSize: 13),
                )
              ],
            ),
          ),
        ),
       isSpecific ? SizedBox(
          height: 59,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading =true;
              });
              context.read<ProfileBloc>().add(ProfileReportEvent(imageUrl:image?.path, eventId: widget.eventId, 
              title:selectedIndex!= null? complaints[selectedIndex!]['title']!: 'Другое', comment: commentController.text.trim()));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Отправить жалобу',
              style: TextStyle(
                  color: Colors.white, fontSize: 16.46, fontFamily: 'Gilroy'),
            ),
          ),
        ):Container(),
        SizedBox(
          height: 40,
        ),
      ],
    );
  }
}
