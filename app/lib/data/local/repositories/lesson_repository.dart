import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../models/lesson.dart';

class LessonRepository {
  final AppDatabase _appDb;

  LessonRepository({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase();

  Future<List<Lesson>> getAllLessons() async {
    final db = await _appDb.database;
    final maps = await db.query(
      'lessons',
      orderBy: 'order_index ASC',
    );
    return maps.map((m) => Lesson.fromMap(m)).toList();
  }

  Future<Lesson?> getLessonById(String id) async {
    final db = await _appDb.database;
    final maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Lesson.fromMap(maps.first);
    }
    return null;
  }

  Future<void> markLessonComplete(String id) async {
    final db = await _appDb.database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'lessons',
      {
        'is_completed': 1,
        'updated_at': now,
        'sync_status': 'pending',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> saveLesson(Lesson lesson) async {
    final db = await _appDb.database;
    await db.insert(
      'lessons',
      lesson.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getCompletedLessonCount() async {
    final db = await _appDb.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM lessons WHERE is_completed = 1',
    );
    if (result.isNotEmpty) {
      return (result.first['count'] as num).toInt();
    }
    return 0;
  }
}
