import 'package:flutter/material.dart';

class MainScreenProvider extends ChangeNotifier {
  int _currentIndex = 1;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
