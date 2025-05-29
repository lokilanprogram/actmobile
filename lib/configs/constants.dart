import 'dart:io';
import 'package:http/http.dart' show get;
import 'package:mime/mime.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

final List<Map<String, String>> complainSpam = [
  {'title': 'Вредоносные ссылки', 'subtitle': 'Организатор размещает ссылки на вредоносные и подозрительные ресурсы'},
  {'title': 'Реклама', 'subtitle': 'Размещено множество рекламы'},
];

final List<Map<String, String>> complainLie = [
  {'title': 'Введение в заблуждение', 'subtitle': 'Потенциально резонансное и опасное описание, размещённое с целью массовой дезинформации.'},
  {'title': 'Мошенничество', 'subtitle': 'Обман с целью получения материальной выгоды. Если вы стали жертвой мошенников, обратитесь в правоохранительные органы.'},
  {'title': 'Киберпреступность', 'subtitle': 'Предлагаются услуги взлома, накрутки или ведётся другая активность, связанная с компьютерными преступлениями.'},
];

final List<Map<String, String>> complainViolence = [
  {'title': 'Насилие над людьми и животными', 'subtitle': ''},
  {'title': 'Оскорбления', 'subtitle': 'Унижение чести и достоинства личности.'},
  {'title': 'Склонение к самоубийству', 'subtitle': 'Призыв к суициду или нанесению себе увечий, демонстрация самоубийства.'},
  {'title': 'Экстремизм', 'subtitle': 'Призывы к беспорядкам и террору, насилию над людьми определённой национальности, вероисповедания, расы.'},
  {'title': 'Призывы к травле', 'subtitle': 'Призывы применять физическую силу и унижать конкретного человека.'},
  {'title': 'Враждебные высказывания', 'subtitle': 'Выражение нетерпимости к людям из-за расы, национальности, вероисповедания, гендера, сексуальной ориентации и других признаков.'},
];

final List<Map<String, String>> complainItems = [
  {'title': 'Оружие',},
  {'title': 'Наркотики'},
  {'title': 'Проституция'},
  {'title': 'Другое'},
];

final List<Map<String, String>> complainSuspect = [
  {'title': 'Смена тематики', 'subtitle': 'Изменилось название мероприятия, начали появляться материалы на другую тему'},
  {'title': 'Организатор взломан', 'subtitle': 'Появляются странные материалы, от организатора приходят необычные сообщения'},
];
final List<Map<String, String>> complainPhoto = [
  {'title': 'Порнография',},
  {'title': 'Детская эротика или порнография'},
  {'title': 'Другое'},
];

String formatDate(String inputDate) {
  // Разделяем строку по точкам
  List<String> parts = inputDate.split('.');
  if (parts.length != 3) return inputDate;

  String day = parts[0].padLeft(2, '0');
  String month = parts[1].padLeft(2, '0');
  String year = parts[2].padLeft(2, '0'); // Здесь задаём нужный год

  return '$day.$month.$year';
}

String formatDuration(String startTime, String endTime) {
  final now = DateTime.now();
  final start = DateTime.parse('${now.toIso8601String().substring(0, 10)}T$startTime');
  final end = DateTime.parse('${now.toIso8601String().substring(0, 10)}T$endTime');

  final duration = end.difference(start);

  if (duration.isNegative) return 'Некорректное время';

  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;

  if (hours == 0) {
    return '$minutes мин';
  }else if(hours == 1 && minutes ==0){
    return '60 мин';
  }
   else {
    return '$hours ч ${minutes.toString().padLeft(2, '0')} мин';
  }
}
const API = 'http://93.183.81.104';

String normalizePhone(String input) {
  return input.replaceAll(RegExp(r'[^\d+]'), '');
}
const hintTextStyleEdit = TextStyle(fontFamily:'Inter',fontSize: 14,fontWeight: FontWeight.w300,color: Colors.grey);
const titleTextStyleEdit = TextStyle(fontFamily: 'Inter',fontSize: 13,fontWeight: FontWeight.w400);
String getWeeklyRepeatOnlyWeekText(DateTime date) {
  const weekdays = {
    DateTime.monday: 'по понедельникам.',
    DateTime.tuesday: 'по вторникам.',
    DateTime.wednesday: 'по средам.',
    DateTime.thursday: 'по четвергам.',
    DateTime.friday: 'по пятницам.',
    DateTime.saturday: 'по субботам.',
    DateTime.sunday: 'по воскресеньям.',
  };

  return weekdays[date.weekday] ?? '';
}

String getWeeklyRepeatText(DateTime date) {
  const weekdays = {
    DateTime.monday: 'каждый понедельник',
    DateTime.tuesday: 'каждый вторник',
    DateTime.wednesday: 'каждую среду',
    DateTime.thursday: 'каждый четверг',
    DateTime.friday: 'каждую пятницу',
    DateTime.saturday: 'каждую субботу',
    DateTime.sunday: 'каждое воскресенье',
  };

  return weekdays[date.weekday] ?? '';
}

String capitalize(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1);
}
String utcDate(String date){
    // Указываем формат входной строки
  DateFormat inputFormat = DateFormat('dd.MM.yyyy');
  DateTime dateTime = inputFormat.parse(date);

  // Выводим в формате "yyyy-MM-dd"
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String formatted = outputFormat.format(dateTime);
  return formatted;
}
String utcTime(String time){

List<String> parts = time.split(':');
int hour = int.parse(parts[0]);
int minute = int.parse(parts[1]);

// 2. Создадим DateTime (например, сегодняшняя дата)
DateTime now = DateTime.now().toUtc();
DateTime dateTimeUtc = DateTime.utc(
  now.year,
  now.month,
  now.day,
  hour,
  minute,
);

// 3. Преобразуем в ISO строку
String utcString = dateTimeUtc.toIso8601String();
String timeOnlyUtc = utcString.substring(11); 
return timeOnlyUtc;
}

String? getNextDateForWeekday(String? weekdayName) {
  final daysMap = {
    'Понедельник': DateTime.monday,
    'Вторник': DateTime.tuesday,
    'Среда': DateTime.wednesday,
    'Четверг': DateTime.thursday,
    'Пятница': DateTime.friday,
    'Суббота': DateTime.saturday,
    'Воскресенье': DateTime.sunday,
  };

  final now = DateTime.now();
  final targetWeekday = daysMap[weekdayName];

  if (targetWeekday == null) {
    throw ArgumentError('Неверное название дня недели: $weekdayName');
  }

  int daysUntil = (targetWeekday - now.weekday) % 7;
  if (daysUntil == 0) daysUntil = 7; // следующий, не сегодня

  final nextDate = now.add(Duration(days: daysUntil));

  // Форматируем в yyyy-MM-dd
  final formattedDate = "${nextDate.year.toString().padLeft(4, '0')}-"
      "${nextDate.month.toString().padLeft(2, '0')}-"
      "${nextDate.day.toString().padLeft(2, '0')}";

  return formattedDate;
}
