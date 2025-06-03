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
  double selectedRadius = 1.0;
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

  void updateDateFilter(String filter, {DateTime? from, DateTime? to}) {
    selectedDateFilter = filter;
    selectedDateFrom = from;
    selectedDateTo = to;
    notifyListeners();
  }

  void updateTimeFilter(String filter, {String? from, String? to}) {
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
    if (isFree != null) isFreeSelected = isFree;
    notifyListeners();
  }

  void updateAgeRestrictions(List<String> restrictions) {
    selectedAgeRestrictions = restrictions;
    notifyListeners();
  }

  void updateAnimalsAllowed(bool allowed) {
    isAnimalsAllowedSelected = allowed;
    notifyListeners();
  }

  void updateDurationFilter(String? filter) {
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

  void resetFilters() {
    selectedDateFilter = null;
    selectedDateFrom = null;
    selectedDateTo = null;
    selectedTimeFilter = null;
    selectedTimeFrom = null;
    selectedTimeTo = null;
    selectedLocationType = null;
    selectedRadius = 1.0;
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
    notifyListeners();
  }
}
 