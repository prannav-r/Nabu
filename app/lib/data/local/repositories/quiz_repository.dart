import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../models/quiz.dart';

class QuizRepository {
  final AppDatabase _appDb;

  QuizRepository({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase();

  Future<List<QuizQuestion>> getQuestionsForLesson(String lessonId) async {
    final db = await _appDb.database;
    final maps = await db.query(
      'quiz_questions',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
    );
    return maps.map((m) => QuizQuestion.fromMap(m)).toList();
  }

  Future<List<QuizQuestion>> getAllQuestions() async {
    final db = await _appDb.database;
    final maps = await db.query('quiz_questions');
    return maps.map((m) => QuizQuestion.fromMap(m)).toList();
  }

  Future<void> recordAttempt(QuizAttempt attempt) async {
    final db = await _appDb.database;
    await db.insert(
      'quiz_attempts',
      attempt.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<QuizAttempt>> getAttemptsForStudent(String studentId) async {
    final db = await _appDb.database;
    final maps = await db.query(
      'quiz_attempts',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'completed_at DESC',
    );
    return maps.map((m) => QuizAttempt.fromMap(m)).toList();
  }

  Future<List<QuizAttempt>> getPendingSyncAttempts() async {
    final db = await _appDb.database;
    final maps = await db.query(
      'quiz_attempts',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
    return maps.map((m) => QuizAttempt.fromMap(m)).toList();
  }

  Future<void> updateAttemptSyncStatus(String id, String status) async {
    final db = await _appDb.database;
    await db.update(
      'quiz_attempts',
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
