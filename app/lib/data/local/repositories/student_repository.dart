import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../models/student_profile.dart';

class StudentRepository {
  final AppDatabase _appDb;

  StudentRepository({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase();

  Future<StudentProfile?> getProfile(String id) async {
    final db = await _appDb.database;
    final maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return StudentProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<StudentProfile?> getDefaultProfile() async {
    final db = await _appDb.database;
    final maps = await db.query(
      'students',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return StudentProfile.fromMap(maps.first);
    }
    return null;
  }

  Future<void> saveProfile(StudentProfile profile) async {
    final db = await _appDb.database;
    await db.insert(
      'students',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
