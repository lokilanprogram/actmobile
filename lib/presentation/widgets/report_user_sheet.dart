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

class ReportUserSheetWidget extends StatefulWidget {
  final String userId;
  const ReportUserSheetWidget({
    super.key,required this.userId
  });

  @override
  State<ReportUserSheetWidget> createState() => _ReportUserSheetWidgetState();
}

class _ReportUserSheetWidgetState extends State<ReportUserSheetWidget> {
  bool isLoading = false;
  bool isUpdatedPhoto = false;
  XFile? image;
  final commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize:isUpdatedPhoto ? 0.9: 0.7,
      minChildSize: 0.3,
      maxChildSize: 1,
      builder: (_, controller) {
        return BlocListener<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if(state is ProfileReportedUserState){
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context);
                    showAlertOKDialog(context, 'Ваша жалоба отправлена. Спасибо, что помогаете нам становиться лучше.');

                  }

                    if(state is ProfileReportedUserErrorState){
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
                  child: scrollableBlockSheet(controller, context),
                ),
              );
      },
    );
  }

  Widget scrollableBlockSheet(
      ScrollController controller, BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // скрыть клавиатуру
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
          
              // Title
              Center(
                child: Text(
                  'На что вы хотите пожаловаться?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Gilroy',
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
          Text(
                                'Комментарий',
                                style: TextStyle(fontFamily: 'Gilroy', fontSize: 15,color: Colors.black),
                              ),
              const SizedBox(height: 5),
                              TextFormField(
                                controller: commentController,
                                maxLines: 7,
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
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                              ),
             
             
             
              SizedBox(
                height: 40,
              ),
            ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Material(
                      elevation: 1.2,
                      borderRadius: BorderRadius.circular(30),
                       child: SizedBox(
                          height: 59,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading =true;
                              });
                              context.read<ProfileBloc>().add(ProfileReportUser(imageUrl: image?.path, userId: widget.userId, title: commentController.text.trim()));
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Color.fromRGBO(223, 223, 223,1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Отправить жалобу',
                              style: TextStyle(
                                  color: Color.fromRGBO(35, 31, 32,1), fontSize: 16.46, fontFamily: 'Gilroy'),
                            ),
                          ),
                        ),
                     ),
              ),
            ),
        ],
      ),
    );
  }
}
