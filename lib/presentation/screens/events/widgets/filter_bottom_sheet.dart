import 'package:flutter/material.dart';
import 'package:acti_mobile/configs/colors.dart';
import 'package:acti_mobile/presentation/screens/events/providers/filter_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:acti_mobile/presentation/screens/profile/my_events/create/map_picker/map_picker_screen.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:acti_mobile/presentation/widgets/time_range_picker_dialog.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:geotypes/geotypes.dart';
import 'package:http/http.dart' as http;
import 'package:acti_mobile/data/models/mapbox_model.dart' as mapbox;
import 'package:acti_mobile/data/models/local_address_model.dart';
import 'package:acti_mobile/data/models/all_events_model.dart' as events;
import 'dart:convert';
import 'package:acti_mobile/domain/api/events/events_api.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class TimeRange {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeRange(this.startTime, this.endTime);
}

class FilterBottomSheet extends StatefulWidget {
  final geolocator.Position? currentPosition;
  final Function() onApplyFilters;

  const FilterBottomSheet({
    super.key,
    this.currentPosition,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with WidgetsBindingObserver {
  final TextEditingController _priceMinController = TextEditingController();
  final TextEditingController _priceMaxController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  List<mapbox.Feature> _suggestions = [];
  bool _isLoading = false;
  List<events.Category> _categories = [];
  bool _isLoadingCategories = false;
  Position? _currentMapPosition;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    WidgetsBinding.instance.addObserver(this);
    if (widget.currentPosition != null) {
      _currentMapPosition = Position(
        widget.currentPosition!.longitude,
        widget.currentPosition!.latitude,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _priceMinController.dispose();
    _priceMaxController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FocusScope.of(context).unfocus();
    }
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final categories = await EventsApi().getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Ошибка загрузки категорий: $e');
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _searchLocation(String place) async {
    if (place.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$place.json'
          '?language=ru&country=ru&types=place'
          '&access_token=pk.eyJ1IjoiYWN0aSIsImEiOiJjbWE5d2NnZm0xa2w3MmxzZ3J4NmF6YnlzIn0.ZugUX9QGcByj0HzVtbJVgg';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final results = mapbox.MapBoxModel.fromJson(jsonDecode(response.body));
        setState(() {
          _suggestions = results.features;
        });
      } else {
        throw Exception('Ошибка: ${response.body}');
      }
    } catch (e) {
      print('Ошибка поиска: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<TimeRange?> _showTimeRangeDialog(BuildContext context,
      {TimeOfDay? initialStart, TimeOfDay? initialEnd}) async {
    final List<TimeOfDay> hours =
        List.generate(25, (i) => TimeOfDay(hour: i, minute: 0));
    int? startIdx;
    int? endIdx;
    if (initialStart != null)
      startIdx = hours.indexWhere((h) => h.hour == initialStart.hour);
    if (initialEnd != null)
      endIdx = hours.indexWhere((h) => h.hour == initialEnd.hour);
    if (startIdx == -1) startIdx = null;
    if (endIdx == -1) endIdx = null;

    return await showDialog<TimeRange>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.all(16),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Время',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 0,
                        childAspectRatio: 2.2,
                      ),
                      itemCount: hours.length,
                      itemBuilder: (context, idx) {
                        final isSelected = startIdx != null &&
                            endIdx != null &&
                            idx >= startIdx! &&
                            idx <= endIdx!;
                        final isEdge = idx == startIdx || idx == endIdx;
                        return GestureDetector(
                          onTap: () {
                            if (startIdx == null ||
                                (startIdx != null && endIdx != null)) {
                              setState(() {
                                startIdx = idx;
                                endIdx = null;
                              });
                            } else if (startIdx != null && endIdx == null) {
                              if (idx < startIdx!) {
                                setState(() {
                                  endIdx = startIdx;
                                  startIdx = idx;
                                });
                              } else {
                                setState(() {
                                  endIdx = idx;
                                });
                              }
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isEdge
                                      ? mainBlueColor
                                      : mainBlueColor.withOpacity(0.2))
                                  : Colors.transparent,
                              borderRadius: isEdge
                                  ? BorderRadius.circular(8)
                                  : BorderRadius.zero,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              hours[idx].format(context),
                              style: TextStyle(
                                color: isSelected
                                    ? (isEdge ? Colors.white : Colors.black)
                                    : Colors.black,
                                fontWeight: isEdge
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          onPressed: (startIdx != null &&
                                  endIdx != null &&
                                  startIdx! <= endIdx!)
                              ? () {
                                  Navigator.of(context).pop(TimeRange(
                                      hours[startIdx!], hours[endIdx!]));
                                }
                              : null,
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showPeriodPickerDialog(
      BuildContext context, FilterProvider filterProvider) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    DateTime startDate = filterProvider.selectedDateFrom ?? now;
    DateTime endDate = filterProvider.selectedDateTo ?? now;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.all(16),
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: 340,
                height: 410,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 320,
                      child: CalendarDatePicker2(
                        config: CalendarDatePicker2Config(
                          calendarType: CalendarDatePicker2Type.range,
                          firstDayOfWeek: 1,
                          weekdayLabels: [
                            'ПН',
                            'ВТ',
                            'СР',
                            'ЧТ',
                            'ПТ',
                            'СБ',
                            'ВС'
                          ],
                          controlsHeight: 70,
                          daySplashColor: Colors.transparent,
                          disableModePicker: true,
                          weekdayLabelTextStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          modePickersGap: 10,
                          controlsTextStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          lastMonthIcon: Icon(Icons.chevron_left,
                              color: Colors.black, size: 28),
                          nextMonthIcon: Icon(Icons.chevron_right,
                              color: Colors.black, size: 28),
                          selectedDayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          selectedRangeDayTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          selectedDayHighlightColor: mainBlueColor,
                          selectedRangeHighlightColor:
                              mainBlueColor.withOpacity(0.5),
                          dayBorderRadius: BorderRadius.circular(8),
                          todayTextStyle: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          disabledDayTextStyle: const TextStyle(
                            color: Colors.grey,
                          ),
                          dayTextStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        value: [startDate, endDate],
                        onValueChanged: (dates) {
                          if (dates.length == 2) {
                            setState(() {
                              startDate = dates[0] ?? startDate;
                              endDate = dates[1] ?? endDate;
                            });
                          }
                        },
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainBlueColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            filterProvider.updateDateFilter('period',
                                from: startDate, to: endDate);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Сохранить',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return GestureDetector(
          onTap: _hideKeyboard,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Фильтры',
                      style: TextStyle(
                        fontFamily: 'Gilroy',
                        color: authBlueColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            filterProvider.resetFilters();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: authBlueColor,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text(
                            'Сбросить',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Город
                        Text('Город (населённый пункт)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 45,
                                child: TextFormField(
                                  onChanged: (value) {
                                    if (value.isNotEmpty &&
                                        filterProvider.selectedLocationType ==
                                            'current') {
                                      filterProvider.updateLocationType('');
                                    }
                                    _searchLocation(value);
                                  },
                                  maxLines: 1,
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      fillColor: Colors.grey[200],
                                      filled: true,
                                      border: OutlineInputBorder(
                                          gapPadding: 0,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide.none),
                                      hintText: 'Введите город',
                                      hintStyle: TextStyle(
                                          fontFamily: 'Gilroy',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400)),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (_isLoading)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    color: mainBlueColor,
                                    strokeWidth: 1.2,
                                  )),
                                )
                              else if (_suggestions.isNotEmpty)
                                Container(
                                  constraints: BoxConstraints(maxHeight: 160),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: _suggestions.length,
                                    itemBuilder: (context, index) {
                                      final city = _suggestions[index];
                                      return ListTile(
                                        dense: true,
                                        title: Text(city.placeNameRu!,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'Gilroy')),
                                        onTap: () {
                                          final parts =
                                              city.placeNameRu?.split(', ');
                                          if (parts!.length == 6) {
                                            _cityController.text =
                                                'г. ${parts[2]}';
                                          } else {
                                            _cityController.text =
                                                city.placeNameRu!;
                                          }
                                          filterProvider.updateCityFilter(
                                              _cityController.text);
                                          // Создаем LocalAddressModel с координатами выбранного города
                                          filterProvider.updateLocationFilter(
                                            'city',
                                            address: LocalAddressModel(
                                              address: _cityController.text,
                                              latitude: city.center!.last,
                                              longitude: city.center!.first,
                                              properties: null,
                                            ),
                                          );
                                          filterProvider
                                              .updateLocationType('city');
                                          setState(() {
                                            _suggestions = [];
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Дата
                        Text('Дата',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Animated Date Segment Bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // "Сегодня" segment
                                  GestureDetector(
                                    onTap: () {
                                      filterProvider.updateDateFilter('today');
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.easeInBack,
                                      decoration: BoxDecoration(
                                        color:
                                            filterProvider.selectedDateFilter ==
                                                    'today'
                                                ? mainBlueColor
                                                : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Сегодня',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: filterProvider
                                                      .selectedDateFilter ==
                                                  'today'
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // "На этой неделе" segment
                                  GestureDetector(
                                    onTap: () {
                                      filterProvider
                                          .updateDateFilter('this_week');
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.easeInBack,
                                      decoration: BoxDecoration(
                                        color:
                                            filterProvider.selectedDateFilter ==
                                                    'this_week'
                                                ? mainBlueColor
                                                : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'На этой неделе',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: filterProvider
                                                      .selectedDateFilter ==
                                                  'this_week'
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // "На выходных" segment
                                  GestureDetector(
                                    onTap: () {
                                      filterProvider
                                          .updateDateFilter('weekend');
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 100),
                                      curve: Curves.easeInBack,
                                      decoration: BoxDecoration(
                                        color:
                                            filterProvider.selectedDateFilter ==
                                                    'weekend'
                                                ? mainBlueColor
                                                : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 8.0),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'На выходных',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: filterProvider
                                                      .selectedDateFilter ==
                                                  'weekend'
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // "Период" Chip
                            GestureDetector(
                              onTap: () async {
                                await _showPeriodPickerDialog(
                                    context, filterProvider);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: filterProvider.selectedDateFilter ==
                                          'period'
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                alignment: Alignment.center,
                                child: Text(
                                  'Период',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: filterProvider.selectedDateFilter ==
                                            'period'
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (filterProvider.selectedDateFilter == 'period' &&
                            (filterProvider.selectedDateFrom != null ||
                                filterProvider.selectedDateTo != null))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Выбран период: ${filterProvider.selectedDateFrom != null ? DateFormat('dd.MM.yyyy').format(filterProvider.selectedDateFrom!) : ''} - ${filterProvider.selectedDateTo != null ? DateFormat('dd.MM.yyyy').format(filterProvider.selectedDateTo!) : ''}',
                              style: TextStyle(
                                color: mainBlueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Время
                        Text('Время',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 10,
                          children: [
                            // "День" segment
                            GestureDetector(
                              onTap: () {
                                filterProvider.updateTimeFilter('day');
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color:
                                      filterProvider.selectedTimeFilter == 'day'
                                          ? mainBlueColor
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  'День',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: filterProvider.selectedTimeFilter ==
                                            'day'
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // "Вечер" segment
                            GestureDetector(
                              onTap: () {
                                filterProvider.updateTimeFilter('evening');
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.selectedTimeFilter ==
                                          'evening'
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  'Вечер',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: filterProvider.selectedTimeFilter ==
                                            'evening'
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // "Период" segment
                            GestureDetector(
                              onTap: () async {
                                final TimeRange? picked =
                                    await _showTimeRangeDialog(
                                  context,
                                  initialStart:
                                      filterProvider.selectedTimeFrom != null
                                          ? TimeOfDay(
                                              hour: int.parse(filterProvider
                                                  .selectedTimeFrom!
                                                  .split(':')[0]),
                                              minute: 0)
                                          : null,
                                  initialEnd:
                                      filterProvider.selectedTimeTo != null
                                          ? TimeOfDay(
                                              hour: int.parse(filterProvider
                                                  .selectedTimeTo!
                                                  .split(':')[0]),
                                              minute: 0)
                                          : null,
                                );
                                if (picked != null) {
                                  filterProvider.updateTimeFilter(
                                    'period',
                                    from:
                                        '${picked.startTime.format(context)}:00',
                                    to: '${picked.endTime.format(context)}:00',
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.selectedTimeFilter ==
                                          'period'
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  'Период',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: filterProvider.selectedTimeFilter ==
                                            'period'
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (filterProvider.selectedTimeFilter == 'period' &&
                            (filterProvider.selectedTimeFrom != null ||
                                filterProvider.selectedTimeTo != null))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Выбран период: ${filterProvider.selectedTimeFrom ?? ''} - ${filterProvider.selectedTimeTo ?? ''}',
                              style: TextStyle(
                                color: mainBlueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Локация
                        Text('Место',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 10,
                          children: [
                            // "Текущее местоположение" segment
                            GestureDetector(
                              onTap: () {
                                if (_cityController.text.isNotEmpty) {
                                  _cityController.clear();
                                  filterProvider.updateCityFilter('');
                                }
                                filterProvider.updateLocationType('current');
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.selectedLocationType ==
                                          'current'
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Text(
                                  'Текущее местоположение',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        filterProvider.selectedLocationType ==
                                                'current'
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // "Точка на карте" segment
                            GestureDetector(
                              onTap: () async {
                                if (_cityController.text.isNotEmpty) {
                                  _cityController.clear();
                                  filterProvider.updateCityFilter('');
                                }
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapPickerScreen(
                                      position: _currentMapPosition,
                                      address: '',
                                      isCreated: false,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  filterProvider.updateLocationFilter(
                                    'map',
                                    address: result,
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.selectedLocationType ==
                                          'map'
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                child: Text(
                                  'Точка на карте',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        filterProvider.selectedLocationType ==
                                                'map'
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // // "Метро" segment
                            // GestureDetector(
                            //   onTap: () {
                            //     if (_cityController.text.isNotEmpty) {
                            //       _cityController.clear();
                            //       filterProvider.updateCityFilter('');
                            //     }
                            //     filterProvider.updateLocationType('metro');
                            //   },
                            //   child: AnimatedContainer(
                            //     duration: Duration(milliseconds: 100),
                            //     curve: Curves.easeInBack,
                            //     decoration: BoxDecoration(
                            //       color: filterProvider.selectedLocationType ==
                            //               'metro'
                            //           ? mainBlueColor
                            //           : Colors.grey[200],
                            //       borderRadius: BorderRadius.circular(30.0),
                            //     ),
                            //     padding: EdgeInsets.symmetric(
                            //         vertical: 8.0, horizontal: 16.0),
                            //     child: Text(
                            //       'Метро',
                            //       style: TextStyle(
                            //         fontSize: 11,
                            //         color:
                            //             filterProvider.selectedLocationType ==
                            //                     'metro'
                            //                 ? Colors.white
                            //                 : Colors.black,
                            //         fontWeight: FontWeight.w500,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                        // const SizedBox(height: 20),

                        // Радиус поиска
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Builder(builder: (context) {
                              final radiusValues = [0, 1, 3, 5, 10, 15, 20, 50];
                              final selectedIndex = radiusValues.indexOf(
                                  filterProvider.selectedRadius.round());
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  FlutterSlider(
                                    values: [selectedIndex.toDouble()],
                                    max: (radiusValues.length - 1).toDouble(),
                                    min: 0,
                                    handler: FlutterSliderHandler(
                                      decoration: BoxDecoration(),
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              mainBlueColor.withOpacity(0.9),
                                              mainBlueColor
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: mainBlueColor
                                                  .withOpacity(0.15),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    trackBar: FlutterSliderTrackBar(
                                      inactiveTrackBar: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      activeTrackBar: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            mainBlueColor,
                                            mainBlueColor.withOpacity(0.6),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      activeTrackBarHeight: 12,
                                      inactiveTrackBarHeight: 12,
                                    ),
                                    handlerHeight: 22,
                                    handlerWidth: 36,
                                    selectByTap: true,
                                    jump: true,
                                    tooltip:
                                        FlutterSliderTooltip(disabled: true),
                                    step: FlutterSliderStep(step: 1),
                                    onDragging:
                                        (handlerIndex, lowerValue, upperValue) {
                                      final idx = lowerValue.round();
                                      filterProvider.updateLocationType(
                                        filterProvider.selectedLocationType ??
                                            'current',
                                        radius: radiusValues[idx].toDouble(),
                                      );
                                    },
                                  ),
                                  // const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: List.generate(radiusValues.length,
                                        (idx) {
                                      final isSelected = idx == selectedIndex;
                                      return Expanded(
                                        child: Center(
                                          child: Text(
                                            idx == 0
                                                ? '0 км'
                                                : '+${radiusValues[idx]} км',
                                            style: TextStyle(
                                              color: mainBlueColor,

                                              //     color: isSelected
                                              // ? mainBlueColor
                                              // : mainBlueColor
                                              //     .withOpacity(0.7),
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              fontSize: isSelected ? 10 : 8,
                                              // decoration: isSelected && idx != 0
                                              //     ? TextDecoration.underline
                                              //     : null,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),

                        if (filterProvider.selectedLocationType == 'map' &&
                            filterProvider.selectedMapAddressModel != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Выбрана точка: ${filterProvider.selectedMapAddressModel!.address}',
                              style: TextStyle(
                                color: mainBlueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        // const SizedBox(height: 20),

                        // Тип события

                        Row(
                          children: [
                            Text('Онлайн',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gilroy',
                                  color: authBlueColor,
                                )),
                            Checkbox(
                              value: filterProvider.isOnlineSelected,
                              onChanged: (value) {
                                filterProvider
                                    .updateOnlineStatus(value ?? false);
                              },
                              side: BorderSide(color: mainBlueColor, width: 2),
                              activeColor: mainBlueColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Цена
                        Text('Цена',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                filterProvider.updatePriceRange(isFree: true);
                              },
                              child: SizedBox(
                                width: 100,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color: filterProvider.isFreeSelected
                                        ? mainBlueColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Бесплатно',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: filterProvider.isFreeSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                filterProvider.updatePriceRange(isFree: false);
                              },
                              child: SizedBox(
                                width: 100,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color: !filterProvider.isFreeSelected
                                        ? mainBlueColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Платно',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: !filterProvider.isFreeSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!filterProvider.isFreeSelected) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _priceMinController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'От',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    filterProvider.updatePriceRange(min: value);
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _priceMaxController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'До',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    filterProvider.updatePriceRange(max: value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Возрастные ограничения
                        Text('Возрастные ограничения',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 10,
                          children: [
                            // "18+" segment
                            GestureDetector(
                              onTap: () {
                                final restrictions = List<String>.from(
                                    filterProvider.selectedAgeRestrictions);

                                if (restrictions.contains('isKidsNotAllowed')) {
                                  restrictions.remove('isKidsNotAllowed');
                                } else {
                                  restrictions.add('isKidsNotAllowed');
                                  restrictions.remove(
                                      'withKids'); // Удаляем 'Можно с детьми', если 18+ выбрано
                                }
                                filterProvider
                                    .updateAgeRestrictions(restrictions);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.selectedAgeRestrictions
                                          .contains('isKidsNotAllowed')
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  '18+',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: filterProvider
                                            .selectedAgeRestrictions
                                            .contains('isKidsNotAllowed')
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            // "Можно с детьми" segment
                            GestureDetector(
                              onTap: () {
                                final restrictions = List<String>.from(
                                    filterProvider.selectedAgeRestrictions);

                                if (restrictions.contains('withKids')) {
                                  restrictions.remove('withKids');
                                } else {
                                  restrictions.add('withKids');
                                  restrictions.remove(
                                      'isKidsNotAllowed'); // Удаляем '18+', если Можно с детьми выбрано
                                }
                                filterProvider
                                    .updateAgeRestrictions(restrictions);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.selectedAgeRestrictions
                                          .contains('withKids')
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: Text(
                                  'Можно с детьми',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: filterProvider
                                            .selectedAgeRestrictions
                                            .contains('withKids')
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Можно с животными

                        Row(
                          children: [
                            Text('Можно с животными',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gilroy',
                                  color: authBlueColor,
                                )),
                            Checkbox(
                              value: filterProvider.isAnimalsAllowedSelected,
                              onChanged: (value) {
                                filterProvider
                                    .updateAnimalsAllowed(value ?? false);
                              },
                              side: BorderSide(color: mainBlueColor, width: 2),
                              activeColor: mainBlueColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Количество людей
                        Text('Количество людей',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // "Без разницы"
                              GestureDetector(
                                onTap: () {
                                  filterProvider.updatePeopleFilter('any');
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color:
                                        filterProvider.selectedPeopleFilter ==
                                                'any'
                                            ? mainBlueColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Без разницы',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          filterProvider.selectedPeopleFilter ==
                                                  'any'
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // "до 15 человек"
                              GestureDetector(
                                onTap: () {
                                  filterProvider.updatePeopleFilter('upTo15');
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color:
                                        filterProvider.selectedPeopleFilter ==
                                                'upTo15'
                                            ? mainBlueColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'до 15 человек',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          filterProvider.selectedPeopleFilter ==
                                                  'upTo15'
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // "Свой вариант"
                              GestureDetector(
                                onTap: () {
                                  filterProvider.updatePeopleFilter('custom');
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color:
                                        filterProvider.selectedPeopleFilter ==
                                                'custom'
                                            ? mainBlueColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Диапазон',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          filterProvider.selectedPeopleFilter ==
                                                  'custom'
                                              ? Colors.white
                                              : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (filterProvider.selectedPeopleFilter == 'custom')
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'От',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      int? min = int.tryParse(value);
                                      filterProvider.updatePeopleRange(
                                        min,
                                        filterProvider.slotsMax,
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: 'До',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      int? max = int.tryParse(value);
                                      filterProvider.updatePeopleRange(
                                        filterProvider.slotsMin,
                                        max,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),

                        // Длительность
                        Text('Длительность',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // "Короткие 1-2 часа"
                              GestureDetector(
                                onTap: () {
                                  filterProvider.updateDurationFilter('short');
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color:
                                        filterProvider.selectedDurationFilter ==
                                                'short'
                                            ? mainBlueColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Короткие 1-2 часа',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: filterProvider
                                                  .selectedDurationFilter ==
                                              'short'
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // "3-5 часов"
                              GestureDetector(
                                onTap: () {
                                  filterProvider.updateDurationFilter('medium');
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color:
                                        filterProvider.selectedDurationFilter ==
                                                'medium'
                                            ? mainBlueColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '3-5 часов',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: filterProvider
                                                  .selectedDurationFilter ==
                                              'medium'
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // "Весь день"
                              GestureDetector(
                                onTap: () {
                                  filterProvider.updateDurationFilter('long');
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color:
                                        filterProvider.selectedDurationFilter ==
                                                'long'
                                            ? mainBlueColor
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Весь день',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: filterProvider
                                                  .selectedDurationFilter ==
                                              'long'
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Категории
                        Text('Категории',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Gilroy',
                              color: authBlueColor,
                            )),
                        if (_isLoadingCategories)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: mainBlueColor,
                                strokeWidth: 1.2,
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 5.0,
                            runSpacing: 10,
                            children: _categories.map((category) {
                              return GestureDetector(
                                onTap: () {
                                  final categoryIds = List<String>.from(
                                      filterProvider.selectedCategoryIds);
                                  if (categoryIds.contains(category.id)) {
                                    categoryIds.remove(category.id);
                                  } else {
                                    categoryIds.add(category.id);
                                  }
                                  filterProvider.updateCategoryIds(categoryIds);
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 100),
                                  curve: Curves.easeInBack,
                                  decoration: BoxDecoration(
                                    color: filterProvider.selectedCategoryIds
                                            .contains(category.id)
                                        ? mainBlueColor
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: filterProvider.selectedCategoryIds
                                              .contains(category.id)
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onApplyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: authBlueColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Применить фильтры',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
