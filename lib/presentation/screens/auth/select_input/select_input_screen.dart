import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/configs/type_navigation.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/presentation/screens/chats/chat_detail/models/social_login_request.dart';
import 'package:acti_mobile/presentation/screens/auth/input_phone/input_phone.dart';
import 'package:acti_mobile/presentation/screens/auth/screens/social_auth_webview.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/privacy_policy_screen.dart';
import 'package:acti_mobile/presentation/screens/profile/settings/user_agreement_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;

import 'package:pkce/pkce.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
    print('==========================================');
    print('ЗАШЛИ В _onSocialLogin !!!');
    print('provider = $provider');
    print('==========================================');

    print('🚀 _onSocialLogin вызван с provider: $provider');
    developer.log('🚀 _onSocialLogin вызван с provider: $provider',
        name: 'AUTH_DEBUG');

    String? initialUrl;
    String? redirectUrl;
    Map<String, dynamic>? authResult;

    if (provider == 'vk') {
      const clientId = '53703480';
      const vkRedirectUri = 'https://oauth.vk.com/blank.html';
      final codeChallenge = _pkcePair.codeChallenge;
      initialUrl =
          'https://id.vk.com/authorize?client_id=$clientId&redirect_uri=$vkRedirectUri&response_type=code&scope=email%20phone&code_challenge=$codeChallenge&code_challenge_method=S256&state=$_state&v=5.131';
      redirectUrl = vkRedirectUri;
    } else if (provider == 'yandex') {
      const clientId = 'bf26d338b2ac4b50aa3d1fe972edf401';
      const yandexRedirectUri = 'acti://auth/yandex_callback';
      initialUrl =
          'https://oauth.yandex.ru/authorize?response_type=token&client_id=$clientId&redirect_uri=$yandexRedirectUri';
      redirectUrl = yandexRedirectUri;
    } else if (provider == 'apple') {
      // Handle Apple Sign In directly
      try {
        print('🍎 НАЧИНАЕМ Apple Sign In процесс...');

        if (!Platform.isIOS) {
          print('🍎 ОШИБКА: Apple Sign In доступен только на iOS');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Apple Sign In доступен только на iOS')),
          );
          return;
        }

        print('🍎 Платформа iOS подтверждена, запрашиваем credential...');
        developer.log('🍎 Начинаем Apple Sign In...', name: 'APPLE_AUTH');

        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        print('🍎 ✅ Apple credential ПОЛУЧЕН!');
        print('');
        print('🍎 ========== ПОЛНЫЕ ДАННЫЕ ОТ APPLE ==========');
        print('🍎 🔑 identityToken (ОБЯЗАТЕЛЬНОЕ):');
        print('🍎    Значение: ${credential.identityToken}');
        print('🍎    Null: ${credential.identityToken == null}');
        print('🍎    Длина: ${credential.identityToken?.length ?? 0}');
        print('');
        print('🍎 📝 authorizationCode (ОПЦИОНАЛЬНОЕ):');
        print('🍎    Значение: ${credential.authorizationCode}');
        print('🍎    Null: ${credential.authorizationCode == null}');
        print('🍎    Длина: ${credential.authorizationCode?.length ?? 0}');
        print('');
        print('🍎 📧 email (ОПЦИОНАЛЬНОЕ):');
        print('🍎    Значение: ${credential.email}');
        print('🍎    Null: ${credential.email == null}');
        print('');
        print('🍎 👤 givenName (Имя, ОПЦИОНАЛЬНОЕ):');
        print('🍎    Значение: ${credential.givenName}');
        print('🍎    Null: ${credential.givenName == null}');
        print('');
        print('🍎 👤 familyName (Фамилия, ОПЦИОНАЛЬНОЕ):');
        print('🍎    Значение: ${credential.familyName}');
        print('🍎    Null: ${credential.familyName == null}');
        print('');
        print('🍎 🆔 userIdentifier (Уникальный ID):');
        print('🍎    Значение: ${credential.userIdentifier}');
        print('🍎    Null: ${credential.userIdentifier == null}');
        print('');
        print('🍎 🎯 state:');
        print('🍎    Значение: ${credential.state}');
        print('🍎    Null: ${credential.state == null}');
        print('🍎 ============================================');
        print('');

        developer.log('🍎 Apple credential получен:', name: 'APPLE_AUTH');
        developer.log(
            '- identityToken: ${credential.identityToken?.substring(0, 50)}...',
            name: 'APPLE_AUTH');
        developer.log(
            '- authorizationCode: ${credential.authorizationCode?.substring(0, 50)}...',
            name: 'APPLE_AUTH');
        developer.log('- email: ${credential.email}', name: 'APPLE_AUTH');
        developer.log('- givenName: ${credential.givenName}',
            name: 'APPLE_AUTH');
        developer.log('- familyName: ${credential.familyName}',
            name: 'APPLE_AUTH');
        developer.log('- userIdentifier: ${credential.userIdentifier}',
            name: 'APPLE_AUTH');

        print('🍎 🔄 Обработка данных для бэкенда...');
        print('🍎 ⚠️  ВАЖНО: Получены дополнительные данные от Apple:');
        print(
            '🍎    - authorizationCode: ${credential.authorizationCode != null ? "✅" : "❌"}');
        print('🍎    - email: ${credential.email != null ? "✅" : "❌"}');
        print('🍎    - givenName: ${credential.givenName != null ? "✅" : "❌"}');
        print(
            '🍎    - familyName: ${credential.familyName != null ? "✅" : "❌"}');
        print(
            '🍎 📤 НО на бэкенд отправляется ТОЛЬКО identity_token согласно новому API!');
        print('');

        // Создаем запрос только с identity_token
        final appleRequest = AppleLoginRequest(
          identityToken: credential.identityToken!,
        );

        print('🍎 📦 ===== ДАННЫЕ ДЛЯ ОТПРАВКИ НА БЭКЕНД (НОВОЕ API) =====');
        print('🍎 Обновленный AppleLoginRequest создан:');
        final jsonData = appleRequest.toJson();
        print('🍎 JSON структура (только identity_token):');
        jsonData.forEach((key, value) {
          print(
              '🍎   "$key": ${value == null ? 'null' : '"${value.toString().substring(0, value.toString().length > 100 ? 100 : value.toString().length)}${value.toString().length > 100 ? '...' : ''}"'}');
        });
        print('🍎 Размер JSON: ${jsonData.length} поле(й)');
        print('🍎 Полный JSON: $jsonData');
        print('🍎 =============================================');
        print('');

        developer.log('🍎 AppleLoginRequest создан:', name: 'APPLE_AUTH');
        developer.log('- JSON: ${appleRequest.toJson()}', name: 'APPLE_AUTH');

        print('🍎 Отправляем в AuthBloc...');
        print('');
        print('🍎 🚀 ===== ОТПРАВКА НА БЭКЕНД =====');
        print('🍎 Эндпоинт: POST /api/v1/auth/apple');
        print('🍎 Данные в теле запроса:');
        print('🍎 {');
        jsonData.forEach((key, value) {
          print('🍎   "$key": ${value == null ? 'null' : '"$value"'},');
        });
        print('🍎 }');
        print('🍎 ================================');
        print('🍎 📡 Отправляем через AuthBloc -> SocialLoginRequested...');
        print('');

        context.read<AuthBloc>().add(
              SocialLoginRequested(
                appleRequest,
                context,
              ),
            );
        print('🍎 ✅ Запрос отправлен в AuthBloc');
        print('🍎 ⏳ Ожидаем ответ от сервера...');
        print('🍎 💡 Проверьте консоль AuthService для ответа сервера');
        print('');
        return;
      } catch (e, stackTrace) {
        print('🍎 ❌ ОШИБКА Apple Sign In: $e');
        print('🍎 StackTrace: $stackTrace');
        developer.log('🍎 Ошибка Apple Sign In: $e', name: 'APPLE_AUTH');
        developer.log('🍎 StackTrace: $stackTrace', name: 'APPLE_AUTH');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка авторизации Apple: $e')),
        );
        return;
      }
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
          codeVerifier: _pkcePair.codeVerifier,
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
                context,
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
                context,
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
    return SafeArea(
      top: false,
      bottom: isGestureNavigation(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // Фоновое изображение
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/image_background.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Основной контент
              Container(
                padding: const EdgeInsets.only(
                  top: 120,
                  left: 45,
                  right: 45,
                ),
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
                    SizedBox(height: 40),
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: InkWell(
                              onTap: () => _onSocialLogin('yandex'),
                              child: SvgPicture.asset(
                                  'assets/icons/icon_yandex_id.svg')),
                        ),
                        Flexible(
                          child: InkWell(
                              onTap: () => _onSocialLogin('vk'),
                              child: SvgPicture.asset(
                                  'assets/icons/icon_vk_id.svg')),
                        ),
                        if (Platform.isIOS)
                          Flexible(
                            child: InkWell(
                                onTap: () {
                                  print('НАЖАЛИ НА APPLE!!!!');
                                  debugPrint('НАЖАЛИ НА APPLE!!!!');
                                  print('Вызываем _onSocialLogin с apple');
                                  _onSocialLogin('apple');
                                },
                                child: SvgPicture.asset(
                                    'assets/icons/icon_apple_id.svg')),
                          ),
                      ],
                    ),
                    Spacer(),
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
                                    'При входе и регистрации, вы соглашаетесь с '),
                            TextSpan(
                              text: 'пользовательским соглашением',
                              style: TextStyle(
                                color: mainBlueColor,
                                // decoration: TextDecoration.underline
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const UserAgreementScreen()),
                                  );
                                },
                            ),
                            TextSpan(text: ' и '),
                            TextSpan(
                              text: 'политикой конфиденциальности',
                              style: TextStyle(
                                color: mainBlueColor,
                                // decoration: TextDecoration.underline
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const PrivacyPolicyScreen()),
                                  );
                                },
                            ),
                            TextSpan(
                                text:
                                    ', а также подтверждаете, что вам 18 лет и более.'),
                          ]),
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
