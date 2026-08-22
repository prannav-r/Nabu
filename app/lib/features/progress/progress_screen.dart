import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';
import '../../data/local/models/progress.dart';
import '../../data/local/models/quiz.dart';
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
  final ClientSyncService _syncService = ClientSyncService();

  StudentProgress? _progress;
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
      final atts = await _quizRepo.getAttemptsForStudent('student_1');

      setState(() {
        _progress = prog;
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

      // Refresh progress and attempts state
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
        title: const Text('My Progress'),
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
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildSyncStatusCard(hasPendingSync),
                  const SizedBox(height: 16),
                  const Text(
                    'Recent Quiz Scores',
                    style: TextStyle(
                      fontSize: 18,
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
                          'No quiz attempts yet. Complete a quiz to track your scores offline!',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._attempts.map((a) => _buildScoreItem(a)),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final completed = _progress?.lessonsCompleted ?? 0;
    final total = _progress?.totalLessons ?? 4;
    final avgScore = _progress?.averageScore ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Learning Progress',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Lessons Completed',
                    value: '$completed / $total',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Average Score',
                    value: '${avgScore.toStringAsFixed(0)}%',
                    icon: Icons.star_outline,
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
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(QuizAttempt attempt) {
    final isSynced = attempt.syncStatus == 'synced';
    final percentage = (attempt.score / (attempt.totalQuestions > 0 ? attempt.totalQuestions : 1)) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(
          'Quiz: ${attempt.lessonId.replaceAll("_", " ").toUpperCase()}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          isSynced ? "Synced with server" : "Stored locally (pending sync)",
          style: TextStyle(
            fontSize: 12,
            color: isSynced ? AppColors.textSecondary : AppColors.warning,
          ),
        ),
        trailing: Text(
          '${attempt.score}/${attempt.totalQuestions} (${percentage.toStringAsFixed(0)}%)',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatusCard(bool hasPendingSync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasPendingSync ? Icons.cloud_queue_rounded : Icons.cloud_done_rounded,
                  color: hasPendingSync ? AppColors.warning : AppColors.success,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Synchronization',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasPendingSync
                            ? 'Pending records stored safely on device. Tap sync when connected to internet.'
                            : 'All local learning progress is fully synchronized.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _triggerManualSync,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.sync_rounded, size: 18),
                label: Text(_isSyncing ? 'Syncing...' : 'Sync Now with Cloud'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
