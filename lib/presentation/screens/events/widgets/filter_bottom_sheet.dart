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

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final TextEditingController _priceMinController = TextEditingController();
  final TextEditingController _priceMaxController = TextEditingController();

  // Dummy data for categories - replace with actual data from API if available
  final List<Map<String, dynamic>> _categoryFilters = [
    {
      "id": "35dae046-43a5-4044-b4b9-6a9bd359bf37",
      "name": "Спорт",
      "icon_path":
          "http://93.183.81.104/uploads/category_icons/30f9574b-2a6a-4c30-bb2b-398724982992.png"
    },
    {
      "id": "05b6b8df-99fd-4d61-9c26-03fcdae2f8af",
      "name": "Музыка",
      "icon_path":
          "http://93.183.81.104/uploads/category_icons/5321b770-2db9-4dc6-aeb5-4b2c8ed45472.png"
    },
    {
      "id": "f028eca7-b1ed-47f6-b7ca-fe79fb09ff10",
      "name": "Наука",
      "icon_path":
          "http://93.183.81.104/uploads/category_icons/6d17b161-b83c-4ca9-b7c6-541758e68ad5.png"
    },
    {
      "id": "ceb24aec-1cf1-46d0-8042-30eb052832f6",
      "name": "Семья",
      "icon_path":
          "http://93.183.81.104/uploads/category_icons/8045b3bf-8605-402f-88d4-977fc2870b35.png"
    },
    {
      "id": "6e27119e-c4ab-4aa1-82c1-729d67a32467",
      "name": "Еда",
      "icon_path":
          "http://93.183.81.104/uploads/category_icons/a7b16612-2080-47b0-be18-a71727b56b56.png"
    },
    {"id": "cat_concerts", "name": "Концерты"},
    {"id": "cat_exhibitions", "name": "Выставки и театры"},
    {"id": "cat_festivals", "name": "Фестивали"},
    {"id": "cat_sports_events", "name": "Спортивные мероприятия"},
    {"id": "cat_museums", "name": "Музеи"},
    {"id": "cat_children", "name": "Дети"},
    {"id": "cat_excursions", "name": "Экскурсии"},
    {"id": "cat_online", "name": "Онлайн активности"},
    {"id": "cat_board_games", "name": "Настолки"},
    {"id": "cat_animals", "name": "Животные"},
    {"id": "cat_master_classes", "name": "Мастер-классы"},
    {"id": "cat_out_of_town", "name": "За городом"},
    {"id": "cat_languages", "name": "Изучение языка"},
    {"id": "cat_photo_video", "name": "Фото и видео"}
  ];

  @override
  void dispose() {
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
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
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Сегодня',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            filterProvider.selectedDateFilter ==
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
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'На этой неделе',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            filterProvider.selectedDateFilter ==
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
                                    filterProvider.updateDateFilter('weekend');
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
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 8.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'На выходных',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            filterProvider.selectedDateFilter ==
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
                                  color:
                                      filterProvider.selectedTimeFilter == 'day'
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
                      Text('Локация',
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
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Текущее местоположение',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: filterProvider.selectedLocationType ==
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
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPickerScreen(
                                    position: widget.currentPosition != null
                                        ? Position(
                                            widget.currentPosition!.longitude,
                                            widget.currentPosition!.latitude,
                                          )
                                        : null,
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
                                color:
                                    filterProvider.selectedLocationType == 'map'
                                        ? mainBlueColor
                                        : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Точка на карте',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: filterProvider.selectedLocationType ==
                                          'map'
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // "Метро" segment
                          GestureDetector(
                            onTap: () {
                              filterProvider.updateLocationType('metro');
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInBack,
                              decoration: BoxDecoration(
                                color: filterProvider.selectedLocationType ==
                                        'metro'
                                    ? mainBlueColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Метро',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: filterProvider.selectedLocationType ==
                                          'metro'
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
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
                      const SizedBox(height: 20),

                      // Радиус поиска
                      if (filterProvider.selectedLocationType == 'current' ||
                          filterProvider.selectedLocationType == 'map')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Радиус поиска',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gilroy',
                                  color: authBlueColor,
                                )),
                            Slider(
                              value: filterProvider.selectedRadius,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label:
                                  '${filterProvider.selectedRadius.round()} км',
                              onChanged: (value) {
                                filterProvider.updateLocationType(
                                  filterProvider.selectedLocationType!,
                                  radius: value,
                                );
                              },
                            ),
                            Text(
                              '${filterProvider.selectedRadius.round()} км',
                              style: TextStyle(
                                color: mainBlueColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),

                      // Тип события
                      Text('Тип события',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gilroy',
                            color: authBlueColor,
                          )),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                filterProvider.updateOnlineStatus(false);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: !filterProvider.isOnlineSelected
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                alignment: Alignment.center,
                                child: Text(
                                  'Офлайн',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: !filterProvider.isOnlineSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                filterProvider.updateOnlineStatus(true);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.isOnlineSelected
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                alignment: Alignment.center,
                                child: Text(
                                  'Онлайн',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: filterProvider.isOnlineSelected
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                filterProvider.updatePriceRange(isFree: true);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.isFreeSelected
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0),
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
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                filterProvider.updatePriceRange(isFree: false);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: !filterProvider.isFreeSelected
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0),
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
                              if (restrictions.contains('isAdults')) {
                                restrictions.remove('isAdults');
                              } else {
                                restrictions.add('isAdults');
                              }
                              filterProvider
                                  .updateAgeRestrictions(restrictions);
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInBack,
                              decoration: BoxDecoration(
                                color: filterProvider.selectedAgeRestrictions
                                        .contains('isAdults')
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
                                  color: filterProvider.selectedAgeRestrictions
                                          .contains('isAdults')
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
                              if (restrictions.contains('isKidsAllowed')) {
                                restrictions.remove('isKidsAllowed');
                              } else {
                                restrictions.add('isKidsAllowed');
                              }
                              filterProvider
                                  .updateAgeRestrictions(restrictions);
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInBack,
                              decoration: BoxDecoration(
                                color: filterProvider.selectedAgeRestrictions
                                        .contains('isKidsAllowed')
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
                                  color: filterProvider.selectedAgeRestrictions
                                          .contains('isKidsAllowed')
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
                      Text('Можно с животными',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gilroy',
                            color: authBlueColor,
                          )),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                filterProvider.updateAnimalsAllowed(true);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color: filterProvider.isAnimalsAllowedSelected
                                      ? mainBlueColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                alignment: Alignment.center,
                                child: Text(
                                  'Да',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        filterProvider.isAnimalsAllowedSelected
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                filterProvider.updateAnimalsAllowed(false);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 100),
                                curve: Curves.easeInBack,
                                decoration: BoxDecoration(
                                  color:
                                      !filterProvider.isAnimalsAllowedSelected
                                          ? mainBlueColor
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                alignment: Alignment.center,
                                child: Text(
                                  'Нет',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        !filterProvider.isAnimalsAllowedSelected
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
                      const SizedBox(height: 20),

                      // Длительность
                      Text('Длительность',
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
                          // "Короткие 1-2 часа" segment
                          GestureDetector(
                            onTap: () {
                              filterProvider.updateDurationFilter('short');
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInBack,
                              decoration: BoxDecoration(
                                color: filterProvider.selectedDurationFilter ==
                                        'short'
                                    ? mainBlueColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Короткие 1-2 часа',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      filterProvider.selectedDurationFilter ==
                                              'short'
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // "3-5 часов" segment
                          GestureDetector(
                            onTap: () {
                              filterProvider.updateDurationFilter('medium');
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInBack,
                              decoration: BoxDecoration(
                                color: filterProvider.selectedDurationFilter ==
                                        'medium'
                                    ? mainBlueColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                '3-5 часов',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      filterProvider.selectedDurationFilter ==
                                              'medium'
                                          ? Colors.white
                                          : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          // "Весь день" segment
                          GestureDetector(
                            onTap: () {
                              filterProvider.updateDurationFilter('long');
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInBack,
                              decoration: BoxDecoration(
                                color: filterProvider.selectedDurationFilter ==
                                        'long'
                                    ? mainBlueColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                'Весь день',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      filterProvider.selectedDurationFilter ==
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
                      const SizedBox(height: 20),

                      // Категории
                      Text('Категории',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Gilroy',
                            color: authBlueColor,
                          )),
                      Wrap(
                        spacing: 5.0,
                        runSpacing: 10,
                        children: _categoryFilters.map((category) {
                          return GestureDetector(
                            onTap: () {
                              final categoryIds = List<String>.from(
                                  filterProvider.selectedCategoryIds);
                              if (categoryIds.contains(category['id'])) {
                                categoryIds.remove(category['id']);
                              } else {
                                categoryIds.add(category['id']);
                              }
                              filterProvider.updateCategoryIds(categoryIds);
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInBack,
                              decoration: BoxDecoration(
                                color: filterProvider.selectedCategoryIds
                                        .contains(category['id'])
                                    ? mainBlueColor
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Text(
                                category['name'],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: filterProvider.selectedCategoryIds
                                          .contains(category['id'])
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
                  child:
                      Text('Применить фильтры', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
