import 'dart:convert';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/auth_codes_model.dart';
import 'package:acti_mobile/data/models/token_model.dart';
import 'package:http/http.dart' as http;


class AuthApi {
Future<TokenModel?> authRefreshToken() async {
  final refreshToken = await storage.read(key: refreshStorageToken);
  if(refreshToken != null){
    final response = await http.post(
    Uri.parse('$API/api/v1/auth/refresh-token'),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(<String, dynamic>{'refresh_token': refreshToken}),
  );
   if (response.statusCode == 200) {
    final resultToken = TokenModel.fromJson(jsonDecode(response.body));
    await writeAuthTokens(resultToken.accessToken, resultToken.refreshToken);
    return resultToken;
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}
 Future<AuthCodesModel?> authRegister(String phone) async {
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
    return AuthCodesModel.fromDetail(detail);
  } else {
    throw Exception('Error: ${response.body}');
  }
}
 Future<TokenModel?> authVerify(String phone, String smsCode, String phoneCode) async {
  final response = await http.post(
    Uri.parse('$API/api/v1/auth/verify'),
    headers: {
      "Content-Type": "application/json",
    },
    body: jsonEncode(<String, dynamic>{
      "phone": phone,
  "code": smsCode,
  "call_last_digits": phoneCode
    }),
  );

  if (response.statusCode == 200) {
    return TokenModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
}
}