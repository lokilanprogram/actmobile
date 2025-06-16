import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/auth/input_loading/input_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:pinput/pinput.dart';

class InputPhoneScreen extends StatefulWidget {
  const InputPhoneScreen({super.key});

  @override
  State<InputPhoneScreen> createState() => _InputPhoneScreenState();
}

class _InputPhoneScreenState extends State<InputPhoneScreen> {
  final phoneController = TextEditingController();
  int phoneLentgh = 0;
  final _formKey = GlobalKey<FormState>();
  final phoneFormatter = MaskTextInputFormatter(
    mask: '+7 ###-###-##-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    phoneController.text = '+7';
    phoneLentgh = phoneFormatter.getUnmaskedText().length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
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
                  // Padding(
                  //   padding:
                  //       const EdgeInsets.only(top: 40, left: 25, right: 45),
                  //   child: IconButton(
                  //       onPressed: () {
                  //         Navigator.pop(context);
                  //       },
                  //       color: Colors.white,
                  //       icon: Icon(
                  //         Icons.arrow_back_ios,
                  //       )),
                  // ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 120, left: 45, right: 45),
                    child: Column(
                      children: [
                        Align(
                            alignment: Alignment.topCenter,
                            child:
                                SvgPicture.asset('assets/icons/icon_acti.svg')),
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
                        TextFormField(
                          controller: phoneController,
                          validator: (val) {
                            final unmaskedText =
                                phoneFormatter.getUnmaskedText();
                            if (unmaskedText.isEmpty) {
                              return 'Заполните номер телефона';
                            } else if (unmaskedText.length < 10) {
                              return 'Неполный номер телефона';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            if (!val.startsWith('+7')) {
                              phoneController.text = '+7';
                              phoneController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: phoneController.text.length));
                            }
                            setState(() {
                              phoneLentgh =
                                  phoneFormatter.getUnmaskedText().length;
                            });
                          },
                          keyboardType: TextInputType.phone,
                          inputFormatters: [phoneFormatter],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromRGBO(236, 236, 236, 1),
                            hintText: 'Телефон',
                            hintStyle: TextStyle(
                                fontFamily: 'Gilroy', color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: mainBlueColor,
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.white)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.white)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 59,
                                width: 140,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: Colors.white,
                                    border: Border.all(color: mainBlueColor)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 14),
                                  child: Center(
                                      child: Text(
                                    'Назад',
                                    style: TextStyle(
                                        color: mainBlueColor,
                                        fontFamily: 'Inter'),
                                  )),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              InputLoadingScreen(
                                                  phone: phoneController.text
                                                      .trim())));
                                }
                              },
                              child: Container(
                                height: 59,
                                width: 140,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: mainBlueColor),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 14),
                                  child: Center(
                                      child: Text(
                                    'Далее',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Inter'),
                                  )),
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
              ),
            )),
      ),
    );
  }
}
