import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/local/models/lesson.dart';
import '../../data/local/repositories/lesson_repository.dart';
import 'lesson_detail_screen.dart';
import 'services/topic_generator.dart';

class LessonsScreen extends StatefulWidget {
  final VoidCallback? onLessonUpdated;

  const LessonsScreen({super.key, this.onLessonUpdated});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final LessonRepository _lessonRepo = LessonRepository();
  final TopicGeneratorService _generatorService = TopicGeneratorService();

  List<Lesson> _lessons = [];
  bool _isLoading = true;
  bool _isGenerating = false;

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
      final lessons = await _lessonRepo.getAllLessons();
      if (!mounted) return;
      setState(() {
        _lessons = lessons;
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

  Future<void> _showAddTopicDialog() async {
    final textController = TextEditingController();

    final topic = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 22),
            SizedBox(width: 8),
            Text('Generate New Topic'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter any topic or subject. The local AI will generate complete lesson chapters, summaries, and practice quizzes for it offline.',
              style: TextStyle(fontSize: 13, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
            ),
            SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Topic Name',
                hintText: 'e.g. Gravity, Human Heart, Python Basics',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              final val = textController.text.trim();
              if (val.isNotEmpty) {
                Navigator.of(ctx).pop(val);
              }
            },
            icon: Icon(Icons.bolt_rounded, size: 18),
            label: Text('Generate Lesson'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (topic != null && topic.isNotEmpty) {
      setState(() {
        _isGenerating = true;
      });

      try {
        final result = await _generatorService.generateLessonForTopic(topic);
        await _loadLessons();
        widget.onLessonUpdated?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✨ Generated new lesson: "${result.lesson.title}" with practice quiz!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating lesson: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Lessons & Topics'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Generate Topic',
            onPressed: _showAddTopicDialog,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTopicDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        icon: Icon(Icons.auto_awesome),
        label: Text('Generate Topic'),
      ),
      body: _isGenerating
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Generating lesson & practice quiz offline...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
          : _isLoading
              ? Center(child: CircularProgressIndicator())
              : _lessons.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_outlined, size: 48, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                          SizedBox(height: 12),
                          Text(
                            'No lessons available yet.',
                            style: TextStyle(fontSize: 16, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddTopicDialog,
                            icon: Icon(Icons.add),
                            label: Text('Add / Generate a Topic'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLessons,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _lessons.length,
                        separatorBuilder: (_, __) => SizedBox(height: 12),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: lesson.isCompleted
                ? Colors.green.withAlpha(30)
                : Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            lesson.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: lesson.isCompleted ? Colors.green : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.0),
          child: Text(
            lesson.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
        ),
        onTap: () => _openLesson(lesson),
      ),
    );
  }
}
