import 'dart:convert';

class QuizQuestion {
  final String id;
  final String lessonId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  const QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'question_text': questionText,
      'options_json': jsonEncode(options),
      'correct_option_index': correctOptionIndex,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    List<String> parsedOptions = [];
    final rawOptions = map['options_json'];
    if (rawOptions is String) {
      final decoded = jsonDecode(rawOptions);
      if (decoded is List) {
        parsedOptions = decoded.map((e) => e.toString()).toList();
      }
    }
    return QuizQuestion(
      id: map['id'] as String,
      lessonId: map['lesson_id'] as String,
      questionText: map['question_text'] as String,
      options: parsedOptions,
      correctOptionIndex: (map['correct_option_index'] as num).toInt(),
    );
  }
}

class QuizAttempt {
  final String id;
  final String studentId;
  final String lessonId;
  final int score;
  final int totalQuestions;
  final String completedAt;
  final String syncStatus; // 'pending', 'syncing', 'synced'

  const QuizAttempt({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
    this.syncStatus = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'lesson_id': lessonId,
      'score': score,
      'total_questions': totalQuestions,
      'completed_at': completedAt,
      'sync_status': syncStatus,
    };
  }

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      lessonId: map['lesson_id'] as String,
      score: (map['score'] as num).toInt(),
      totalQuestions: (map['total_questions'] as num).toInt(),
      completedAt: map['completed_at'] as String,
      syncStatus: (map['sync_status'] as String?) ?? 'pending',
    );
  }

  QuizAttempt copyWith({
    String? id,
    String? studentId,
    String? lessonId,
    int? score,
    int? totalQuestions,
    String? completedAt,
    String? syncStatus,
  }) {
    return QuizAttempt(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      lessonId: lessonId ?? this.lessonId,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      completedAt: completedAt ?? this.completedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
