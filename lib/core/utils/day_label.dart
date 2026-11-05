import 'package:intl/intl.dart';

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "Today", "Yesterday", otherwise "3 Nov 2026". [now] is injectable for tests.
String dayLabel(DateTime day, DateTime now) {
  if (isSameDay(day, now)) return 'Today';
  if (isSameDay(day, now.subtract(const Duration(days: 1)))) return 'Yesterday';
  return DateFormat('d MMM yyyy').format(day);
}

String timeLabel(DateTime time) => DateFormat('HH:mm').format(time);
