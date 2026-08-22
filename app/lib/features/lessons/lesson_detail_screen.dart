import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/local/models/lesson.dart';
import '../../data/local/repositories/lesson_repository.dart';
import '../../data/local/repositories/progress_repository.dart';
import '../quiz/quiz_screen.dart';
import '../tutor/tutor_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback? onLessonUpdated;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    this.onLessonUpdated,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late Lesson _currentLesson;
  bool _isLoading = false;
  final LessonRepository _lessonRepo = LessonRepository();
  final ProgressRepository _progressRepo = ProgressRepository();

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.lesson;
  }

  Future<void> _toggleCompletion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updated = _currentLesson.copyWith(
        isCompleted: !_currentLesson.isCompleted,
        updatedAt: DateTime.now().toIso8601String(),
        syncStatus: 'pending',
      );

      await _lessonRepo.saveLesson(updated);
      await _progressRepo.recalculateAndSave('student_1');

      setState(() {
        _currentLesson = updated;
      });

      widget.onLessonUpdated?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _currentLesson.isCompleted
                  ? '🎉 Lesson marked as completed! Progress updated locally.'
                  : 'Lesson marked as incomplete.',
            ),
            backgroundColor: _currentLesson.isCompleted
                ? AppColors.success
                : AppColors.textSecondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDeleteLesson() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lesson?'),
        content: Text('Are you sure you want to delete "${_currentLesson.title}" and its quiz questions?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _lessonRepo.deleteLesson(_currentLesson.id);
      await _progressRepo.recalculateAndSave('student_1');
      widget.onLessonUpdated?.call();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${_currentLesson.title}".'),
            backgroundColor: AppColors.textSecondary,
          ),
        );
      }
    }
  }

  void _openLessonQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(initialLessonId: _currentLesson.id),
      ),
    );
  }

  void _askTutorAboutLesson() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TutorScreen(
          initialPrompt: 'Help me understand ${_currentLesson.title}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentLesson.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Lesson',
            onPressed: _confirmDeleteLesson,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentLesson.isCompleted
                    ? AppColors.success.withAlpha(25)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentLesson.isCompleted ? AppColors.success : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentLesson.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: _currentLesson.isCompleted
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _currentLesson.isCompleted
                          ? 'Completed (Saved Locally)'
                          : 'Not completed yet • Study below and tap Complete when done',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: _currentLesson.isCompleted
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentLesson.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentLesson.description,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 32, color: AppColors.border),
            Text(
              _currentLesson.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),

            // Completion Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleCompletion,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(
                        _currentLesson.isCompleted
                            ? Icons.check_box_outlined
                            : Icons.check_circle_outline,
                      ),
                label: Text(
                  _currentLesson.isCompleted
                      ? 'Completed ✓ (Tap to Mark Incomplete)'
                      : 'Mark Lesson as Completed ✓',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentLesson.isCompleted
                      ? AppColors.textSecondary
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Actions: Take Quiz & Ask AI Tutor
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openLessonQuiz,
                    icon: const Icon(Icons.quiz_outlined, size: 18),
                    label: const Text('Take Quiz'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _askTutorAboutLesson,
                    icon: const Icon(Icons.smart_toy_outlined, size: 18),
                    label: const Text('Ask AI Tutor'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
