import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/offline_indicator.dart';
import '../../data/local/models/quiz.dart';
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
  final ProgressRepository _progressRepo = ProgressRepository();

  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  final Map<int, int> _userAnswers = {}; // questionIndex -> selectedOptionIndex

  bool _isLoading = true;
  bool _isFinished = false;
  int _score = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _isFinished = false;
      _currentQuestionIndex = 0;
      _selectedOptionIndex = null;
      _userAnswers.clear();
      _score = 0;
    });

    try {
      List<QuizQuestion> loaded;
      if (widget.initialLessonId != null) {
        loaded = await _quizRepo.getQuestionsForLesson(widget.initialLessonId!);
      } else {
        loaded = await _quizRepo.getAllQuestions();
      }

      if (loaded.isEmpty) {
        // Fallback default questions if DB was empty
        loaded = [
          const QuizQuestion(
            id: 'q_fb_1',
            lessonId: 'lesson_1',
            questionText: 'What is the first step in the scientific method?',
            options: ['Hypothesis', 'Observation', 'Conclusion', 'Experiment'],
            correctOptionIndex: 1,
          ),
          const QuizQuestion(
            id: 'q_fb_2',
            lessonId: 'lesson_2',
            questionText: 'Which planet is known as the Red Planet?',
            options: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
            correctOptionIndex: 1,
          ),
          const QuizQuestion(
            id: 'q_fb_3',
            lessonId: 'lesson_3',
            questionText: 'What gas do green plants produce during photosynthesis?',
            options: ['Carbon Dioxide', 'Nitrogen', 'Oxygen', 'Hydrogen'],
            correctOptionIndex: 2,
          ),
          const QuizQuestion(
            id: 'q_fb_4',
            lessonId: 'lesson_4',
            questionText: 'In the fraction 3/5, what is the top number 3 called?',
            options: ['Denominator', 'Numerator', 'Quotient', 'Factor'],
            correctOptionIndex: 1,
          ),
        ];
      }

      setState(() {
        _questions = loaded;
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
        lessonId: widget.initialLessonId ?? 'all_lessons',
        score: calculatedScore,
        totalQuestions: _questions.length,
        completedAt: now,
        syncStatus: 'pending',
      );

      try {
        await _quizRepo.recordAttempt(attempt);
        await _progressRepo.recalculateAndSave('student_1');
      } catch (e) {
        debugPrint('Error saving quiz attempt locally: $e');
      }

      if (mounted) {
        setState(() {
          _score = calculatedScore;
          _isFinished = true;
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Quiz'),
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
          : _isFinished
              ? _buildResultView()
              : _buildQuizView(),
    );
  }

  Widget _buildQuizView() {
    final currentQ = _questions[_currentQuestionIndex];
    final progressVal = (_currentQuestionIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(progressVal * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressVal,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            currentQ.questionText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(currentQ.options.length, (index) {
            final letter = String.fromCharCode(65 + index); // A, B, C, D
            final isSelected = _selectedOptionIndex == index;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildOptionCard(
                optionLetter: letter,
                text: currentQ.options[index],
                isSelected: isSelected,
                onTap: () => _onOptionSelected(index),
              ),
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedOptionIndex == null || _isSaving ? null : _nextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _currentQuestionIndex == _questions.length - 1
                          ? 'Submit Quiz'
                          : 'Next Question',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPassed
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                size: 64,
                color: isPassed ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isPassed ? 'Great Job!' : 'Keep Practicing!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You scored $_score out of ${_questions.length} ($percentage%)',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined, color: AppColors.success, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Score saved locally & queued for sync.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retake Quiz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
