import 'package:flutter/material.dart';

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