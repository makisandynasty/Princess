/// Entity representing a recurring daily or weekly habit.
class HabitEntity {
  const HabitEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.iconName = 'favorite',
    this.colorHex = 0xFFF5C34A,
    this.targetDaysPerWeek = 7,
    this.completedDates = const [],
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final int colorHex;
  final int targetDaysPerWeek;

  /// ISO date strings 'YYYY-MM-DD' when the habit was completed.
  final List<String> completedDates;
  final DateTime createdAt;

  /// Check if completed on a specific day
  bool isCompletedOn(DateTime date) {
    final key = _formatDateKey(date);
    return completedDates.contains(key);
  }

  /// Calculate current continuous streak
  int get currentStreak {
    int streak = 0;
    DateTime check = DateTime.now();

    // If today is completed, start checking from today, else check if yesterday was done
    final todayKey = _formatDateKey(check);
    if (!completedDates.contains(todayKey)) {
      check = check.subtract(const Duration(days: 1));
    }

    while (true) {
      final key = _formatDateKey(check);
      if (completedDates.contains(key)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Calculate completion rate over the last 30 days
  double get monthlySuccessRate {
    int count = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final d = now.subtract(Duration(days: i));
      if (isCompletedOn(d)) count++;
    }
    return count / 30.0;
  }

  static String _formatDateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  HabitEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    int? colorHex,
    int? targetDaysPerWeek,
    List<String>? completedDates,
    DateTime? createdAt,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      targetDaysPerWeek: targetDaysPerWeek ?? this.targetDaysPerWeek,
      completedDates: completedDates ?? this.completedDates,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'colorHex': colorHex,
        'targetDaysPerWeek': targetDaysPerWeek,
        'completedDates': completedDates,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HabitEntity.fromJson(Map<String, dynamic> json) => HabitEntity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        iconName: json['iconName'] as String? ?? 'favorite',
        colorHex: json['colorHex'] as int? ?? 0xFFF5C34A,
        targetDaysPerWeek: json['targetDaysPerWeek'] as int? ?? 7,
        completedDates: (json['completedDates'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
