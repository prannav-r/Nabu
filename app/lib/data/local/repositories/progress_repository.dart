import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../models/progress.dart';

class ProgressRepository {
  final AppDatabase _appDb;

  ProgressRepository({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase();

  Future<StudentProgress?> getProgress(String studentId) async {
    final db = await _appDb.database;
    if (db != null) {
      try {
        final maps = await db.query(
          'student_progress',
          where: 'student_id = ?',
          whereArgs: [studentId],
          limit: 1,
        );
        if (maps.isNotEmpty) {
          return StudentProgress.fromMap(maps.first);
        }
      } catch (_) {}
    }
    return AppDatabase.memProgress;
  }

  Future<void> updateProgress(StudentProgress progress) async {
    AppDatabase.memProgress = progress;

    final db = await _appDb.database;
    if (db != null) {
      try {
        await db.insert(
          'student_progress',
          progress.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } catch (_) {}
    }
  }

  Future<StudentProgress> recalculateAndSave(String studentId) async {
    final allLessons = AppDatabase.memLessons;
    final totalLessons = allLessons.length;
    final lessonsCompleted = allLessons.where((l) => l.isCompleted).length;

    final studentAttempts = AppDatabase.memAttempts.where((a) => a.studentId == studentId).toList();
    final quizzesCompleted = studentAttempts.length;

    double averageScore = 0.0;
    if (quizzesCompleted > 0) {
      double totalRatio = 0.0;
      for (final att in studentAttempts) {
        if (att.totalQuestions > 0) {
          totalRatio += (att.score / att.totalQuestions);
        }
      }
      averageScore = ((totalRatio / quizzesCompleted) * 100).roundToDouble();
    }

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
