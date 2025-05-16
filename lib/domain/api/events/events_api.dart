import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'package:acti_mobile/data/models/event_model.dart';
import 'package:http/http.dart' as http;

class EventsApi {
  Dio dio = Dio();
  Future<bool?> cancelActivity(String eventId,bool isRecurring) async {
    final queryParameter = {
  'cancel_recurring': isRecurring.toString(),
};
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.post(
    Uri.parse('$API/api/v1/events/$eventId/cancel').replace(queryParameters: queryParameter),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
    print(response.body);
    return true; 
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}
  Future<bool?> acceptUserOnActivity(String eventId, String userId,String status) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.post(
    Uri.parse('$API/api/v1/events/$eventId/users/$userId/status'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
    body: jsonEncode({
      "status": status
    })
  );
   if (response.statusCode == 200) {
    print(response.body);
    return true;
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
  Future<bool?> joinEvent(String eventId) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.post(
    Uri.parse('$API/api/v1/events/$eventId/join'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
      return true;
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return false;
}

 Future<bool?> reportUser(String? imagePath,String title, String userId) async {
    MultipartFile multipartFile;
    FormData formData;
    final accessToken = await storage.read(
      key: accessStorageToken,
    );
   if(imagePath!=null){
    final file = File(imagePath);
        final bytes = file.readAsBytesSync();
        final type = file.path.split('.').last;
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: file.path.split('/').last,
          contentType: DioMediaType('image', type)
          
        );
    formData = FormData.fromMap({
          'reason':title,
          'photo': multipartFile
        });
   }else{
      formData = FormData.fromMap({
          'reason':title,
        });
   }

    final response = await dio.post(
     '$API/api/v1/users/$userId/reports',
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


 Future<bool?> reportEvent(String? imagePath,String title, String? comment,String eventId) async {
    MultipartFile multipartFile;
    FormData formData;
    final accessToken = await storage.read(
      key: accessStorageToken,
    );
   if(imagePath!=null){
    final file = File(imagePath);
        final bytes = file.readAsBytesSync();
        final type = file.path.split('.').last;
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: file.path.split('/').last,
          contentType: DioMediaType('image', type)
          
        );
    formData = FormData.fromMap({
          'reason':title,
          'comment':comment,
          'file': multipartFile
        });
   }else{
      formData = FormData.fromMap({
          'reason':title,
          'comment':comment,
        });
   }

    final response = await dio.post(
     '$API/api/v1/events/$eventId/reports',
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

  Future<bool?> leaveEvent(String eventId) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.post(
    Uri.parse('$API/api/v1/events/$eventId/leave'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
      return true;
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return false;
}
}