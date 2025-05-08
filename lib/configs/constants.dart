import 'package:flutter/material.dart';

final List<Map<String, String>> similarUsers = [
  {'image': 'assets/images/image_user_1.png', 'name': 'Алексей'},
  {'image': 'assets/images/image_user_2.png', 'name': 'Максим'},
  {'image': 'assets/images/image_user_3.png', 'name': 'Анастасия'},
  {'image': 'assets/images/image_user_4.png', 'name': 'Николай'},
];

const API = 'http://93.183.81.104';

String normalizePhone(String input) {
  return input.replaceAll(RegExp(r'[^\d+]'), '');
}
const hintTextStyleEdit = TextStyle(fontFamily:'Inter',fontSize: 14,fontWeight: FontWeight.w300,color: Colors.grey);
const titleTextStyleEdit = TextStyle(fontFamily: 'Inter',fontSize: 13,fontWeight: FontWeight.w400);

String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}