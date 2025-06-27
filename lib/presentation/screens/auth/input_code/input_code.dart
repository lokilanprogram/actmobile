import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/widgets/loader_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import 'package:url_launcher/url_launcher.dart';

class InputCodeScreen extends StatefulWidget {
  final String phone;
  const InputCodeScreen({super.key, required this.phone});

  @override
  State<InputCodeScreen> createState() => _InputCodeScreenState();
}

class _InputCodeScreenState extends State<InputCodeScreen> {
  late TextEditingController codeController;
  bool isLoading = false;

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'actimobapp@gmail.com',
        query: 'subject=Проблема с регистрацией&body=Опишите вашу проблему...');
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось открыть почтовый клиент')),
      );
    }
  }

  @override
  void initState() {
    setState(() {
      codeController = TextEditingController();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ActiVerifiedState) {
          setState(() {
            isLoading = false;
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InitialScreen()));
        }
        if (state is ActiVerifiedErrorState) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Ошибка')));
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: isLoading
            ? LoaderWidget()
            : GestureDetector(
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
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 120, left: 45, right: 45),
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.topCenter,
                              child: SvgPicture.asset(
                                  'assets/icons/icon_acti.svg')),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            'На ваш номер телефона поступит звонок',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Gilroy',
                                color: authBlueColor,
                                fontSize: 18),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Введите последние 4 цифры номера\n(можете не принимать звонок)',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontFamily: 'Gilroy', fontSize: 13),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Pinput(
                            length: 4,
                            defaultPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromRGBO(30, 60, 87, 1),
                                  fontWeight: FontWeight.w600),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Color.fromRGBO(234, 239, 243, 1)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            controller: codeController,
                            onCompleted: (pin) => print(pin),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                      text:
                                          'Если возникли проблемы с регистрацией, обратитесь в'),
                                  TextSpan(
                                    text: '\nслужбу поддержки',
                                    style: TextStyle(
                                        color: mainBlueColor,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        _launchEmail();
                                      },
                                  ),
                                ]),
                          ),
                          // SvgPicture.asset('assets/texts/text_support.svg'),
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                              });
                              context.read<AuthBloc>().add(ActiVerifyEvent(
                                  phone: widget.phone,
                                  code: codeController.text.trim()));
                            },
                            child: Container(
                              height: 59,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: mainBlueColor),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 14),
                                child: Center(
                                    child: Text(
                                  'Войти',
                                  style: TextStyle(
                                      color: Colors.white, fontFamily: 'Inter'),
                                )),
                              ),
                            ),
                          ),
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
