// import 'package:acti_mobile/domain/repositories/auth_repository.dart';
// import 'package:acti_mobile/navigation/app_route_path.dart';
// import 'package:acti_mobile/navigation/app_router_delegate.dart';
// import 'package:acti_mobile/utils/app_colors.dart';
// import 'package:acti_mobile/utils/app_fonts.dart';
// import 'package:acti_mobile/utils/assets.dart';
// import 'package:acti_mobile/utils/error_handler.dart';

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:developer' as developer;
// import 'dart:convert';

// import 'package:dio/dio.dart';

// class VerifyEmailScreen extends StatefulWidget {
//   final String token;
//   final String email;
//   final AppRouterDelegate routerDelegate;

//   const VerifyEmailScreen({
//     super.key,
//     required this.token,
//     required this.email,
//     required this.routerDelegate,
//   });

//   @override
//   State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
// }

// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     // Проверяем статус верификации при открытии экрана
//     _checkVerificationStatus();
//   }

//   // Метод для повторной отправки письма с подтверждением
//   Future<void> _resendVerificationEmail() async {
//     try {
//       setState(() {
//         _isLoading = true; // Включаем индикатор загрузки
//       });

//       final authRepository = context.read<AuthRepository>();
//       // Используем widget.email для доступа к email из State
//       await authRepository.resendVerificationEmail(widget.email);

//       if (mounted) {
//         // Проверяем, что виджет все еще смонтирован
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Письмо с подтверждением отправлено повторно'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       developer.log('Ошибка при повторной отправке письма: $e',
//           name: 'VERIFY_EMAIL');
//       if (mounted) {
//         // Проверяем, что виджет все еще смонтирован
//         ErrorHandler.handleError(e, context);
//       }
//     } finally {
//       if (mounted) {
//         // Проверяем, что виджет все еще смонтирован
//         setState(() {
//           _isLoading = false; // Выключаем индикатор загрузки
//         });
//       }
//     }
//   }

//   // Метод для проверки статуса верификации email (используется при загрузке и по кнопке)
//   Future<void> _checkVerificationStatus() async {
//     if (_isLoading) return; // Избегаем повторных запросов

//     try {
//       setState(() {
//         _isLoading = true; // Включаем индикатор загрузки
//       });

//       final authRepository = context.read<AuthRepository>();
//       // Проверяем и обновляем токены
//       final isAuthenticated =
//           await authRepository.checkAndRefreshTokenIfNeeded();

//       if (isAuthenticated) {
//         final accessToken = await authRepository.getAccessToken();
//         if (accessToken != null) {
//           // Проверяем верификацию email
//           // checkEmailVerification вернет данные профиля при успехе (200)
//           // или выбросит DioException при 403 'Email is not verified'
//           final profileData =
//               await authRepository.checkEmailVerification(accessToken);

//           // Если checkEmailVerification не выбросил ошибку 403 и вернул данные,
//           // считаем, что email верифицирован и переходим на главный экран
//           // (даже если 'is_verified' == false для соц.сетей без email).
//           // Если email == 'None' (соц сети), то checkAndRefreshTokenIfNeeded уже вернет true
//           // и мы не попадем в этот блок в случае, если email был None изначально.
//           // Если это обычный пользователь с email, то profileData['is_verified'] будет true при успехе.
//           debugPrint(
//               'Email verification check successful. Navigating to Home.');
//           if (mounted) {
//             // Проверяем, что виджет все еще смонтирован
//             // Используем widget.routerDelegate для навигации
//             widget.routerDelegate.setNewRoutePath(AppRoutePath.home());
//           }
//         } else {
//           // Нет access token, перенаправляем на экран авторизации
//           debugPrint(
//               'Access token missing during verification check. Navigating to Auth.');
//           if (mounted) {
//             widget.routerDelegate.setNewRoutePath(AppRoutePath.auth());
//           }
//         }
//       } else {
//         // Пользователь не авторизован (токены невалидны или отсутствуют), перенаправляем на экран авторизации
//         debugPrint(
//             'User not authenticated during verification check. Navigating to Auth.');
//         if (mounted) {
//           widget.routerDelegate.setNewRoutePath(AppRoutePath.auth());
//         }
//       }
//     } on DioException catch (e) {
//       // Обрабатываем конкретную ошибку: Email is not verified (403)
//       if (e.response?.statusCode == 403 &&
//           e.response?.data['detail'] == 'Email is not verified') {
//         developer.log('Email still not verified (403). Staying on screen.',
//             name: 'VERIFY_EMAIL');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Email еще не подтвержден. Проверьте почту.'),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       } else {
//         // Обработка других ошибок Dio
//         developer.log(
//             'DioError during verification check: ${e.response?.data ?? e.message}',
//             name: 'VERIFY_EMAIL');
//         if (mounted) {
//           ErrorHandler.handleError(
//               e, context); // Используем ErrorHandler для других ошибок
//         }
//       }
//     } catch (e) {
//       developer.log('Unknown error during verification check: $e',
//           name: 'VERIFY_EMAIL');
//       // Обрабатываем другие ошибки
//       if (mounted) {
//         ErrorHandler.handleError(e, context); // Используем ErrorHandler
//       }
//     } finally {
//       if (mounted) {
//         // Проверяем, что виджет все еще смонтирован
//         setState(() {
//           _isLoading = false; // Выключаем индикатор загрузки
//         });
//       }
//     }
//   }

//   // Метод, вызываемый при нажатии кнопки "Я подтвердил почту"
//   void _onVerifyEmailButtonPressed() {
//     _checkVerificationStatus(); // Вызываем ту же логику проверки
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Stack(
//           // Используем Stack для наложения индикатора загрузки
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     SvgAssets.email,
//                     width: 80,
//                     height: 80,
//                     color: AppColors.primaryDark,
//                   ),
//                   const SizedBox(height: 32),
//                   const Text(
//                     'Подтвердите ваш email',
//                     style: AppFonts.h24,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     // Используем widget.email
//                     'Мы отправили письмо на ${widget.email}. Пожалуйста, перейдите по ссылке в письме для подтверждения вашего аккаунта.',
//                     style: AppFonts.h16dark,
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 32),
//                   const Text(
//                     'Не получили письмо?',
//                     style: AppFonts.h14grey,
//                   ),
//                   TextButton(
//                     // Отключаем кнопку при загрузке
//                     onPressed:
//                         _isLoading ? null : () => _resendVerificationEmail(),
//                     child: Text(
//                       'Отправить повторно',
//                       style: TextStyle(
//                         // Меняем цвет текста кнопки при отключении
//                         color: _isLoading ? Colors.grey : AppColors.primaryDark,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16), // Добавляем отступ
//                   // Новая кнопка для ручной проверки статуса
//                   ElevatedButton(
//                     onPressed: _isLoading ? null : _onVerifyEmailButtonPressed,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryDark, // Цвет кнопки
//                       foregroundColor: Colors.white, // Цвет текста
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ))
//                         : const Text('Я подтвердил почту',
//                             style: AppFonts.h14light),
//                   ),
//                 ],
//               ),
//             ),
//             // Индикатор загрузки поверх остального контента
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
