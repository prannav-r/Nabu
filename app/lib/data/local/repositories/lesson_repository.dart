import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../models/lesson.dart';

class LessonRepository {
  final AppDatabase _appDb;

  LessonRepository({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase();

  Future<List<Lesson>> getAllLessons() async {
    final db = await _appDb.database;
    if (db != null) {
      try {
        final maps = await db.query('lessons', orderBy: 'order_index ASC');
        if (maps.isNotEmpty) {
          return maps.map((m) => Lesson.fromMap(m)).toList();
        }
      } catch (_) {}
    }
    // Return universal store
    final list = List<Lesson>.from(AppDatabase.memLessons);
    list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return list;
  }

  Future<Lesson?> getLessonById(String id) async {
    final db = await _appDb.database;
    if (db != null) {
      try {
        final maps = await db.query('lessons', where: 'id = ?', whereArgs: [id], limit: 1);
        if (maps.isNotEmpty) {
          return Lesson.fromMap(maps.first);
        }
      } catch (_) {}
    }
    try {
      return AppDatabase.memLessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLesson(Lesson lesson) async {
    // Update memory store
    final index = AppDatabase.memLessons.indexWhere((l) => l.id == lesson.id);
    if (index >= 0) {
      AppDatabase.memLessons[index] = lesson;
    } else {
      AppDatabase.memLessons.add(lesson);
    }

    final db = await _appDb.database;
    if (db != null) {
      try {
        await db.insert('lessons', lesson.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      } catch (_) {}
    }
  }

  Future<void> deleteLesson(String id) async {
    AppDatabase.memLessons.removeWhere((l) => l.id == id);
    AppDatabase.memQuestions.removeWhere((q) => q.lessonId == id);

    final db = await _appDb.database;
    if (db != null) {
      try {
        await db.delete('lessons', where: 'id = ?', whereArgs: [id]);
        await db.delete('quiz_questions', where: 'lesson_id = ?', whereArgs: [id]);
      } catch (_) {}
    }
  }

  Future<void> toggleLessonCompletion(String id) async {
    final lesson = await getLessonById(id);
    if (lesson == null) return;

    final updated = lesson.copyWith(
      isCompleted: !lesson.isCompleted,
      updatedAt: DateTime.now().toIso8601String(),
      syncStatus: 'pending',
    );
    await saveLesson(updated);
  }

  Future<int> getCompletedLessonCount() async {
    final lessons = await getAllLessons();
    return lessons.where((l) => l.isCompleted).length;
  }
}
