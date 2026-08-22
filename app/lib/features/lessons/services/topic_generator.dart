import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/local/models/lesson.dart';
import '../../../data/local/models/quiz.dart';
import '../../../data/local/repositories/lesson_repository.dart';
import '../../../data/local/repositories/progress_repository.dart';
import '../../../data/local/repositories/quiz_repository.dart';

class GeneratedTopicResult {
  final Lesson lesson;
  final List<QuizQuestion> questions;

  const GeneratedTopicResult({
    required this.lesson,
    required this.questions,
  });
}

class TopicGeneratorService {
  final LessonRepository _lessonRepo;
  final QuizRepository _quizRepo;
  final ProgressRepository _progressRepo;

  TopicGeneratorService({
    LessonRepository? lessonRepo,
    QuizRepository? quizRepo,
    ProgressRepository? progressRepo,
  })  : _lessonRepo = lessonRepo ?? LessonRepository(),
        _quizRepo = quizRepo ?? QuizRepository(),
        _progressRepo = progressRepo ?? ProgressRepository();

  Future<GeneratedTopicResult> generateLessonForTopic(String topicPrompt) async {
    final cleanTopic = topicPrompt.trim();
    final lower = cleanTopic.toLowerCase();
    final timestamp = DateTime.now().toIso8601String();
    final lessonId = 'lesson_gen_${DateTime.now().millisecondsSinceEpoch}';

    // Simulate local quantized ONNX topic distillation
    await Future.delayed(const Duration(milliseconds: 600));

    final existingLessons = await _lessonRepo.getAllLessons();
    final nextOrder = existingLessons.length + 1;

    String title = '$nextOrder. $cleanTopic';
    String description = 'Comprehensive structured overview of $cleanTopic with key concepts and self-testing.';
    String content = _buildContentForTopic(cleanTopic, lower);
    List<QuizQuestion> questions = _buildQuestionsForTopic(lessonId, cleanTopic, lower);

    final lesson = Lesson(
      id: lessonId,
      title: title,
      description: description,
      content: content,
      orderIndex: nextOrder,
      isCompleted: false,
      updatedAt: timestamp,
      syncStatus: 'pending',
    );

    await _lessonRepo.saveLesson(lesson);
    await _quizRepo.saveQuestions(questions);
    await _progressRepo.recalculateAndSave('student_1');

    debugPrint('[TopicGeneratorService] Successfully generated lesson: ${lesson.title} with ${questions.length} questions.');

    return GeneratedTopicResult(lesson: lesson, questions: questions);
  }

  String _buildContentForTopic(String topic, String lower) {
    if (lower.contains('gravity') || lower.contains('newton') || lower.contains('force') || lower.contains('physics')) {
      return '''# $topic

Gravity and classical mechanics describe how physical bodies interact through fundamental forces.

---

## 1. Newton's Three Laws of Motion
1. **First Law (Inertia)**: An object at rest remains at rest, and an object in motion continues in uniform motion unless acted upon by an external net force.
2. **Second Law (F = ma)**: The acceleration of an object is directly proportional to net force and inversely proportional to its mass.
3. **Third Law (Action & Reaction)**: For every action, there is an equal and opposite reaction force.

---

## 2. Universal Gravitation
Sir Isaac Newton discovered that every mass attracts every other mass with a force proportional to the product of their masses and inversely proportional to the square of the distance between them:
```text
F = G * (m1 * m2) / r²
```

---

## 3. Real-World Applications
- **Satellite Orbits**: Keeping communication satellites in stable geostationary trajectories around Earth.
- **Space Travel**: Calculating gravitational slingshots to propel deep-space probes.
- **Architecture**: Engineering bridges and skyscrapers to withstand gravitational loads and stresses.''';
    }

    if (lower.contains('code') || lower.contains('python') || lower.contains('program') || lower.contains('computer')) {
      return '''# $topic

Computer science and programming provide the foundational logic behind modern digital technology.

---

## 1. Core Programming Concepts
- **Variables**: Named storage locations in memory holding data values (e.g., integers, strings, booleans).
- **Control Flow**: Conditionals (`if`, `else`) that direct execution based on logical truth values.
- **Loops**: Iterative structures (`for`, `while`) that automate repetitive tasks.
- **Functions**: Reusable blocks of code that take inputs (arguments) and return results.

---

## 2. Computational Thinking
1. **Decomposition**: Breaking a large problem into smaller, manageable subproblems.
2. **Pattern Recognition**: Identifying similarities among different problems.
3. **Abstraction**: Focusing only on essential details while hiding unnecessary complexity.
4. **Algorithm Design**: Developing step-by-step instructions to solve the problem reliably.

---

## 3. Real-World Applications
Software powers everything from global communication networks and smartphones to medical diagnostic imaging and autonomous vehicles.''';
    }

    if (lower.contains('heart') || lower.contains('blood') || lower.contains('digest') || lower.contains('body') || lower.contains('human')) {
      return '''# $topic

The human body is an intricate biological system composed of specialized organs working together to maintain homeostasis.

---

## 1. Key Organ Systems
- **Circulatory System**: The heart pumps oxygen-rich blood through arteries, while veins return deoxygenated blood to the lungs.
- **Respiratory System**: The lungs facilitate gas exchange, inhaling oxygen (O₂) and expelling carbon dioxide (CO₂).
- **Digestive System**: Breaks down food into essential macronutrients and water, absorbing energy in the small intestines.
- **Nervous System**: The brain, spinal cord, and peripheral nerves transmit electrical signals at speeds over 100 meters per second.

---

## 2. Homeostasis
Homeostasis is the body's ability to maintain a stable internal environment (such as body temperature at ~37°C, pH levels, and blood sugar balance) regardless of external conditions.

---

## 3. Health & Longevity
Regular physical exercise, balanced nutrition, and adequate sleep support cellular regeneration and immune defense against pathogens.''';
    }

    // Dynamic structured template for any generic topic
    return '''# $topic

A structured educational introduction to **$topic**, exploring fundamental principles, mechanisms, and real-world importance.

---

## 1. Overview & Core Definition
$topic is a vital subject of study with significant historical, practical, and scientific relevance. Understanding its foundational principles enables deeper analytical and critical thinking.

---

## 2. Fundamental Key Concepts
- **Core Principle**: The central theory that governs how $topic operates.
- **Components**: The individual interconnected parts that make up the system of $topic.
- **Functionality**: The active processes and transformations that take place within $topic.

---

## 3. Step-by-Step Breakdown
1. **Foundations**: Establishing the primary facts and initial conditions.
2. **Dynamics**: Observing how different factors interact and create outcomes.
3. **Application**: Applying theoretical knowledge to solve real-world problems and practical scenarios.

---

## 4. Summary & Key Takeaways
- $topic follows clear, systematic rules that can be studied and applied.
- Review the key terms and take the practice quiz to solidify your understanding offline.''';
  }

