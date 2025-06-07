import 'package:flutter/material.dart';

class CustomNavBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  void _handleTap(BuildContext context, int index) {
    // Скрываем клавиатуру при переключении экранов
    FocusScope.of(context).unfocus();
    onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _handleTap(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Карта',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'События',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Чаты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
