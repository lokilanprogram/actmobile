import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/similiar_users_model.dart';
import 'package:dio/dio.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/profile_model.dart';
import 'package:http/http.dart' as http;

class ProfileApi {
  Dio dio = Dio();
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
Future<ProfileEventModels?> getProfileListEvents() async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.get(
    Uri.parse('$API/api/v1/users/events/my'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
     return ProfileEventModels.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}

Future<List<SimiliarUsersModel>?> getSimiliarUsers() async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.get(
    Uri.parse('$API/api/v1/users/similar'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => SimiliarUsersModel.fromJson(json))
          .toList();
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}

Future<EventModel?> getProfileEvent(String eventId) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.get(
    Uri.parse('$API/api/v1/events/$eventId'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
     return EventModel.fromJson(jsonDecode(response.body));
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
  "city": profileModel.city,
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
  Future<bool> updateProfilePicture(String imagePath) async {
    MultipartFile multipartFile;
    final accessToken = await storage.read(
      key: accessStorageToken,
    );
   final file = File(imagePath);
        final bytes = file.readAsBytesSync();
        final type = file.path.split('.').last;
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: file.path.split('/').last,
          contentType: DioMediaType('image', type)
          
        );
   final formData = FormData.fromMap({
          'file': multipartFile
        });

    final response = await dio.post(
     '$API/api/v1/users/profile/photo',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
          'Authorization': 'Bearer $accessToken'
        },
      ),
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Error: ${response.statusCode}');
  }
}