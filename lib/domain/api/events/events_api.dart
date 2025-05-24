import 'dart:convert';
import 'dart:io';
import 'package:acti_mobile/data/models/alter_event_model.dart';
import 'package:acti_mobile/data/models/mapbox_reverse_model.dart';
import 'package:acti_mobile/data/models/profile_event_model.dart';
import 'package:acti_mobile/data/models/searched_events_model.dart';
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
  Future<OrganizedEventModel?> getProfileEvent(String eventId) async {
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
     return OrganizedEventModel.fromJson(jsonDecode(response.body));
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
 Future<bool?> deletePhotoEvent(String eventId,String photoUrl) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){
    final response = await http.delete(
    Uri.parse('$API/api/v1/events/$eventId/photo'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
    body: jsonEncode(<String,dynamic>{
      "photo_url": photoUrl
    })
  );
   if (response.statusCode == 200) {
      return true;
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return false;
}

 Future<SearchedEventsModel?> searchEventsOnMap(double latitude, double longitude) async {
  final accessToken = await storage.read(key: accessStorageToken);
  if(accessToken != null){

    final queryParameters = {
  'latitude': latitude.toString(),
  'longitude': longitude.toString(),
  'limit':100.toString(),
  'radius':100.toString()
};
    final response = await http.get(
    Uri.parse('$API/api/v1/events/map').replace(queryParameters: queryParameters),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $accessToken'
    },
  );
   if (response.statusCode == 200) {
      return SearchedEventsModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
  }
  return null;
}

Future<bool?> alterEvent({
  required AlterEventModel alterEvent,
  required bool isCreated
}) async {
  final accessToken = await storage.read(key: accessStorageToken);
  FormData formData;
  List<MultipartFile> photos = [];
  Response response;

  for (var photo in alterEvent.images) {
    if(!photo.contains('http://93.183.81.104')){
        final file = File(photo);
            final bytes = file.readAsBytesSync();
           final type = file.path.split('.').last;
            final multipartFile = MultipartFile.fromBytes(
              bytes,
              filename: file.path.split('/').last,
        contentType: DioMediaType('image', type),
            );
            photos.add(multipartFile);
    }
  }
  if(!isCreated){
    for(var photo in alterEvent.deletedImages){
   await EventsApi().deletePhotoEvent(alterEvent.id!, photo);
  }
  }

 formData = FormData.fromMap({
      'title':alterEvent.title,
      'description':alterEvent.description,
      'type':alterEvent.type,
      'address':alterEvent.isOnline? null: alterEvent.address,
      'date_start':alterEvent.isRecurring? alterEvent.recurringDay : alterEvent.dateStart,
      'time_start':alterEvent.timeStart.substring(0,8),
      'time_end':alterEvent.timeEnd.substring(0,8),
      'price':alterEvent.price!= null? alterEvent.price.toString() : '0',
      'create_group_chat':alterEvent.isGroupChat.toString(),
      'restrictions':[
        alterEvent.is18plus ? 'isAdults': 'noAdults',
        alterEvent.isOnline ? 'isOnline': 'Offline',
        alterEvent.isKidsAllowed ? 'isKidsAllowed': 'isKidsNotAllowed',
        alterEvent.isUnlimited ? 'isUnlimited': 'noUnlimited',
        alterEvent.withAnimals ? 'withAnimals': 'notWithAnimals',
      ],
      'category_id':alterEvent.categoryId,
      'latitude':alterEvent.selectedAddressModel?.latitude,
      'longitude':alterEvent.selectedAddressModel?.longitude,
      'is_recurring':alterEvent.isRecurring.toString(),
      'update_recurring':alterEvent.isRecurring.toString(),
      'slots':alterEvent.isUnlimited? 0:alterEvent.slots.toString(),
      'photos':photos,
        });
    
 
  try{
    if(isCreated){
      response = await dio.post(
    '$API/api/v1/events',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      },
    ),
  );
  }else{
      response = await dio.put(
    '$API/api/v1/events/${alterEvent.id}',
    data: formData,
    options: Options(
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      },
    ),
  );
  }
    if (response.statusCode == 200 || response.statusCode == 201) {
    print(response.data);
    return true;
  } else {
    throw Exception('Failed to create event: ${response.statusCode} ${response.data}');
  }
  }on DioException catch(e){
    throw Exception('Error: ${e.response!.data['detail']}');
  }

}

 Future<MapboxReverseModel> getMapBoxAddress(String latitude, String longitude) async {
 final response = await http.get(
    Uri.parse('https://api.mapbox.com/search/geocode/v6/reverse?longitude=$latitude&latitude=$longitude&access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg'),
    headers: {
      "Content-Type": "application/json",
    },
  );
   if (response.statusCode == 200) {
      return MapboxReverseModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Error: ${response.body}');
  }
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