import 'dart:convert';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsNotificationsProvider extends ChangeNotifier {
  bool notificationsEnabled = false;
  final storage = SecureStorageService();

  Future<void> loadProfile() async {
    final accessToken = await storage.getAccessToken();
    final response = await Dio().get('$API/api/v1/users/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ));
    notificationsEnabled = response.data['notifications_enabled'];
    notifyListeners();
  }

  Future<void> changeNotificationSettings({required bool enabled}) async {
    final accessToken = await storage.getAccessToken();
    if (accessToken == null) throw Exception('Нет accessToken');
    final response = await http.put(
      Uri.parse('$API/api/v1/users/settings/notifications'),
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $accessToken'
      },
      body: jsonEncode({'enabled': enabled}),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка уведомлений: ${response.body}');
    }
    notificationsEnabled = enabled;
    notifyListeners();
  }
}
