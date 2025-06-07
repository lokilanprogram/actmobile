import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

Future<void> downloadAndSaveImage(String imageUrl, Function(String message) onResult) async {
  try {
    // // Разрешения: Android 13+ использует Permission.photos, остальные — Permission.storage
    // bool hasPermission = false;

    // if (Platform.isAndroid) {
    //   final androidInfo = await Permission.storage.status;
    //   if (androidInfo.isDenied || androidInfo.isPermanentlyDenied) {
    //     final result = await Permission.storage.request();
    //     hasPermission = result.isDenied;
    //   } else {
    //     hasPermission = true;
    //   }
    // } else if (Platform.isIOS) {
    //   final result = await Permission.photos.request();
    //   hasPermission = result.isGranted;
    // }

    // if (!hasPermission) {
    //   onResult('Нет доступа к памяти');
    //   return;
    // }

    // Загружаем изображение
    final response = await Dio().get<List<int>>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    // Сохраняем во временный файл
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/downloaded_image.jpg';
    final file = File(filePath);
    await file.writeAsBytes(response.data!);

    // Сохраняем в галерею
    final saved = await GallerySaver.saveImage(file.path);
    if (saved == true) {
      onResult('Сохранено в галерею');
    } else {
      onResult('Не удалось сохранить');
    }
  } catch (e) {
    onResult('Ошибка: $e');
  }
}
