import 'package:flutter/material.dart';

class MainScreenProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isMapLoading = true;

  int get currentIndex => _currentIndex;
  bool get isMapLoading => _isMapLoading;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setMapLoading(bool isLoading) {
    _isMapLoading = isLoading;
    notifyListeners();
  }
}
