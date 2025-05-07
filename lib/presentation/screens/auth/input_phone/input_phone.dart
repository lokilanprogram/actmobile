import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/domain/bloc/acti_bloc.dart';
import 'package:acti_mobile/presentation/screens/auth/input_code/input_code.dart';
import 'package:acti_mobile/presentation/screens/auth/input_loading/input_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InputPhoneScreen extends StatefulWidget {
  const InputPhoneScreen({super.key});

  @override
  State<InputPhoneScreen> createState() => _InputPhoneScreenState();
}

class _InputPhoneScreenState extends State<InputPhoneScreen> {
  final phoneController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiBloc, ActiState>(
      listener: (context, state) {
        if(state is ActiRegisteredState){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> InputCodeScreen(authCodes: state.authCodes,)));
        }
        if(state is ActiRegisteredErrorState){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body:GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
              child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/images/image_background.png",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120, left: 45, right: 45),
                child: Column(
                  children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: SvgPicture.asset('assets/icons/icon_acti.svg')),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Введите ваш номер\nдля входа',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Gilroy',
                          color: authBlueColor,
                          fontSize: 27),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Вы получите Push-уведомление, которое\nнеобходимо принять',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Gilroy', fontSize: 13),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(236, 236, 236, 1),
                          borderRadius: BorderRadius.circular(25)),
                      child: TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          hintText: 'Телефон',
                          hintStyle: TextStyle(
                              fontFamily: 'Gilroy', color: Colors.grey),
                          prefixIcon: Icon(
                            Icons.phone,
                            color: mainBlueColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                             Navigator.push(context, MaterialPageRoute(builder: (_)=> InputLoadingScreen(phone: phoneController.text.trim())));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: mainBlueColor),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 14),
                              child: Text(
                                'Мне 18 лет',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Inter'),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: (){
                             Navigator.push(context, MaterialPageRoute(builder: (_)=> InputLoadingScreen(phone: phoneController.text.trim())));},
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: mainBlueColor),
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 14,
                              ),
                              child: Text(
                                'Мне 18 лет',
                                style: TextStyle(
                                    color: mainBlueColor, fontFamily: 'Inter'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SvgPicture.asset('assets/texts/text_term.svg'),
                  ],
                ),
              )
            ],
          )),
        ),
      ),
    );
  }
}
