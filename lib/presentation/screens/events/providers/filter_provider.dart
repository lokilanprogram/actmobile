import 'package:flutter/foundation.dart';
import 'package:acti_mobile/data/models/local_address_model.dart';

class FilterProvider extends ChangeNotifier {
  String? selectedDateFilter;
  DateTime? selectedDateFrom;
  DateTime? selectedDateTo;
  String? selectedTimeFilter;
  String? selectedTimeFrom;
  String? selectedTimeTo;
  String? selectedLocationType;
  static const double baseRadius = 50.0;
  double selectedRadius = baseRadius;
  bool isOnlineSelected = false;
  String priceMinText = '';
  String priceMaxText = '';
  bool? isFreeSelected;
  List<String> selectedAgeRestrictions = [];
  bool isAnimalsAllowedSelected = false;
  bool isCompanySelected = false;
  bool? isOrganization;
  String? selectedDurationFilter;
  List<String> selectedCategoryIds = [];
  LocalAddressModel? selectedMapAddressModel;
  String cityFilterText = '';

  // Фильтр по количеству людей
  String selectedPeopleFilter = 'any'; // 'any', 'upTo15', 'custom'
  int? slotsMin;
  int? slotsMax;

  List<Map<String, dynamic>> metroSuggestionList = [];

  void updateDateFilter(String filter, {DateTime? from, DateTime? to}) {
    // Если нажали на уже выбранный фильтр - сбрасываем его
    if (selectedDateFilter == filter) {
      selectedDateFilter = null;
      selectedDateFrom = null;
      selectedDateTo = null;
      notifyListeners();
      return;
    }

    selectedDateFilter = filter;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case 'today':
        selectedDateFrom = today;
        selectedDateTo = today;
        break;
      case 'this_week':
        // Получаем номер дня недели (1-7, где 1 - понедельник)
        final weekday = now.weekday;
        // Вычисляем дату воскресенья
        final sunday = today.add(Duration(days: 7 - weekday));
        selectedDateFrom = today;
        selectedDateTo = sunday;
        break;
      case 'weekend':
        // Получаем номер дня недели (1-7, где 1 - понедельник)
        final weekday = now.weekday;
        // Вычисляем дату ближайшей субботы
        final daysUntilSaturday = (6 - weekday) % 7;
        final saturday = today.add(Duration(days: daysUntilSaturday));
        // Вычисляем дату воскресенья
        final sunday = saturday.add(const Duration(days: 1));
        selectedDateFrom = saturday;
        selectedDateTo = sunday;
        break;
      case 'period':
        selectedDateFrom = from;
        selectedDateTo = to;
        break;
      default:
        selectedDateFrom = null;
        selectedDateTo = null;
    }

