import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:acti_mobile/domain/bloc/auth/auth_bloc.dart';
import 'package:acti_mobile/presentation/screens/initial/initial_screen.dart';
import 'package:acti_mobile/domain/api/profile/profile_api.dart';
import 'package:acti_mobile/presentation/screens/maps/map/map_screen.dart';
import 'package:acti_mobile/presentation/screens/onbording/events_around/events_around_screen.dart';
import 'package:acti_mobile/presentation/screens/auth/select_input/select_input_screen.dart';
import 'package:acti_mobile/configs/constants.dart';

class SocialAuthWebView extends StatefulWidget {
  final String provider;
  final String initialUrl;
  final String redirectUrl;
  final String? codeVerifier;

  const SocialAuthWebView({
    super.key,
    required this.provider,
    required this.initialUrl,
    required this.redirectUrl,
    this.codeVerifier,
  });

  @override
  State<SocialAuthWebView> createState() => _SocialAuthWebViewState();
}

class _SocialAuthWebViewState extends State<SocialAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigated = false;
  bool _hasError = false;
  String? _errorMessage;

  // Добавляем переменные для проброса PKCE и других параметров
  String? _codeVerifier;
  String? _deviceId;
  String? _stateParam;
  String? _phoneParam;

  // Добавь clientId для VK
  static const String vkClientId = '53703480';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted) return;
            developer.log('WebView error: ${error.description}',
                name: 'SOCIAL_AUTH_WEBVIEW');
            setState(() {
              _hasError = true;
              _errorMessage = 'Ошибка загрузки страницы: ${error.description}';
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            if (_hasNavigated) return NavigationDecision.navigate;

            developer.log('Navigation request: ${request.url}',
                name: 'SOCIAL_AUTH_WEBVIEW');

            try {
              if (request.url.startsWith(widget.redirectUrl)) {
                final uri = Uri.parse(request.url);
                final Map<String, dynamic> result = {};

                if (widget.provider == 'vk') {
                  final code = uri.queryParameters['code'];
                  final state = uri.queryParameters['state'];
                  final deviceId = uri.queryParameters['device_id'];
                  final extPhone = uri.queryParameters['phone'];
                  // code_verifier пробрасывается через widget (см. SelectInputScreen)
                  final codeVerifier = widget.codeVerifier;

                  developer.log('VK Auth URI: $uri',
                      name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('VK Auth Parameters:',
                      name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('Code: $code', name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('State: $state', name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('Device ID: $deviceId',
                      name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('Code Verifier: $codeVerifier',
                      name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('Phone: $extPhone',
                      name: 'SOCIAL_AUTH_WEBVIEW');

                  if (code != null &&
                      state != null &&
                      codeVerifier != null &&
                      deviceId != null) {
                    result['code'] = code;
                    result['state'] = state;
                    result['device_id'] = deviceId;
                    result['code_verifier'] = codeVerifier;
                    result['phone'] = extPhone ?? '';

                    _hasNavigated = true;
                    // Получаем данные пользователя через VK API
                    final userData = await _getVkUserData(
                      code: code,
                      codeVerifier: codeVerifier,
                      deviceId: deviceId,
                      state: state,
                      phone: extPhone,
                    );
                    developer.log('VK User Data: $userData',
                        name: 'SOCIAL_AUTH_WEBVIEW');

                    result['email'] = userData['email'] ?? '';
                    result['phone'] = userData['phone'] ?? '';

                    Navigator.of(context).pop(result);
                    return NavigationDecision.prevent;
                  }
                } else if (widget.provider == 'yandex') {
                  final token = _extractTokenFromUrl(request.url);
                  if (token != null) {
                    result['token'] = token;
                    _hasNavigated = true;
                    Navigator.of(context).pop(result);
                    return NavigationDecision.prevent;
                  }
                }
              }
            } catch (e) {
              developer.log('Ошибка при обработке URL: $e',
                  name: 'SOCIAL_AUTH_WEBVIEW');
              setState(() {
                _hasError = true;
                _errorMessage = 'Ошибка при обработке ответа: $e';
              });
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  String? _extractTokenFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      developer.log('Extracting token from URL: $url',
          name: 'SOCIAL_AUTH_WEBVIEW');

      // Для Яндекса токен обычно находится в фрагменте URI (#access_token=...)
      final fragment = uri.fragment;
      if (fragment.isNotEmpty) {
        final params = Uri.splitQueryString(fragment);
        developer.log('Fragment parameters: $params',
            name: 'SOCIAL_AUTH_WEBVIEW');
        return params['access_token'];
      }

      // Если токен не в фрагменте, проверяем параметры запроса
      final queryParams = uri.queryParameters;
      if (queryParams.containsKey('access_token')) {
        developer.log('Query parameters: $queryParams',
            name: 'SOCIAL_AUTH_WEBVIEW');
        return queryParams['access_token'];
      }
    } catch (e) {
      developer.log('Ошибка при извлечении токена: $e',
          name: 'SOCIAL_AUTH_WEBVIEW');
    }
    return null;
  }

  // Future<Map<String, String?>> _getVkUserData({
  //   required String code,
  //   required String codeVerifier,
  //   required String deviceId,
  //   required String state,
  //   String? phone,
  // }) async {
  //   try {
  //     // Извлекаем чистый код из формата vk2.a.xxx
  //     final cleanCode = code;

  //     developer.log('Sending VK auth code to backend: $cleanCode',
  //         name: 'SOCIAL_AUTH_WEBVIEW');

  //     // 1. Получаем access_token через свой бэкенд (или напрямую, если можно)
  //     final tokenResponse = await http.post(
  //       Uri.parse('https://id.vk.com/oauth2/auth'),
  //       headers: {
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //       body:
  //           'grant_type=authorization_code&code_verifier=$codeVerifier&redirect_uri=https%3A%2F%2Foauth.vk.com%2Fblank.html&code=$cleanCode&client_id=$vkClientId&device_id=$deviceId&state=$state',
  //     );
  //     developer.log('VK token response: ${tokenResponse.body}',
  //         name: 'SOCIAL_AUTH_WEBVIEW');
  //     if (tokenResponse.statusCode != 200) {
  //       developer.log('Ошибка получения access_token: ${tokenResponse.body}',
  //           name: 'SOCIAL_AUTH_WEBVIEW');
  //       return {'email': '', 'phone': ''};
  //     }
  //     final tokenData = json.decode(tokenResponse.body);
  //     final accessToken = tokenData['access_token'] as String?;
  //     final email = tokenData['email'] as String?;

  //     // 2. Получаем данные пользователя через user_info
  //     String? phoneResp;
  //     if (accessToken != null) {
  //       final userInfoResponse = await http.post(
  //         Uri.parse('https://id.vk.com/oauth2/user_info'),
  //         headers: {
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //         body: 'client_id=$vkClientId&access_token=$accessToken',
  //       );
  //       developer.log('VK user_info response: ${userInfoResponse.body}',
  //           name: 'SOCIAL_AUTH_WEBVIEW');
  //       if (userInfoResponse.statusCode == 200) {
  //         final userData = json.decode(userInfoResponse.body);
  //         final user = userData['user'] as Map<String, dynamic>?;
  //         phoneResp = user != null ? user['phone'] as String? : null;
  //       }
  //     }

  //     developer.log('Email from backend: $email', name: 'SOCIAL_AUTH_WEBVIEW');
  //     developer.log('Phone from user_info: $phoneResp',
  //         name: 'SOCIAL_AUTH_WEBVIEW');

  //     return {
  //       'email': email ?? '',
  //       'phone': phoneResp ?? '',
  //     };
  //   } catch (e) {
  //     developer.log('Ошибка при отправке кода на бэкенд: $e',
  //         name: 'SOCIAL_AUTH_WEBVIEW');
  //   }
  //   return {'email': '', 'phone': ''};
  // }

  Future<Map<String, String?>> _getVkUserData({
    required String code,
    required String codeVerifier,
    required String deviceId,
    required String state,
    String? phone,
  }) async {
    // Теперь не делаем запросы к VK ID напрямую, только возвращаем параметры для бэкенда
    return {
      'code': code,
      'code_verifier': codeVerifier,
      'device_id': deviceId,
      'state': state,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is ActiRegisteredState) {
          developer.log(
              'Получен ActiRegisteredState, переходим на InitialScreen',
              name: 'SOCIAL_AUTH_WEBVIEW');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InitialScreen(),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          // title: Text(
          //   widget.provider == 'vk'
          //       ? 'Вход через VK'
          //       : widget.provider == 'yandex'
          //           ? 'Вход через Яндекс'
          //           : 'Социальная авторизация',
          // ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Stack(
          children: [
            if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'Произошла ошибка',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _errorMessage = null;
                          });
                          _controller.reload();
                        },
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              )
            else
              WebViewWidget(controller: _controller),
            if (_isLoading && !_hasError)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
