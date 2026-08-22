import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../data/local/app_database.dart';
import '../../../data/local/repositories/lesson_repository.dart';
import '../../../data/local/repositories/progress_repository.dart';
import '../../../data/local/repositories/quiz_repository.dart';

class SyncResult {
  final bool success;
  final int syncedAttemptsCount;
  final int syncedLessonsCount;
  final String message;
  final String? syncedAt;

  const SyncResult({
    required this.success,
    this.syncedAttemptsCount = 0,
    this.syncedLessonsCount = 0,
    required this.message,
    this.syncedAt,
  });
}

class ClientSyncService {
  static ClientSyncService? _instance;
  final LessonRepository _lessonRepo;
  final QuizRepository _quizRepo;
  final ProgressRepository _progressRepo;
  final AppDatabase _appDb;

  String _backendUrl = 'http://10.0.2.2:8000'; // Default Android emulator host to localhost

  ClientSyncService._({
    LessonRepository? lessonRepo,
    QuizRepository? quizRepo,
    ProgressRepository? progressRepo,
    AppDatabase? appDb,
  })  : _lessonRepo = lessonRepo ?? LessonRepository(),
        _quizRepo = quizRepo ?? QuizRepository(),
        _progressRepo = progressRepo ?? ProgressRepository(),
        _appDb = appDb ?? AppDatabase();

  factory ClientSyncService({
    LessonRepository? lessonRepo,
    QuizRepository? quizRepo,
    ProgressRepository? progressRepo,
    AppDatabase? appDb,
  }) {
    _instance ??= ClientSyncService._(
      lessonRepo: lessonRepo,
      quizRepo: quizRepo,
      progressRepo: progressRepo,
      appDb: appDb,
    );
    return _instance!;
  }

  String get backendUrl => _backendUrl;
  set backendUrl(String url) {
    _backendUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<SyncResult> performSync({String studentId = 'student_1'}) async {
    try {
      final pendingAttempts = await _quizRepo.getPendingSyncAttempts();
      final allLessons = await _lessonRepo.getAllLessons();
      final pendingLessons = allLessons.where((l) => l.syncStatus == 'pending').toList();
      final progress = await _progressRepo.getProgress(studentId);

      if (pendingAttempts.isEmpty && pendingLessons.isEmpty && (progress == null || progress.syncStatus == 'synced')) {
        return const SyncResult(
          success: true,
          syncedAttemptsCount: 0,
          syncedLessonsCount: 0,
          message: 'All local records are already synchronized.',
        );
      }

      final payload = {
        'student_id': studentId,
        'attempts': pendingAttempts
            .map((a) => {
                  'client_id': a.id,
                  'lesson_id': a.lessonId,
                  'score': a.score,
                  'total_questions': a.totalQuestions,
                  'completed_at': a.completedAt,
                })
            .toList(),
        'lesson_progress': pendingLessons
            .map((l) => {
                  'lesson_id': l.id,
                  'is_completed': l.isCompleted,
                  'updated_at': l.updatedAt,
                })
            .toList(),
        'summary': progress != null
            ? {
                'lessons_completed': progress.lessonsCompleted,
                'total_lessons': progress.totalLessons,
                'quizzes_completed': progress.quizzesCompleted,
                'average_score': progress.averageScore,
                'updated_at': progress.updatedAt,
              }
            : null,
      };

      final uri = Uri.parse('$_backendUrl/sync');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Mark local attempts as synced in SQLite
        for (final attempt in pendingAttempts) {
          await _quizRepo.updateAttemptSyncStatus(attempt.id, 'synced');
        }

        // Mark local lessons as synced in SQLite
        final db = await _appDb.database;
        for (final lesson in pendingLessons) {
          await db.update(
            'lessons',
            {'sync_status': 'synced'},
            where: 'id = ?',
            whereArgs: [lesson.id],
          );
        }

        // Mark local progress summary as synced in SQLite
        if (progress != null) {
          await _progressRepo.updateProgress(progress.copyWith(syncStatus: 'synced'));
        }

        return SyncResult(
          success: true,
          syncedAttemptsCount: pendingAttempts.length,
          syncedLessonsCount: pendingLessons.length,
          syncedAt: decoded['synced_at'] as String?,
          message: 'Successfully synchronized with remote server.',
        );
      } else {
        return SyncResult(
          success: false,
          message: 'Server returned HTTP error ${response.statusCode}. Local records preserved.',
        );
      }
    } catch (e) {
      debugPrint('[ClientSyncService] Synchronization attempt error: $e');
      return SyncResult(
        success: false,
        message: 'Could not reach server. All local learning data remains safely preserved on device.',
      );
    }
  }
}
