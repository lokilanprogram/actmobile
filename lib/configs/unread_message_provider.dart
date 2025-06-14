import 'package:flutter/material.dart';

class UnreadMessageProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void increment() async {
    _unreadCount++;
    notifyListeners();
  }

  void decrement() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  void reset() {
    _unreadCount = 0;
    notifyListeners();
  }

  void setUnreadCount(int count) {
    _unreadCount = count.clamp(0, double.infinity).toInt();
    notifyListeners();
  }
}
