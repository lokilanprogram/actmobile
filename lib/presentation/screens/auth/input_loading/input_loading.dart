import 'dart:async';

import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:acti_mobile/presentation/screens/auth/input_code/input_code.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/widgets/rotating_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => InputCodeScreen(
                        phone: widget.phone,
                      )));
          _timer!.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ActiRegisteredState) {
          _timer!.cancel();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => InitialScreen()));
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
                      RotatingIcon(),
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
