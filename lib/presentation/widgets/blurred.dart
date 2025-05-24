import 'dart:ui'; // Для ImageFilter
import 'package:flutter/material.dart';

class BlurredContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Размытие
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // параметры размытия
            child: Container(
              color: Colors.black.withOpacity(0), // прозрачный контейнер
            ),
          ),
        ),
        // Здесь можно разместить содержимое поверх размытия
        Center(
          child: Text(
            'Текст поверх размытия',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ],
    );
  }
}