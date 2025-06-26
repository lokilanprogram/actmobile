import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        backgroundColor: Colors.white,
        title: const Text('О нас'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'Acti — это приложение, которое помогает пользователям находить мероприятия по их увлечениям.\n\nПользователи находят здесь разнообразные мероприятия — мастер-классы, спортивные тренировки, культурные события и многое другое. Всего в Acti представлено более 3 000 000 мероприятий по 900 различным категориям.\n\nОрганизаторы мероприятий и частные специалисты находят с помощью Acti заинтересованных участников. Каждый день в нашем приложении появляется более 25 тысяч новых предложений.',
          style: TextStyle(fontSize: 17, height: 1.4),
        ),
      ),
    );
  }
}
