import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:acti_mobile/domain/bloc/profile/profile_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

void _launchEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'Actimobapp@gmail.com',
  );
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    // fallback или ошибка
    debugPrint('Не удалось открыть почтовое приложение');
  }
}

class BlockedScreen extends StatelessWidget {
  final ProfileModel profileModel;
  const BlockedScreen({super.key, required this.profileModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.close,
              color: Colors.red,
              size: 129,
            ),
            SizedBox(
              height: 40,
            ),
            const Text(
              'Ваш аккаунт веременно заблокирован',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                  fontFamily: 'Montserrat'),
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "Мы заметили нарушение правил использования приложения.\nВаш доступ приостановлен до ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  TextSpan(
                    text: "...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(
                      text:
                          'Если вы считаете, что это ошибка, свяжитесь с поддержкой '),
                  TextSpan(
                    text: 'Actimobapp@gmail.com',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _launchEmail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeletedScreen extends StatelessWidget {
  final ProfileModel profileModel;
  const DeletedScreen({super.key, required this.profileModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Colors.red,
              size: 129,
            ),
            SizedBox(
              height: 40,
            ),
            const Text(
              'Аккаунт удален',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                  fontFamily: 'Montserrat'),
            ),
            SizedBox(
              height: 20,
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(
                      text:
                          'Ваш аккаунт был удален администратором. Если вы считаете, что это произошло по ошибке, пожалуйста, свяжитесь с нашей службой поддержки'),
                  TextSpan(
                    text: 'Actimobapp@gmail.com',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = _launchEmail,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
