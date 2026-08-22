import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/data/local/models/quiz.dart';

void main() {
  group('Unit 05 - Offline Quizzes Scoring & Attempt Tests', () {
    test('Calculates score and creates QuizAttempt with pending syncStatus', () {
      final questions = [
        const QuizQuestion(
          id: 'q1',
          lessonId: 'lesson_1',
          questionText: 'Q1',
          options: ['A', 'B', 'C', 'D'],
          correctOptionIndex: 1,
        ),
        const QuizQuestion(
          id: 'q2',
          lessonId: 'lesson_1',
          questionText: 'Q2',
          options: ['A', 'B', 'C', 'D'],
          correctOptionIndex: 0,
        ),
      ];

      final userAnswers = {0: 1, 1: 0}; // Both correct

      int score = 0;
      for (int i = 0; i < questions.length; i++) {
        if (userAnswers[i] == questions[i].correctOptionIndex) {
          score++;
        }
      }

      expect(score, 2);

      final attempt = QuizAttempt(
        id: 'attempt_123',
        studentId: 'student_1',
        lessonId: 'lesson_1',
        score: score,
        totalQuestions: questions.length,
        completedAt: '2026-08-22T02:00:00Z',
        syncStatus: 'pending',
      );

      expect(attempt.score, 2);
      expect(attempt.totalQuestions, 2);
      expect(attempt.syncStatus, 'pending');
    });
  });
}
