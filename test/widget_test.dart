import 'package:flutter_test/flutter_test.dart';
import 'package:princes/features/tasks/domain/entities/task_entity.dart';

void main() {
  test('TaskEntity serialization test', () {
    final now = DateTime.now();
    final task = TaskEntity(
      id: 'task_123',
      title: 'Morning Routine',
      createdAt: now,
    );

    final json = task.toJson();
    final restored = TaskEntity.fromJson(json);

    expect(restored.id, 'task_123');
    expect(restored.title, 'Morning Routine');
  });
}
