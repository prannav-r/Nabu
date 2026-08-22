import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../models/quiz.dart';

class QuizRepository {
  final AppDatabase _appDb;

  QuizRepository({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase();

  Future<List<QuizQuestion>> getQuestionsForLesson(String lessonId) async {
    final db = await _appDb.database;
    if (db != null) {
      try {
        final maps = await db.query('quiz_questions', where: 'lesson_id = ?', whereArgs: [lessonId]);
        if (maps.isNotEmpty) {
          return maps.map((m) => QuizQuestion.fromMap(m)).toList();
        }
      } catch (_) {}
    }
    return AppDatabase.memQuestions.where((q) => q.lessonId == lessonId).toList();
  }

  Future<List<QuizQuestion>> getAllQuestions() async {
    final db = await _appDb.database;
    if (db != null) {
      try {
        final maps = await db.query('quiz_questions');
        if (maps.isNotEmpty) {
          return maps.map((m) => QuizQuestion.fromMap(m)).toList();
        }
      } catch (_) {}
    }
    return List<QuizQuestion>.from(AppDatabase.memQuestions);
  }

  Future<void> saveQuestions(List<QuizQuestion> questions) async {
    for (final q in questions) {
      final idx = AppDatabase.memQuestions.indexWhere((item) => item.id == q.id);
      if (idx >= 0) {
        AppDatabase.memQuestions[idx] = q;
      } else {
        AppDatabase.memQuestions.add(q);
      }
    }

    final db = await _appDb.database;
    if (db != null) {
      try {
        for (final q in questions) {
          await db.insert('quiz_questions', q.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      } catch (_) {}
    }
  }

  Future<void> recordAttempt(QuizAttempt attempt) async {
    final idx = AppDatabase.memAttempts.indexWhere((a) => a.id == attempt.id);
    if (idx >= 0) {
      AppDatabase.memAttempts[idx] = attempt;
    } else {
      AppDatabase.memAttempts.insert(0, attempt);
    }

    final db = await _appDb.database;
    if (db != null) {
      try {
        await db.insert('quiz_attempts', attempt.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (_) {}
    }
  }

  Future<List<QuizAttempt>> getAttemptsForStudent(String studentId) async {
    final db = await _appDb.database;
    if (db != null) {
      try {
        final maps = await db.query(
          'quiz_attempts',
          where: 'student_id = ?',
          whereArgs: [studentId],
          orderBy: 'completed_at DESC',
        );
        if (maps.isNotEmpty) {
          return maps.map((m) => QuizAttempt.fromMap(m)).toList();
        }
      } catch (_) {}
    }
    return AppDatabase.memAttempts.where((a) => a.studentId == studentId).toList();
  }

  Future<List<QuizAttempt>> getPendingSyncAttempts() async {
    final db = await _appDb.database;
    if (db != null) {
      try {
        final maps = await db.query('quiz_attempts', where: 'sync_status = ?', whereArgs: ['pending']);
        if (maps.isNotEmpty) {
          return maps.map((m) => QuizAttempt.fromMap(m)).toList();
        }
      } catch (_) {}
    }
    return AppDatabase.memAttempts.where((a) => a.syncStatus == 'pending').toList();
  }

  Future<void> updateAttemptSyncStatus(String id, String status) async {
    final idx = AppDatabase.memAttempts.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      AppDatabase.memAttempts[idx] = AppDatabase.memAttempts[idx].copyWith(syncStatus: status);
    }

    final db = await _appDb.database;
    if (db != null) {
      try {
        await db.update('quiz_attempts', {'sync_status': status}, where: 'id = ?', whereArgs: [id]);
      } catch (_) {}
    }
  }
}
