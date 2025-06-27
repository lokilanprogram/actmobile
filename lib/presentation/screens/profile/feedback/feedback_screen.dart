import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:acti_mobile/configs/constants.dart';
import 'package:acti_mobile/configs/storage.dart';
import 'dart:developer' as developer;
import 'package:toastification/toastification.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _controller = TextEditingController();
  XFile? _mediaFile;
  bool _isLoading = false;

  void _showMessage(String message, {bool isError = false}) {
    toastification.show(
      context: context,
      title: Text(message),
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.fillColored,
      autoCloseDuration: const Duration(seconds: 3),
      alignment: Alignment.topRight,
    );
  }

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _mediaFile = file;
      });
    }
  }

  Future<void> _sendFeedback() async {
    if (_controller.text.isEmpty) {
      _showMessage('Пожалуйста, введите текст отзыва', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      developer.log('Начало отправки отзыва', name: 'FEEDBACK');
      developer.log('Текст отзыва: ${_controller.text}', name: 'FEEDBACK');

      final accessToken = await SecureStorageService().getAccessToken();
      if (accessToken == null) {
        throw Exception('Токен доступа не найден');
      }
      developer.log('Токен доступа получен', name: 'FEEDBACK');

      final dio = Dio();
      final formData = FormData();

      // Добавляем текст отзыва
      formData.fields.add(MapEntry('description', _controller.text));
      developer.log('Текст добавлен в formData', name: 'FEEDBACK');

      // Добавляем изображение, если оно есть
      if (_mediaFile != null) {
        developer.log('Подготовка изображения: ${_mediaFile!.path}',
            name: 'FEEDBACK');
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(
            _mediaFile!.path,
            filename: _mediaFile!.name,
          ),
        ));
        developer.log('Изображение добавлено в formData', name: 'FEEDBACK');
      }

      developer.log('Отправка запроса на сервер...', name: 'FEEDBACK');
      final response = await dio.post(
        '$API/api/v1/admin/feedback',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => true,
        ),
      );

      developer.log('Получен ответ от сервера', name: 'FEEDBACK');
      developer.log('Статус код: ${response.statusCode}', name: 'FEEDBACK');
      developer.log('Тело ответа: ${response.data}', name: 'FEEDBACK');
      developer.log('Заголовки ответа: ${response.headers}', name: 'FEEDBACK');

      if (response.statusCode == 200) {
        developer.log('Отзыв успешно отправлен', name: 'FEEDBACK');
        _showMessage('Отзыв успешно отправлен');
        Navigator.of(context).pop();
      } else {
        final errorMessage = response.data is Map
            ? response.data['detail'] ?? 'Неизвестная ошибка'
            : 'Ошибка при отправке отзыва: ${response.statusCode}';
        developer.log('Ошибка сервера: $errorMessage', name: 'FEEDBACK');
        throw Exception(errorMessage);
      }
    } catch (e) {
      developer.log('Ошибка при отправке отзыва: $e',
          name: 'FEEDBACK', error: e);
      if (e is DioException) {
        developer.log('DioException details:', name: 'FEEDBACK');
        developer.log('Type: ${e.type}', name: 'FEEDBACK');
        developer.log('Message: ${e.message}', name: 'FEEDBACK');
        developer.log('Response: ${e.response?.data}', name: 'FEEDBACK');
      }
      _showMessage(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
      developer.log('Завершение процесса отправки отзыва', name: 'FEEDBACK');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Обратная связь',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w400,
              fontSize: 22,
            ),
          ),
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  controller: _controller,
                  maxLines: 5,
                  minLines: 4,
                  decoration: InputDecoration(
                    hintText: 'О чём бы вы хотели рассказать?',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Gilroy',
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: _pickMedia,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo,
                          color: Colors.grey[700], size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Прикрепить медиафайл',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontFamily: 'Gilroy',
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_mediaFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_mediaFile!.path),
                      height: 80,
                    ),
                  ),
                ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4293EF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _sendFeedback,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Отправить',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}
