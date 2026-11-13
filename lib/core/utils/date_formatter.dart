import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _shortDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _fullDateTime = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

  static String formatShort(DateTime date) => _shortDate.format(date);
  static String formatFull(DateTime date) => _fullDateTime.format(date);
  static String formatTime(DateTime date) => _timeOnly.format(date);
  static String formatIso(DateTime date) => _isoDate.format(date);

  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final aDate = DateTime(date.year, date.month, date.day);

    if (aDate == today) {
      return 'Today, ${_timeOnly.format(date)}';
    } else if (aDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_timeOnly.format(date)}';
    }
    return _fullDateTime.format(date);
  }
}
