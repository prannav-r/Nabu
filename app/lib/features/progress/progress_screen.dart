import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';
import '../../data/local/models/lesson.dart';
import '../../data/local/models/progress.dart';
import '../../data/local/models/quiz.dart';
import '../../data/local/repositories/lesson_repository.dart';
import '../../data/local/repositories/progress_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import '../sync/services/client_sync_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressRepository _progressRepo = ProgressRepository();
  final QuizRepository _quizRepo = QuizRepository();
  final LessonRepository _lessonRepo = LessonRepository();
  final ClientSyncService _syncService = ClientSyncService();

  StudentProgress? _progress;
  List<Lesson> _lessons = [];
  List<QuizAttempt> _attempts = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prog = await _progressRepo.recalculateAndSave('student_1');
      final lessons = await _lessonRepo.getAllLessons();
      final atts = await _quizRepo.getAttemptsForStudent('student_1');

      setState(() {
        _progress = prog;
        _lessons = lessons;
        _attempts = atts;
      });
    } catch (_) {
      // Fallback
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _triggerManualSync() async {
    setState(() {
      _isSyncing = true;
    });

    final result = await _syncService.performSync(studentId: 'student_1');

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppColors.success : AppColors.warning,
          duration: const Duration(seconds: 3),
        ),
      );

      await _loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPendingSync = _attempts.any((a) => a.syncStatus == 'pending') ||
        (_progress?.syncStatus == 'pending');

    SyncStatus status = SyncStatus.offline;
    if (_isSyncing) {
      status = SyncStatus.syncing;
    } else if (!hasPendingSync) {
      status = SyncStatus.onlineSynced;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Learning Progress'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: OfflineStatusIndicator(status: status),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProgress,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSummaryHeroCard(),
                  const SizedBox(height: 16),
                  _buildSyncCard(hasPendingSync),
                  const SizedBox(height: 20),
                  _buildTopicBreakdownSection(),
                  const SizedBox(height: 20),
                  _buildRecentQuizScoresSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryHeroCard() {
    final completed = _progress?.lessonsCompleted ?? 0;
    final total = _progress?.totalLessons ?? (_lessons.isNotEmpty ? _lessons.length : 4);
    final avgScore = _progress?.averageScore ?? 0.0;
    final progressFraction = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Curriculum Mastery',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${(progressFraction * 100).toInt()}% Done',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progressFraction,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Completed',
                    value: '$completed / $total',
                    subtitle: 'Lessons',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Average Score',
                    value: '${avgScore.toStringAsFixed(0)}%',
                    subtitle: 'From quizzes',
                    icon: Icons.star_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Quizzes Taken',
                    value: '${_attempts.length}',
                    subtitle: 'Attempts',
                    icon: Icons.assignment_turned_in_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topic Completion Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._lessons.map((lesson) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: Icon(
                lesson.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: lesson.isCompleted ? AppColors.success : AppColors.textSecondary,
                size: 22,
              ),
              title: Text(
                lesson.title,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: lesson.isCompleted
                      ? AppColors.success.withAlpha(20)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: lesson.isCompleted ? AppColors.success : AppColors.border,
                  ),
                ),
                child: Text(
                  lesson.isCompleted ? 'Completed' : 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: lesson.isCompleted ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentQuizScoresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Quiz Activity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        if (_attempts.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No quiz attempts recorded yet. Start any quiz to track your mastery offline!',
                style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ..._attempts.map((attempt) {
            final percentage = (attempt.score / (attempt.totalQuestions > 0 ? attempt.totalQuestions : 1)) * 100;
            final isPassed = percentage >= 60;

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPassed ? AppColors.success.withAlpha(20) : AppColors.warning.withAlpha(20),
                  child: Icon(
                    isPassed ? Icons.check : Icons.refresh,
                    color: isPassed ? AppColors.success : AppColors.warning,
                    size: 20,
                  ),
                ),
                title: Text(
                  attempt.lessonId.replaceAll('lesson_', 'Lesson ').replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  attempt.syncStatus == 'synced' ? '✓ Synced' : '• Saved locally (offline)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: attempt.syncStatus == 'synced' ? AppColors.textSecondary : AppColors.warning,
                  ),
                ),
                trailing: Text(
                  '${attempt.score}/${attempt.totalQuestions} (${percentage.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? AppColors.primary : AppColors.warning,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSyncCard(bool hasPendingSync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(
              hasPendingSync ? Icons.cloud_queue_rounded : Icons.cloud_done_rounded,
              color: hasPendingSync ? AppColors.warning : AppColors.success,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cloud Synchronization',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasPendingSync
                        ? 'Pending changes saved locally.'
                        : 'All progress is fully synchronized.',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _isSyncing ? null : _triggerManualSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                _isSyncing ? 'Syncing...' : 'Sync',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
