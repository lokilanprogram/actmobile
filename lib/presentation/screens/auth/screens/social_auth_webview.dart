import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SocialAuthWebView extends StatefulWidget {
  final String provider;
  final String initialUrl;
  final String redirectUrl;

  const SocialAuthWebView({
    super.key,
    required this.provider,
    required this.initialUrl,
    required this.redirectUrl,
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
            setState(() {
              _isLoading = true;
              _hasError = false;
              _errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
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

                  developer.log('VK Auth URI: $uri',
                      name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('VK Auth Parameters:',
                      name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('Code: $code', name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('State: $state', name: 'SOCIAL_AUTH_WEBVIEW');
                  developer.log('Device ID: $deviceId',
                      name: 'SOCIAL_AUTH_WEBVIEW');

                  if (code != null && state != null) {
                    result['code'] = code;
                    result['state'] = state;
                    if (deviceId != null) {
                      result['device_id'] = deviceId;
                    }

                    // Получаем данные пользователя через VK API
                    final userData = await _getVkUserData(code);
                    developer.log('VK User Data: $userData',
                        name: 'SOCIAL_AUTH_WEBVIEW');

                    result['email'] = userData['email'] ?? '';
                    result['phone'] = userData['phone'] ?? '';

                    _hasNavigated = true;
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

  Future<Map<String, String?>> _getVkUserData(String code) async {
    try {
      const clientId = '53703480';
      const clientSecret =
          'E7vT8Kk4MJAnZJVGi1VY'; // Нужно добавить ваш client secret
      const redirectUri = 'https://oauth.vk.com/blank.html';

      developer.log('Requesting VK access token with code: $code',
          name: 'SOCIAL_AUTH_WEBVIEW');

      final response = await http.post(
        Uri.parse('https://oauth.vk.com/access_token'),
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'code': code,
        },
      );

      developer.log('VK access token response: ${response.body}',
          name: 'SOCIAL_AUTH_WEBVIEW');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Получаем access token
        final accessToken = data['access_token'] as String?;
        final email = data['email'] as String?;

        developer.log('VK access token: $accessToken',
            name: 'SOCIAL_AUTH_WEBVIEW');
        developer.log('VK email from token response: $email',
            name: 'SOCIAL_AUTH_WEBVIEW');

        if (accessToken == null) {
          return {'email': '', 'phone': ''};
        }

        // Делаем запрос к VK API для получения данных пользователя
        final userResponse = await http.get(
          Uri.parse(
              'https://api.vk.com/method/users.get?fields=contacts&access_token=$accessToken&v=5.131'),
        );

        developer.log('VK user data response: ${userResponse.body}',
            name: 'SOCIAL_AUTH_WEBVIEW');

        if (userResponse.statusCode == 200) {
          final userData = json.decode(userResponse.body);

          final response = userData['response'] as List?;
          if (response != null && response.isNotEmpty) {
            final user = response[0] as Map<String, dynamic>;
            return {
              'email': email ?? '',
              'phone': user['mobile_phone'] as String? ?? '',
            };
          }
        }
      }
    } catch (e) {
      developer.log('Ошибка при получении данных из VK API: $e',
          name: 'SOCIAL_AUTH_WEBVIEW');
    }
    return {'email': '', 'phone': ''};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
