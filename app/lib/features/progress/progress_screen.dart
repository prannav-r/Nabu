import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';
import '../../data/local/models/progress.dart';
import '../../data/local/models/quiz.dart';
import '../../data/local/repositories/progress_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ProgressRepository _progressRepo = ProgressRepository();
  final QuizRepository _quizRepo = QuizRepository();

  StudentProgress? _progress;
  List<QuizAttempt> _attempts = [];
  bool _isLoading = true;

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
      // Fallback offline
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPendingSync = _attempts.any((a) => a.syncStatus == 'pending') ||
        (_progress?.syncStatus == 'pending');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: OfflineStatusIndicator(status: SyncStatus.offline),
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 16),
                  _buildSyncStatusCard(hasPendingSync),
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
        child: Row(
          children: [
            Icon(
              hasPendingSync ? Icons.sync_problem : Icons.sync,
              color: hasPendingSync ? AppColors.warning : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Synchronization State',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasPendingSync
                        ? 'Pending records stored locally. Will synchronize automatically when connectivity is restored.'
                        : 'All local progress is synchronized.',
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
      ),
    );
  }
}
