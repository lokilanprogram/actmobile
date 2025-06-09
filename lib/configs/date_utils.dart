import 'package:intl/intl.dart';

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
        DateTime.parse('${date.toIso8601String().split('T')[0]}T$timeStart');
    final endTime =
        DateTime.parse('${date.toIso8601String().split('T')[0]}T$timeEnd');

    final localStartTime = isOnline ? startTime.toLocal() : startTime;
    final localEndTime = isOnline ? endTime.toLocal() : endTime;

    return '${dateFormat.format(date)} | ${timeFormat.format(localStartTime)}–${timeFormat.format(localEndTime)}';
  }

  static String formatEventDate(
      DateTime date, String timeStart, bool isOnline) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('dd.MM.yyyy');

    final timeRange = timeStart.split('–'); // или '-', если такой дефис
    final startTimeStr = timeRange.first.trim(); // '17:43'
    final startTime =
        DateTime.parse('${date.toIso8601String().split('T')[0]}T$startTimeStr');

    final localTime = isOnline ? startTime.toLocal() : startTime;

    return '${dateFormat.format(date)} | ${timeFormat.format(localTime)}';
  }

  static String formatDuration(String timeStart, String timeEnd) {
    final start = DateTime.parse('2000-01-01T$timeStart');
    final end = DateTime.parse('2000-01-01T$timeEnd');
    final difference = end.difference(start);

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return '($hoursч $minutesм)';
    } else {
      return '($minutesм)';
    }
  }
}

String formattedTimestamp(DateTime createdAt,
    [bool timeOnly = false, bool meridiem = false]) {
  DateTime now = DateTime.now();
  createdAt = createdAt.toLocal();

  // Если явно указано только время или это сегодня
  if (timeOnly || datesHaveSameDay(now, createdAt)) {
    return DateFormat('HH:mm').format(createdAt);
  }

  // Если это вчера
  if (isYesterday(createdAt)) {
    return meridiem
        ? 'Вчера ${DateFormat('hh:mm a').format(createdAt)}'
        : 'Вчера ${DateFormat('HH:mm').format(createdAt)}';
  }

  // Если в этом году
  if (createdAt.year == now.year) {
    return meridiem
        ? DateFormat('MMM d, hh:mm a').format(createdAt)
        : DateFormat('MMM d, HH:mm').format(createdAt);
  }

  // Если в прошлом году и ранее
  return meridiem
      ? DateFormat('y MMM d, hh:mm a').format(createdAt)
      : DateFormat('y MMM d, HH:mm').format(createdAt);
}

bool datesHaveSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return datesHaveSameDay(date, yesterday);
}