  List<QuizQuestion> _buildQuestionsForTopic(String lessonId, String topic, String lower) {
    if (lower.contains('gravity') || lower.contains('physics') || lower.contains('newton')) {
      return [
        QuizQuestion(
          id: 'q_${lessonId}_1',
          lessonId: lessonId,
          questionText: 'According to Newton\'s First Law, what keeps an object in motion at constant velocity?',
          options: ['Inertia (absence of net external force)', 'Continuous engine power', 'Friction with air', 'Gravity'],
          correctOptionIndex: 0,
        ),
        QuizQuestion(
          id: 'q_${lessonId}_2',
          lessonId: lessonId,
          questionText: 'What is the formula for Newton\'s Second Law of Motion?',
          options: ['E = mc²', 'F = ma', 'P = IV', 'v = d / t'],
          correctOptionIndex: 1,
        ),
        QuizQuestion(
          id: 'q_${lessonId}_3',
          lessonId: lessonId,
          questionText: 'For every action force, there is:',
          options: ['A smaller reaction force', 'No reaction force', 'An equal and opposite reaction force', 'A delayed reaction force'],
          correctOptionIndex: 2,
        ),
      ];
    }

    if (lower.contains('code') || lower.contains('program') || lower.contains('python') || lower.contains('computer')) {
      return [
        QuizQuestion(
          id: 'q_${lessonId}_1',
          lessonId: lessonId,
          questionText: 'What is a named storage location in memory called?',
          options: ['Loop', 'Variable', 'Comment', 'Compiler'],
          correctOptionIndex: 1,
        ),
        QuizQuestion(
          id: 'q_${lessonId}_2',
          lessonId: lessonId,
          questionText: 'Which programming structure is used to repeat code multiple times?',
          options: ['Conditional (if/else)', 'Loop (for/while)', 'Variable assignment', 'Print statement'],
          correctOptionIndex: 1,
        ),
        QuizQuestion(
          id: 'q_${lessonId}_3',
          lessonId: lessonId,
          questionText: 'What is decomposing a problem in computational thinking?',
          options: ['Breaking it into smaller parts', 'Writing binary code', 'Buying faster hardware', 'Deleting error logs'],
          correctOptionIndex: 0,
        ),
      ];
    }

    return [
      QuizQuestion(
        id: 'q_${lessonId}_1',
        lessonId: lessonId,
        questionText: 'What is the main purpose of studying $topic?',
        options: [
          'To understand its foundational principles and applications',
          'To ignore practical examples',
          'To memorize without understanding',
          'To replace experimentation with guessing',
        ],
        correctOptionIndex: 0,
      ),
      QuizQuestion(
        id: 'q_${lessonId}_2',
        lessonId: lessonId,
        questionText: 'Which step is essential when analyzing problems in $topic?',
        options: [
          'Skipping data collection',
          'Breaking the problem into core components and observing dynamics',
          'Relying on random chance',
          'Ignoring fundamental laws',
        ],
        correctOptionIndex: 1,
      ),
    ];
  }
}
