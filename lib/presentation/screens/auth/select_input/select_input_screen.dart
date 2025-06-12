import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/models/social_login_request.dart';
import 'package:acti_mobile/presentation/screens/auth/input_phone/input_phone.dart';
import 'package:acti_mobile/presentation/screens/auth/screens/social_auth_webview.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import 'package:pkce/pkce.dart';

class SelectInputScreen extends StatefulWidget {
  const SelectInputScreen({
    super.key,
  });

  @override
  State<SelectInputScreen> createState() => _SelectInputScreenState();
}

class _SelectInputScreenState extends State<SelectInputScreen> {
  late PkcePair _pkcePair;
  late String _state;

  @override
  void initState() {
    super.initState();
    developer.log('AuthScreen: initState вызван', name: 'AUTH_SCREEN');

    _pkcePair = PkcePair.generate();
    _state = _pkcePair.codeVerifier.substring(0, 32);
  }

  void _onSocialLogin(String provider) async {
    String? initialUrl;
    String? redirectUrl;
    Map<String, dynamic>? authResult;

    if (provider == 'vk') {
      const clientId = '53703480';
      const vkRedirectUri = 'https://oauth.vk.com/blank.html';
      final codeChallenge = _pkcePair.codeChallenge;
      initialUrl =
          'https://id.vk.com/authorize?client_id=$clientId&redirect_uri=$vkRedirectUri&response_type=code&scope=email,phone&code_challenge=$codeChallenge&code_challenge_method=S256&state=$_state&v=5.131';
      redirectUrl = vkRedirectUri;
    } else if (provider == 'yandex') {
      const clientId = 'bf26d338b2ac4b50aa3d1fe972edf401';
      const yandexRedirectUri = 'acti://auth/yandex_callback';
      initialUrl =
          'https://oauth.yandex.ru/authorize?response_type=token&client_id=$clientId&redirect_uri=$yandexRedirectUri';
      redirectUrl = yandexRedirectUri;
    }

    if (initialUrl == null || redirectUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Неподдерживаемый провайдер авторизации')),
      );
      return;
    }

    authResult = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => SocialAuthWebView(
          provider: provider,
          initialUrl: initialUrl!,
          redirectUrl: redirectUrl!,
        ),
      ),
    );

    if (authResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Авторизация отменена')),
      );
      return;
    }

    try {
      if (provider == 'vk') {
        final code = authResult['code'] as String?;
        final deviceId = authResult['device_id'] as String?;
        final state = authResult['state'] as String?;

        if (code == null || state == null) {
          throw Exception('Отсутствуют обязательные параметры авторизации');
        }

        context.read<AuthBloc>().add(
              SocialLoginRequested(
                VkLoginRequest(
                  code: code,
                  codeVerifier: _pkcePair.codeVerifier,
                  deviceId: deviceId,
                  state: state,
                  email: authResult['email'] as String?,
                  phone: authResult['phone'] as String?,
                ),
              ),
            );
      } else if (provider == 'yandex') {
        final token = authResult['token'] as String?;
        if (token == null) {
          throw Exception('Отсутствует токен авторизации');
        }

        context.read<AuthBloc>().add(
              SocialLoginRequested(
                YandexLoginRequest(
                  token: token,
                ),
              ),
            );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка авторизации: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Фоновое изображение
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/image_background.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Основной контент
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 120, left: 45, right: 45, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/icons/icon_acti.svg'),
                  SizedBox(height: 40),
                  Text(
                    'Войти в приложение',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      color: authBlueColor,
                      fontSize: 27,
                    ),
                  ),

                  ////
                  // InkWell(
                  //   // onTap: () => _onSocialLogin('yandex'),
                  //   onTap: () {
                  //     final accessToken =
                  //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYWZkYWIwOC05ZDhkLTRlZmUtYWVhMy1hNGQwMDBlZTJhMDgiLCJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzg0MDgzMjEzfQ.hp4g-SOZiw3t1Wg2Q-6h1sQMwpY1220v_5LC8fVQ1Dg';
                  //     final refreshToken =
                  //         'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYWZkYWIwOC05ZDhkLTRlZmUtYWVhMy1hNGQwMDBlZTJhMDgiLCJ0eXBlIjoicmVmcmVzaCIsImV4cCI6MTc1MDY3NTIxM30.Hlec01f57x5xBCU3WLaJiECT2P2ONYnJ81Whk4Bi0Z8';
                  //     writeAuthTokens(accessToken, refreshToken);
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (_) => InitialScreen()));
                  //   },
                  //   // child: SvgPicture.asset(
                  //   //     'assets/icons/icon_yandex_id.svg')
                  //   child: Container(
                  //       width: 150,
                  //       height: 50,
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(25),
                  //         color: mainBlueColor,
                  //       ),
                  //       child: Center(
                  //           child: Text(
                  //         "Временный вход",
                  //         style: TextStyle(color: Colors.white),
                  //       ))),
                  // ),
                  //////
                  SizedBox(height: 45),
                  Text(
                    'Через сервис',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: () => _onSocialLogin('yandex'),
                          // onTap: (){
                          //   final accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYWZkYWIwOC05ZDhkLTRlZmUtYWVhMy1hNGQwMDBlZTJhMDgiLCJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzg0MDgzMjEzfQ.hp4g-SOZiw3t1Wg2Q-6h1sQMwpY1220v_5LC8fVQ1Dg';
                          //   final refreshToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYWZkYWIwOC05ZDhkLTRlZmUtYWVhMy1hNGQwMDBlZTJhMDgiLCJ0eXBlIjoicmVmcmVzaCIsImV4cCI6MTc1MDY3NTIxM30.Hlec01f57x5xBCU3WLaJiECT2P2ONYnJ81Whk4Bi0Z8';
                          //   writeAuthTokens(accessToken, refreshToken);
                          //   Navigator.push(context, MaterialPageRoute(builder: (_)=>InitialScreen()));
                          // },
                          child: SvgPicture.asset(
                              'assets/icons/icon_yandex_id.svg')),
                      SizedBox(width: 15),
                      InkWell(
                          onTap: () => _onSocialLogin('vk'),
                          // onTap: (){
                          //   final accessToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3Y2ZlMzAwNi0xMzIwLTRkY2MtOWRlZS03OWI2N2UxODc0YjciLCJ0eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzg0MDkyNDEyfQ.JkNw5KZ-dbkBeyofuF5mdxz-CoV7MKKi01V959aHT7k';
                          //   final refreshToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI3Y2ZlMzAwNi0xMzIwLTRkY2MtOWRlZS03OWI2N2UxODc0YjciLCJ0eXBlIjoicmVmcmVzaCIsImV4cCI6MTc1MDY4NDQxMn0.tl-VLm2bwUU5wWK0602gvmagngRrzRpM_eIOumRO-J0';
                          //   writeAuthTokens(accessToken, refreshToken);
                          //   Navigator.push(context, MaterialPageRoute(builder: (_)=>InitialScreen()));
                          // },
                          child:
                              SvgPicture.asset('assets/icons/icon_vk_id.svg')),
                    ],
                  ),
                  SizedBox(height: 60),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InputPhoneScreen()),
                      );
                    },
                    child: Container(
                      height: 59,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: mainBlueColor,
                      ),
                      child: Center(
                        child: Text(
                          'По номеру телефона',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SvgPicture.asset('assets/texts/text_confirm.svg'),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