    notifyListeners();
  }

  void updateTimeFilter(String filter, {String? from, String? to}) {
    // Если нажали на уже выбранный фильтр - сбрасываем его
    if (selectedTimeFilter == filter && filter != 'period') {
      selectedTimeFilter = null;
      selectedTimeFrom = null;
      selectedTimeTo = null;
      notifyListeners();
      return;
    }
    // Для периода не сбрасываем значения, если повторно выбираем "Период"
    selectedTimeFilter = filter;
    if (filter == 'period') {
      if (from != null) selectedTimeFrom = from;
      if (to != null) selectedTimeTo = to;
    } else {
      selectedTimeFrom = from;
      selectedTimeTo = to;
    }
    notifyListeners();
  }

  void updateLocationType(String type, {double? radius}) {
    selectedLocationType = type;
    if (radius != null && !isOnlineSelected) {
      selectedRadius = baseRadius + radius;
    }
    notifyListeners();
  }

  void updateOnlineStatus(bool isOnline) {
    isOnlineSelected = isOnline;
    if (isOnline) {
    } else {
      selectedRadius = baseRadius;
    }
    notifyListeners();
  }

  void updatePriceRange({String? min, String? max, bool? isFree}) {
    if (min != null) priceMinText = min;
    if (max != null) priceMaxText = max;
    if (isFree == true) {
      isFreeSelected = true;
      if (!selectedAgeRestrictions.contains('isUnlimited')) {
        selectedAgeRestrictions.add('isUnlimited');
      }
    } else if (isFree == false) {
      isFreeSelected = false;
      selectedAgeRestrictions.remove('isUnlimited');
    } else if (isFree == null) {
      isFreeSelected = null;
    }
    notifyListeners();
  }

  void updateAgeRestrictions(List<String> restrictions) {
    // Очищаем список перед добавлением новых ограничений
    selectedAgeRestrictions.clear();

    // Добавляем только уникальные значения
    for (var restriction in restrictions) {
      if (!selectedAgeRestrictions.contains(restriction)) {
        selectedAgeRestrictions.add(restriction);
      }
    }

    // Синхронизируем состояние чекбоксов
    isAnimalsAllowedSelected = selectedAgeRestrictions.contains('withAnimals');
    // isCompanySelected = selectedAgeRestrictions.contains('onlyCompany');

    // Если выбрано "Можно с детьми", добавляем withKids
    if (selectedAgeRestrictions.contains('isKidsAllowed')) {
      selectedAgeRestrictions.add('withKids');
    }

    notifyListeners();
  }

  void updateAnimalsAllowed(bool allowed) {
    isAnimalsAllowedSelected = allowed;
    if (allowed) {
      if (!selectedAgeRestrictions.contains('withAnimals')) {
        selectedAgeRestrictions.add('withAnimals');
      }
    } else {
      selectedAgeRestrictions.remove('withAnimals');
    }
    notifyListeners();
  }

  void updateCompanyAllowed(bool allowed) {
    isCompanySelected = allowed;
    isOrganization = allowed;
    notifyListeners();
  }

  void updateDurationFilter(String? filter) {
    // Если нажали на уже выбранный фильтр - сбрасываем его
    if (selectedDurationFilter == filter) {
      selectedDurationFilter = null;
      notifyListeners();
      return;
    }

    selectedDurationFilter = filter;
    notifyListeners();
  }

  void updateCategoryIds(List<String> ids) {
    selectedCategoryIds = ids;
    notifyListeners();
  }

  void updateCityFilter(String city) {
    cityFilterText = city;
    notifyListeners();
  }

  void updateLocationFilter(String type,
      {double? radius, LocalAddressModel? address}) {
    selectedLocationType = type;
    if (radius != null) selectedRadius = radius;
    if (address != null) selectedMapAddressModel = address;
    notifyListeners();
  }

  void updatePeopleFilter(String filter) {
    selectedPeopleFilter = filter;
    if (filter == 'any') {
      slotsMin = null;
      slotsMax = null;
    } else if (filter == 'upTo15') {
      slotsMin = null;
      slotsMax = 15;
    }
    notifyListeners();
  }

  void updatePeopleRange(int? min, int? max) {
    selectedPeopleFilter = 'custom';
    slotsMin = min;
    slotsMax = max;
    notifyListeners();
  }

  // Метод для получения типа события
  String? getEventType() {
    if (isOnlineSelected) {
      return 'online';
    }
    return null; // null означает, что type не будет передан
  }

  void resetFilters() {
    selectedDateFilter = null;
    selectedDateFrom = null;
    selectedDateTo = null;
    selectedTimeFilter = null;
    selectedTimeFrom = null;
    selectedTimeTo = null;
    selectedLocationType = null;
    selectedRadius = baseRadius;
    isOnlineSelected = false;
    priceMinText = '';
    priceMaxText = '';
    isFreeSelected = null;
    selectedAgeRestrictions.clear();
    isAnimalsAllowedSelected = false;
    isCompanySelected = false;
    isOrganization = null;
    selectedDurationFilter = null;
    selectedCategoryIds = [];
    selectedMapAddressModel = null;
    cityFilterText = '';
    selectedPeopleFilter = 'any';
    slotsMin = null;
    slotsMax = null;
    notifyListeners();
  }

  void setPriceMin(String value) {
    priceMinText = value;
    notifyListeners();
  }

  void setPriceMax(String value) {
    priceMaxText = value;
    notifyListeners();
  }

  void setPriceType(bool? isFree) {
    isFreeSelected = isFree;
    if (isFree == true) {
      if (!selectedAgeRestrictions.contains('isUnlimited')) {
        selectedAgeRestrictions.add('isUnlimited');
      }
    } else {
      selectedAgeRestrictions.remove('isUnlimited');
    }
    notifyListeners();
  }

  void updateMetroSuggestions(
      String query, List<Map<String, dynamic>> allStations) {
    if (query.isEmpty) {
      metroSuggestionList = allStations;
    } else {
      final lower = query.toLowerCase();
      final startsWith = allStations
          .where((s) => s['name'].toLowerCase().startsWith(lower))
          .toList();
      final contains = allStations
          .where((s) =>
              !s['name'].toLowerCase().startsWith(lower) &&
              s['name'].toLowerCase().contains(lower))
          .toList();
      metroSuggestionList = [...startsWith, ...contains];
    }
    notifyListeners();
  }

  void clearMetroSuggestions() {
    metroSuggestionList = [];
    notifyListeners();
  }
}
