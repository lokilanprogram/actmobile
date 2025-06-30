import 'dart:async';

import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/auth/input_code/input_code.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/widgets/rotating_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toastification/toastification.dart';

class InputLoadingScreen extends StatefulWidget {
  final String phone;
  const InputLoadingScreen({super.key, required this.phone});

  @override
  State<InputLoadingScreen> createState() => _InputLoadingScreenState();
}

class _InputLoadingScreenState extends State<InputLoadingScreen> {
  final codeController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 30;
  String? normalizedPhone;
  String? authReqId;
  bool _resend = false;

  @override
  void initState() {
    initialize();
    super.initState();
  }

  initialize() {
    startTimer();
    context.read<AuthBloc>().add(ActiRegisterEvent(phone: widget.phone));
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _navigateAndDisplay(context);
        }
      });
      if (authReqId != null && _remainingSeconds % 5 == 0) {
        context
            .read<AuthBloc>()
            .add(ActiAuthStatusEvent(authReqId: authReqId!));
      }
    });
  }

  Future<void> _navigateAndDisplay(BuildContext context) async {
    _timer!.cancel();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputCodeScreen(
          authReqId: authReqId,
          phone: widget.phone,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      startTimer();
      setState(() {
        _remainingSeconds = 30;
        _resend = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is ActiRegisteredState) {
          _timer!.cancel();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InitialScreen()));
        } else if (state is AuthReqIdState) {
          setState(() {
            authReqId = state.loginModel.authReqId;
            normalizedPhone = state.phone;
          });
        } else if (state is ActiSmsSentState) {
          _navigateAndDisplay(context);
        } else if (state is ActiRejectedState) {
          Navigator.pop(context);
          toastification.show(
            context: context,
            title: const Text('Ошибка'),
            description:
                const Text('Не удалось зарегистрироваться, попробуйте позже'),
            type: ToastificationType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
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
                          child:
                              SvgPicture.asset('assets/icons/icon_acti.svg')),
                      SizedBox(
                        height: 90,
                      ),
                      _resend ? Container() : RotatingIcon(),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        'Ожидания подтверждения',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Gilroy',
                            color: Colors.black,
                            fontSize: 18),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        _remainingSeconds < 10
                            ? '00:0${_remainingSeconds.toString()}'
                            : '00:${_remainingSeconds.toString()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Gilroy',
                            color: Colors.black,
                            fontSize: 20),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _resend
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _resend = false;
                                  _remainingSeconds = 30;
                                });
                                startTimer();
                                context.read<AuthBloc>().add(
                                    ActiRegisterEvent(phone: widget.phone));
                              },
                              child: Text(
                                'Отправить код повторно',
                                style: TextStyle(
                                  fontFamily: 'Gilroy',
                                  color: mainBlueColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : Container(),
                      _resend ? SizedBox(height: 10) : Container(),
                      SvgPicture.asset('assets/texts/text_redirect.svg')
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
