import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateUtils {
  static DateTime convertToLocalTime(String dateStr, String timeWithOffsetStr) {
    String dateTimeStr = '${dateStr}T$timeWithOffsetStr';
    return DateTime.parse(dateTimeStr).toLocal();
  }

  static String formatEventTime(
      DateTime date, String timeStart, String timeEnd, bool isOnline) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd.MM.yyyy');

    final startTime =
        DateTime.parse('${date.toIso8601String().split('T')[0]}T$timeStart')
            .toLocal();
    final endTime =
        DateTime.parse('${date.toIso8601String().split('T')[0]}T$timeEnd')
            .toLocal();

    final localStartTime = isOnline ? startTime.toLocal() : startTime;
    final localEndTime = isOnline ? endTime.toLocal() : endTime;

    return '${dateFormat.format(date)} | ${timeFormat.format(localStartTime)}–${timeFormat.format(localEndTime)}';
  }

  static String formatEventDate(
      DateTime date, String timeStart, bool isOnline) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd.MM.yyyy');

    final timeRange = timeStart.split('–'); // или '-', если такой дефис
    final startTimeStr = timeRange.first.trim();
    final endTimeStr = timeRange.last.trim();
    // '17:43'
    final startTime =
        DateTime.parse('${date.toIso8601String().split('T')[0]}T$startTimeStr');

    final localTime = isOnline ? startTime.toLocal() : startTime;

    final endTime =
        DateTime.parse('${date.toIso8601String().split('T')[0]}T$endTimeStr');

    final localEndTime = isOnline ? endTime.toLocal() : endTime;

    return '${dateFormat.format(date)} | ${timeFormat.format(localTime)} - ${timeFormat.format(localEndTime)}';
  }
}

String formattedTimestamp(DateTime createdAt,
    [bool timeOnly = false, bool meridiem = false]) {
  DateTime now = DateTime.now();
  createdAt = createdAt.toLocal();

  if (timeOnly || datesHaveSameDay(now, createdAt)) {
    return DateFormat('HH:mm', 'ru').format(createdAt);
  }

  if (isYesterday(createdAt)) {
    return meridiem
        ? 'Вчера ${DateFormat('hh:mm a', 'ru').format(createdAt)}'
        : 'Вчера ${DateFormat('HH:mm', 'ru').format(createdAt)}';
  }

  if (createdAt.year == now.year) {
    return meridiem
        ? DateFormat('d MMM, hh:mm a', 'ru').format(createdAt)
        : DateFormat('d MMM, HH:mm', 'ru').format(createdAt);
  }

  return meridiem
      ? DateFormat('y MMM d, hh:mm a', 'ru').format(createdAt)
      : DateFormat('y MMM d, HH:mm', 'ru').format(createdAt);
}

bool datesHaveSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return datesHaveSameDay(date, yesterday);
}
