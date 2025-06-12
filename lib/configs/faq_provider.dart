import 'package:flutter/foundation.dart';
import 'package:acti_mobile/data/models/faq_model.dart';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'dart:developer' as developer;

class FaqProvider extends ChangeNotifier {
  List<FaqModel> _faqs = [];
  bool _isLoading = false;
  String? _error;
  int? _openedFaqIndex;

  List<FaqModel> get faqs => _faqs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get openedFaqIndex => _openedFaqIndex;

  void toggleFaq(int index) {
    _openedFaqIndex = _openedFaqIndex == index ? null : index;
    notifyListeners();
  }

  Future<void> loadFaqs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log('[FAQ] Начало загрузки FAQ', name: 'FAQ');
      final response = await EventsApi().getFaqs();
      developer.log('[FAQ] Получен ответ: ${response.length} вопросов',
          name: 'FAQ');

      _faqs = response;
      _error = null;
    } catch (e) {
      developer.log('[FAQ] Ошибка при загрузке: $e', name: 'FAQ');
      _error = e.toString();
      _faqs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
