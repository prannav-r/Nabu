import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/data/local/models/student_profile.dart';
import 'package:offline_ai_tutor/data/local/models/lesson.dart';
import 'package:offline_ai_tutor/data/local/models/quiz.dart';
import 'package:offline_ai_tutor/data/local/models/progress.dart';

void main() {
  group('Unit 02 - SQLite Model Mapping Tests', () {
    test('StudentProfile model mapping and syncStatus', () {
      final profile = StudentProfile(
        id: 'student_1',
        name: 'Alex',
        createdAt: '2026-08-22T00:00:00Z',
        syncStatus: 'synced',
      );

      final map = profile.toMap();
      expect(map['id'], 'student_1');
      expect(map['name'], 'Alex');
      expect(map['sync_status'], 'synced');

      final fromMap = StudentProfile.fromMap(map);
      expect(fromMap.id, profile.id);
      expect(fromMap.name, profile.name);
      expect(fromMap.syncStatus, 'synced');
    });

    test('Lesson model mapping and completion tracking', () {
      final lesson = Lesson(
        id: 'lesson_1',
        title: 'Introduction to Science',
        description: 'Scientific method basics',
        content: 'Observation -> Hypothesis -> Experiment',
        orderIndex: 1,
        isCompleted: true,
        updatedAt: '2026-08-22T00:00:00Z',
        syncStatus: 'pending',
      );

      final map = lesson.toMap();
      expect(map['id'], 'lesson_1');
      expect(map['is_completed'], 1);
      expect(map['sync_status'], 'pending');

      final restored = Lesson.fromMap(map);
      expect(restored.isCompleted, true);
      expect(restored.orderIndex, 1);
      expect(restored.syncStatus, 'pending');
    });

    test('QuizQuestion and QuizAttempt mapping with JSON options', () {
      final question = QuizQuestion(
        id: 'q1',
        lessonId: 'lesson_1',
        questionText: 'What is 2+2?',
        options: ['3', '4', '5'],
        correctOptionIndex: 1,
      );

      final qMap = question.toMap();
      expect(qMap['options_json'], '["3","4","5"]');

      final restoredQ = QuizQuestion.fromMap(qMap);
      expect(restoredQ.options.length, 3);
      expect(restoredQ.options[1], '4');
      expect(restoredQ.correctOptionIndex, 1);

      final attempt = QuizAttempt(
        id: 'att_1',
        studentId: 'student_1',
        lessonId: 'lesson_1',
        score: 5,
        totalQuestions: 5,
        completedAt: '2026-08-22T00:00:00Z',
        syncStatus: 'pending',
      );

      final attMap = attempt.toMap();
      expect(attMap['score'], 5);
      expect(attMap['sync_status'], 'pending');

      final restoredAtt = QuizAttempt.fromMap(attMap);
      expect(restoredAtt.score, 5);
      expect(restoredAtt.syncStatus, 'pending');
    });

    test('StudentProgress mapping and calculations', () {
      final progress = StudentProgress(
        id: 'prog_1',
        studentId: 'student_1',
        lessonsCompleted: 2,
        totalLessons: 4,
        quizzesCompleted: 2,
        averageScore: 85.0,
        updatedAt: '2026-08-22T00:00:00Z',
        syncStatus: 'pending',
      );

      final map = progress.toMap();
      expect(map['lessons_completed'], 2);
      expect(map['average_score'], 85.0);

      final restored = StudentProgress.fromMap(map);
      expect(restored.lessonsCompleted, 2);
      expect(restored.totalLessons, 4);
      expect(restored.averageScore, 85.0);
    });
  });
}
