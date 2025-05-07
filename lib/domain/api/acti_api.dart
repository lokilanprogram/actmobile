import 'dart:convert';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/data/models/auth_codes.dart';
import 'package:http/http.dart' as http;


class ActiApi {
 Future<AuthCodes?> authRegister(String phone) async {
  final response = await http.post(
    Uri.parse('$API/api/v1/auth/register'),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(<String, dynamic>{'phone': phone}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final detail = data['detail'] as String;
    return AuthCodes.fromDetail(detail);
  } else {
    throw Exception('Error: ${response.body}');
  }
}

}