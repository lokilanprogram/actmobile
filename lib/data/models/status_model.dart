import 'package:acti_mobile/configs/colors.dart';
import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'pending':
      return Color.fromARGB(255,255,172,45);
    case 'active':
      return Color.fromRGBO(98, 207, 102, 1);
    case 'rejected':
      return Colors.red;
    case 'editing':
      return mainBlueColor;
    case 'completed':
      return Color.fromRGBO(98, 207, 102, 1);
    case 'canceled':
      return Colors.red;
    default:
      return Colors.transparent;
  }
}

String getStatusText(String status) {
  switch (status) {
    case 'pending':
      return 'На проверке';
    case 'active':
      return 'Активно';
    case 'rejected':
      return 'Отклонено';
    case 'editing':
      return 'Требует\nредактирования';
    case 'completed':
      return 'Завершено';
    case 'canceled':
      return 'Отменено';
    default:
      return '';
  }
}
