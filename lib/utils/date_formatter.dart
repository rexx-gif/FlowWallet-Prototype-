import 'package:intl/intl.dart';

class DateFormatter {
  static String formatToDayMonthYear(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatToMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final aDate = DateTime(date.year, date.month, date.day);

    if (aDate == today) {
      return 'Hari ini, ${formatTime(date)}';
    } else if (aDate == yesterday) {
      return 'Kemarin, ${formatTime(date)}';
    } else {
      return '${DateFormat('dd MMM').format(date)}, ${formatTime(date)}';
    }
  }
}
