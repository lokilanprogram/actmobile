
import 'dart:convert';

import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:http/http.dart' as http;

class ProfileApi {
  Future<ProfileModel?> getProfile() async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.get(
    Uri.parse('$API/api/v1/users/profile'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
     return ProfileModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}

 Future<ProfileModel?> updateProfile(ProfileModel profileModel) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.put(
    Uri.parse('$API/api/v1/users/profile'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
    body: jsonEncode(<String,dynamic>{
      "name": profileModel.name,
  "surname": profileModel.surname,
  "email": profileModel.email,
  "bio": profileModel.bio,
  "is_organization": profileModel.isOrganization,
  "categories": profileModel.categories.map((event)=>event.id).toList()
    })
  );
   if (response.statusCode == 200) {
     return profileModel;
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}
}