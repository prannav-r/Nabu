import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/local/models/lesson.dart';
import '../../data/local/repositories/lesson_repository.dart';
import 'lesson_detail_screen.dart';

class LessonsScreen extends StatefulWidget {
  final VoidCallback? onLessonUpdated;

  const LessonsScreen({super.key, this.onLessonUpdated});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final LessonRepository _lessonRepo = LessonRepository();
  List<Lesson> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var lessons = await _lessonRepo.getAllLessons();
      if (lessons.isEmpty) {
        lessons = [
          const Lesson(
            id: 'lesson_1',
            title: '1. Introduction to Science',
            description: 'Learn the scientific method, observation, and hypothesis testing.',
            content: 'Science is the systematic study of the natural world.',
            orderIndex: 1,
            isCompleted: true,
            updatedAt: '2026-08-22T00:00:00Z',
          ),
          const Lesson(
            id: 'lesson_2',
            title: '2. The Solar System',
            description: 'Explore planets, orbits, and celestial objects in our solar neighborhood.',
            content: 'Our solar system consists of the Sun and everything bound to it by gravity.',
            orderIndex: 2,
            isCompleted: false,
            updatedAt: '2026-08-22T00:00:00Z',
          ),
          const Lesson(
            id: 'lesson_3',
            title: '3. Plant Biology & Photosynthesis',
            description: 'Understand how green plants make energy, oxygen, and support ecosystems.',
            content: 'Plants use sunlight, carbon dioxide, and water to produce glucose and oxygen.',
            orderIndex: 3,
            isCompleted: false,
            updatedAt: '2026-08-22T00:00:00Z',
          ),
          const Lesson(
            id: 'lesson_4',
            title: '4. Basic Mathematics: Fractions',
            description: 'Master understanding parts of a whole, numerators, and denominators.',
            content: 'A fraction represents a part of a whole number.',
            orderIndex: 4,
            isCompleted: false,
            updatedAt: '2026-08-22T00:00:00Z',
          ),
        ];
      }
      setState(() {
        _lessons = lessons;
      });
    } catch (_) {
      // Offline fallback
      setState(() {
        _lessons = [
          const Lesson(
            id: 'lesson_1',
            title: '1. Introduction to Science',
            description: 'Learn the scientific method, observation, and hypothesis testing.',
            content: 'Science is the systematic study of the natural world.',
            orderIndex: 1,
            isCompleted: true,
            updatedAt: '2026-08-22T00:00:00Z',
          ),
        ];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openLesson(Lesson lesson) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonDetailScreen(
          lesson: lesson,
          onLessonUpdated: () {
            _loadLessons();
            widget.onLessonUpdated?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Lessons'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _lessons.isEmpty
              ? const Center(
                  child: Text(
                    'No offline lessons found.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLessons,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _lessons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lesson = _lessons[index];
                      return _buildLessonItem(lesson);
                    },
                  ),
                ),
    );
  }

  Widget _buildLessonItem(Lesson lesson) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lesson.isCompleted
                ? AppColors.success.withAlpha(30)
                : AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            lesson.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: lesson.isCompleted ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            lesson.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: () => _openLesson(lesson),
      ),
    );
  }
}
