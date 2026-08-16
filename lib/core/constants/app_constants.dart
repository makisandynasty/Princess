/// Application-wide constants.
abstract class AppConstants {
  /// Default snooze duration in minutes.
  static const int defaultSnoozeDurationMinutes = 10;

  /// Maximum photo cache size in MB (NFR-6).
  static const int defaultPhotoCacheLimitMB = 150;

  /// Google Drive backup filename.
  static const String driveBackupFilename = 'princes_backup.json';

  /// Google API scopes.
  static const List<String> googleScopes = [
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  /// Task categories.
  static const List<String> taskCategories = ['Work', 'Health', 'Personal'];

  /// Time-of-day segments for dashboard grouping (FR-1.4).
  static const int morningStartHour = 5;
  static const int afternoonStartHour = 12;
  static const int eveningStartHour = 17;

  /// Quote categories.
  static const List<String> quoteCategories = [
    'Motivational',
    'Sweet',
    'Mindfulness',
  ];
}
