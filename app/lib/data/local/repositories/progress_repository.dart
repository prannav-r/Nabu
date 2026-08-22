import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../models/progress.dart';

class ProgressRepository {
  final AppDatabase _appDb;

  ProgressRepository({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase();

  Future<StudentProgress?> getProgress(String studentId) async {
    final db = await _appDb.database;
    final maps = await db.query(
      'student_progress',
      where: 'student_id = ?',
      whereArgs: [studentId],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return StudentProgress.fromMap(maps.first);
    }
    return null;
  }

  Future<void> updateProgress(StudentProgress progress) async {
    final db = await _appDb.database;
    await db.insert(
      'student_progress',
      progress.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StudentProgress> recalculateAndSave(String studentId) async {
    final db = await _appDb.database;

    // Count total lessons
    final totalLessonsRes = await db.rawQuery('SELECT COUNT(*) as c FROM lessons');
    final totalLessons = (totalLessonsRes.first['c'] as num).toInt();

    // Count completed lessons
    final completedLessonsRes = await db.rawQuery(
      'SELECT COUNT(*) as c FROM lessons WHERE is_completed = 1',
    );
    final lessonsCompleted = (completedLessonsRes.first['c'] as num).toInt();

    // Calculate quiz stats
    final quizStatsRes = await db.rawQuery(
      'SELECT COUNT(*) as c, AVG(CAST(score AS REAL) / CAST(total_questions AS REAL)) as avg_ratio FROM quiz_attempts WHERE student_id = ?',
      [studentId],
    );

    final quizzesCompleted = (quizStatsRes.first['c'] as num).toInt();
    final avgRatio = (quizStatsRes.first['avg_ratio'] as num?)?.toDouble() ?? 0.0;
    final averageScore = (avgRatio * 100.0).roundToDouble();

    final now = DateTime.now().toIso8601String();
    final progress = StudentProgress(
      id: 'prog_$studentId',
      studentId: studentId,
      lessonsCompleted: lessonsCompleted,
      totalLessons: totalLessons > 0 ? totalLessons : 4,
      quizzesCompleted: quizzesCompleted,
      averageScore: averageScore,
      updatedAt: now,
      syncStatus: 'pending',
    );

    await updateProgress(progress);
    return progress;
  }
}
