import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/data/local/models/lesson.dart';
import 'package:offline_ai_tutor/data/local/models/progress.dart';

void main() {
  group('Unit 03 - Lessons and Progress Logic Tests', () {
    test('Toggle lesson completion updates state and syncStatus', () {
      final lesson = Lesson(
        id: 'lesson_2',
        title: 'The Solar System',
        description: 'Planets and stars',
        content: 'Content about solar system',
        orderIndex: 2,
        isCompleted: false,
        updatedAt: '2026-08-22T00:00:00Z',
        syncStatus: 'synced',
      );

      expect(lesson.isCompleted, false);

      final completed = lesson.copyWith(
        isCompleted: true,
        updatedAt: '2026-08-22T01:00:00Z',
        syncStatus: 'pending',
      );

      expect(completed.isCompleted, true);
      expect(completed.syncStatus, 'pending');
      expect(completed.updatedAt, '2026-08-22T01:00:00Z');
    });

    test('Progress calculation correctly updates with completed lessons ratio', () {
      final initialProgress = StudentProgress(
        id: 'prog_student_1',
        studentId: 'student_1',
        lessonsCompleted: 0,
        totalLessons: 4,
        quizzesCompleted: 0,
        averageScore: 0.0,
        updatedAt: '2026-08-22T00:00:00Z',
        syncStatus: 'synced',
      );

      expect(initialProgress.lessonsCompleted / initialProgress.totalLessons, 0.0);

      final updatedProgress = initialProgress.copyWith(
        lessonsCompleted: 2,
        quizzesCompleted: 1,
        averageScore: 80.0,
        syncStatus: 'pending',
      );

      expect(updatedProgress.lessonsCompleted / updatedProgress.totalLessons, 0.5);
      expect(updatedProgress.averageScore, 80.0);
      expect(updatedProgress.syncStatus, 'pending');
    });
  });
}
