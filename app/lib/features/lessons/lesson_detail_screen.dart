import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/local/models/lesson.dart';
import '../../data/local/repositories/lesson_repository.dart';
import '../../data/local/repositories/progress_repository.dart';

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
                  ? 'Lesson marked as completed! Progress updated locally.'
                  : 'Lesson marked as incomplete.',
            ),
            backgroundColor: _currentLesson.isCompleted
                ? AppColors.success
                : AppColors.textSecondary,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentLesson.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
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
                  Text(
                    _currentLesson.isCompleted
                        ? 'Completed (Offline Saved)'
                        : 'Not completed yet',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _currentLesson.isCompleted
                          ? AppColors.success
                          : AppColors.textSecondary,
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
                fontSize: 15,
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
                      ? 'Mark as Incomplete'
                      : 'Mark Lesson as Completed',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          ],
        ),
      ),
    );
  }
}
