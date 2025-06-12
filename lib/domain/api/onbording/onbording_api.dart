import 'dart:convert';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/list_onbording_model.dart';
import 'package:http/http.dart' as http;
class OnbordingApi {
  final storage = SecureStorageService();
  
   Future<ListOnbordingModel?> getOnbording() async {
  final response = await http.get(
    Uri.parse('$API/api/v1/onboarding'),
    headers: {
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    return ListOnbordingModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
}
Future<bool> saveOnbording(List<String> listId) async {
  final accessToken = await storage.getAccessToken();
  final response = await http.post(
    Uri.parse('$API/api/v1/onboarding/categories'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
    body: jsonEncode(<String,dynamic>{
      "category_ids": listId
    })
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Error: ${response.body}');
  }
}
}