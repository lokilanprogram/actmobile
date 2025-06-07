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
