import 'dart:io';

import 'package:flutter/material.dart';

bool isGestureNavigation(BuildContext context) {
  if (!Platform.isAndroid) return false; // Только для Android
  
  final padding = MediaQuery.of(context);
  return padding.systemGestureInsets.bottom > 40; // Если есть нижний отступ, вероятно, используются жесты
}