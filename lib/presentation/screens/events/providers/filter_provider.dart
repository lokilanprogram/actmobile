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
  double selectedRadius = 50.0;
  bool isOnlineSelected = false;
  String priceMinText = '';
  String priceMaxText = '';
  bool isFreeSelected = false;
  List<String> selectedAgeRestrictions = [];
  bool isAnimalsAllowedSelected = false;
  String? selectedDurationFilter;
  List<String> selectedCategoryIds = [];
  LocalAddressModel? selectedMapAddressModel;
  String cityFilterText = '';

  // Фильтр по количеству людей
  String selectedPeopleFilter = 'any'; // 'any', 'upTo15', 'custom'
  int? slotsMin;
  int? slotsMax;

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
    if (selectedTimeFilter == filter) {
      selectedTimeFilter = null;
      selectedTimeFrom = null;
      selectedTimeTo = null;
      notifyListeners();
      return;
    }

    selectedTimeFilter = filter;
    selectedTimeFrom = from;
    selectedTimeTo = to;
    notifyListeners();
  }

  void updateLocationType(String type, {double? radius}) {
    selectedLocationType = type;
    if (radius != null) {
      selectedRadius = radius;
    }
    notifyListeners();
  }

  void updateOnlineStatus(bool isOnline) {
    isOnlineSelected = isOnline;
    notifyListeners();
  }

  void updatePriceRange({String? min, String? max, bool? isFree}) {
    if (min != null) priceMinText = min;
    if (max != null) priceMaxText = max;
    if (isFree != null) {
      isFreeSelected = isFree;
      if (isFree) {
        selectedAgeRestrictions.add('isUnlimited');
      } else {
        selectedAgeRestrictions.remove('isUnlimited');
      }
    }
    notifyListeners();
  }

  void updateAgeRestrictions(List<String> restrictions) {
    selectedAgeRestrictions = restrictions;
    notifyListeners();
  }

  void updateAnimalsAllowed(bool allowed) {
    isAnimalsAllowedSelected = allowed;
    if (allowed) {
      selectedAgeRestrictions.add('withAnimals');
    } else {
      selectedAgeRestrictions.remove('withAnimals');
    }
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

  void resetFilters() {
    selectedDateFilter = null;
    selectedDateFrom = null;
    selectedDateTo = null;
    selectedTimeFilter = null;
    selectedTimeFrom = null;
    selectedTimeTo = null;
    selectedLocationType = null;
    selectedRadius = 50.0;
    isOnlineSelected = false;
    priceMinText = '';
    priceMaxText = '';
    isFreeSelected = false;
    selectedAgeRestrictions = [];
    isAnimalsAllowedSelected = false;
    selectedDurationFilter = null;
    selectedCategoryIds = [];
    selectedMapAddressModel = null;
    cityFilterText = '';
    // Сброс фильтра по количеству людей
    selectedPeopleFilter = 'any';
    slotsMin = null;
    slotsMax = null;
    notifyListeners();
  }
}
