import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';
import '../../data/local/models/lesson.dart';
import '../../data/local/models/quiz.dart';
import '../../data/local/repositories/lesson_repository.dart';
import '../../data/local/repositories/progress_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';

class QuizScreen extends StatefulWidget {
  final String? initialLessonId;

  const QuizScreen({super.key, this.initialLessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizRepository _quizRepo = QuizRepository();
  final LessonRepository _lessonRepo = LessonRepository();
  final ProgressRepository _progressRepo = ProgressRepository();

  List<Lesson> _availableLessons = [];
  String? _selectedLessonId;
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  final Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex

  bool _isLoading = true;
  bool _isQuizActive = false;
  bool _isFinished = false;
  int _score = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedLessonId = widget.initialLessonId;
    _initQuizScreen();
  }

  Future<void> _initQuizScreen() async {
    setState(() {
      _isLoading = true;
    });

    final lessons = await _lessonRepo.getAllLessons();

    setState(() {
      _availableLessons = lessons;
      _isLoading = false;
    });

    if (_selectedLessonId != null) {
      await _startQuizForLesson(_selectedLessonId);
    }
  }

  Future<void> _startQuizForLesson(String? lessonId) async {
    setState(() {
      _isLoading = true;
      _selectedLessonId = lessonId;
      _isQuizActive = true;
      _isFinished = false;
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _userAnswers.clear();
      _score = 0;
    });

    List<QuizQuestion> loaded = [];
    if (lessonId != null) {
      loaded = await _quizRepo.getQuestionsForLesson(lessonId);
    }

    if (loaded.isEmpty) {
      loaded = await _quizRepo.getAllQuestions();
    }

    setState(() {
      _questions = loaded;
      _isLoading = false;
    });
  }

  void _onOptionSelected(int optionIndex) {
    setState(() {
      _selectedOptionIndex = optionIndex;
      _userAnswers[_currentQuestionIndex] = optionIndex;
    });
  }

  Future<void> _nextOrSubmit() async {
    if (_selectedOptionIndex == null) return;

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = _userAnswers[_currentQuestionIndex];
      });
    } else {
      // Finish Quiz & Calculate Score
      setState(() {
        _isSaving = true;
      });

      int calculatedScore = 0;
      for (int i = 0; i < _questions.length; i++) {
        if (_userAnswers[i] == _questions[i].correctOptionIndex) {
          calculatedScore++;
        }
      }

      final now = DateTime.now().toIso8601String();
      final attempt = QuizAttempt(
        id: 'attempt_${DateTime.now().millisecondsSinceEpoch}',
        studentId: 'student_1',
        lessonId: _selectedLessonId ?? 'all_topics',
        score: calculatedScore,
        totalQuestions: _questions.length,
        completedAt: now,
        syncStatus: 'pending',
      );

      await _quizRepo.recordAttempt(attempt);
      await _progressRepo.recalculateAndSave('student_1');

      if (mounted) {
        setState(() {
          _score = calculatedScore;
          _isFinished = true;
          _isSaving = false;
        });
      }
    }
  }

  void _exitQuizToSelector() {
    setState(() {
      _isQuizActive = false;
      _isFinished = false;
      _selectedLessonId = null;
      _questions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isQuizActive ? 'Interactive Quiz' : 'Offline Quizzes'),
        leading: _isQuizActive
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                tooltip: 'Back to Quiz List',
                onPressed: _exitQuizToSelector,
              )
            : null,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(
              child: OfflineStatusIndicator(status: SyncStatus.offline),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : !_isQuizActive
              ? _buildQuizSelectionView()
              : _isFinished
                  ? _buildResultView()
                  : _questions.isEmpty
                      ? _buildNoQuestionsView()
                      : _buildQuizView(),
    );
  }

  Widget _buildQuizSelectionView() {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Card(
          color: Theme.of(context).colorScheme.primary.withAlpha(15),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.0),
            leading: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.stars_rounded, color: Colors.white, size: 28),
            ),
            title: Text(
              'Comprehensive Practice Quiz',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4.0),
              child: Text(
                'Test your knowledge across all available lessons and topics in a combined quiz.',
                style: TextStyle(fontSize: 13, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
              ),
            ),
            trailing: Icon(Icons.play_circle_fill, color: Theme.of(context).colorScheme.primary, size: 32),
            onTap: () => _startQuizForLesson(null),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Select a Topic Quiz',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 10),
        if (_availableLessons.isEmpty)
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No topic quizzes found. Generate topics from the Lessons tab.'),
            ),
          )
        else
          ..._availableLessons.map((l) {
            return Card(
              margin: EdgeInsets.only(bottom: 10.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  child: Icon(Icons.quiz_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                title: Text(
                  l.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  l.isCompleted ? '✓ Lesson Completed' : 'Study & Test',
                  style: TextStyle(
                    fontSize: 12,
                    color: l.isCompleted ? Colors.green : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
                onTap: () => _startQuizForLesson(l.id),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildNoQuestionsView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 48, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
            SizedBox(height: 12),
            Text(
              'No practice questions found for this topic yet.',
              style: TextStyle(fontSize: 15, color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _exitQuizToSelector,
              child: Text('Return to Quiz List'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizView() {
    final currentQ = _questions[_currentQuestionIndex];
    final progressVal = (_currentQuestionIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
                ),
              ),
              Text(
                '${(progressVal * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressVal,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 24),
          Text(
            currentQ.questionText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24),
          ...List.generate(currentQ.options.length, (index) {
            final letter = String.fromCharCode(65 + index); // A, B, C, D
            final isSelected = _selectedOptionIndex == index;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: _buildOptionCard(
                optionLetter: letter,
                text: currentQ.options[index],
                isSelected: isSelected,
                onTap: () => _onOptionSelected(index),
              ),
            );
          }),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedOptionIndex == null || _isSaving ? null : _nextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Submit Quiz ✓'
                          : 'Next Question →',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String optionLetter,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withAlpha(20) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final percentage = ((_score / (_questions.isNotEmpty ? _questions.length : 1)) * 100).toInt();
    final isPassed = percentage >= 60;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green.withAlpha(25) : Colors.orange.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                size: 64,
                color: isPassed ? Colors.green : Colors.orange,
              ),
            ),
            SizedBox(height: 16),
            Text(
              isPassed ? '🎉 Great Job!' : 'Keep Practicing!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You scored $_score out of ${_questions.length} ($percentage%)',
              style: TextStyle(
                fontSize: 16,
                color: (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Score recorded locally & queued for sync.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _startQuizForLesson(_selectedLessonId),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Retake Quiz', style: TextStyle(fontSize: 15)),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exitQuizToSelector,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Choose Quiz', style: TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
