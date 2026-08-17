import 'package:intl/intl.dart';

class AppDateTimeFormatter {
  static DateTime dateFormat(String time) {
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return DateTime(date.year, date.month, date.day);
  }

  static String timeDate(String time) {
    String timeView = '';
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    timeView = DateFormat('jm').format(date).toString();
    return timeView;
  }

  static String dateAndTime(String time) {
    String timeView = '';
    var date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(const Duration(days: 1));

    DateTime todayFormat = DateTime(today.year, today.month, today.day);
    DateTime yesterdayFormat =
        DateTime(yesterday.year, yesterday.month, yesterday.day);
    DateTime dateFormat = DateTime(date.year, date.month, date.day);

    if (dateFormat == todayFormat) {
      return timeView = 'Today';
    } else if (dateFormat == yesterdayFormat) {
      return timeView = 'Yesterday';
    } else if (date.year == today.year) {
      timeView = DateFormat('d-M').format(date).toString();
    } else {
      timeView = DateFormat('d-M-yyyy').format(date).toString();
    }
    return timeView;
  }
}
