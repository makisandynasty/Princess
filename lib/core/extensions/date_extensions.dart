import 'package:intl/intl.dart';

/// Extension methods on [DateTime] for common formatting operations.
extension DateTimeExtensions on DateTime {
  /// Returns "Today", "Tomorrow", or formatted date.
  String get relativeDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(year, month, day);

    if (date == today) return 'Today';
    if (date == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(this);
  }

  /// Returns formatted time string (e.g. "9:30 AM").
  String get formattedTime => DateFormat('h:mm a').format(this);

  /// Returns the day-of-year (1–366) for deterministic quote rotation.
  int get dayOfYear {
    final startOfYear = DateTime(year);
    return difference(startOfYear).inDays + 1;
  }

  /// Returns the time-of-day segment: 'Morning', 'Afternoon', or 'Evening'.
  String get daySegment {
    if (hour >= 5 && hour < 12) return 'Morning';
    if (hour >= 12 && hour < 17) return 'Afternoon';
    return 'Evening';
  }

  /// Whether this datetime is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
