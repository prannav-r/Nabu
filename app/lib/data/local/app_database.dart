import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'models/lesson.dart';
import 'models/progress.dart';
import 'models/quiz.dart';
import 'models/student_profile.dart';

class AppDatabase {
  static const String _dbName = 'offline_ai_tutor.db';
  static const int _dbVersion = 1;

  static AppDatabase? _instance;
  static Database? _database;

  // In-memory web and runtime fallback store ensuring 100% reliability across Web, Android, and Desktop
  static final List<StudentProfile> _memStudents = [];
  static final List<Lesson> _memLessons = [];
  static final List<QuizQuestion> _memQuestions = [];
  static final List<QuizAttempt> _memAttempts = [];
  static StudentProgress? _memProgress;
  static bool _memInitialized = false;

  AppDatabase._() {
    _initMemoryStore();
  }

  factory AppDatabase() {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  static void _initMemoryStore() {
    if (_memInitialized) return;
    final now = DateTime.now().toIso8601String();

    _memStudents.add(
      StudentProfile(
        id: 'student_1',
        name: 'Student',
        createdAt: now,
        syncStatus: 'synced',
      ),
    );

    _memLessons.addAll([
      Lesson(
        id: 'lesson_1',
        title: '1. Introduction to Science & Scientific Method',
        description: 'Master observation, hypothesis formulation, experimentation, and evidence analysis.',
        content: '''# Introduction to Science

Science is the systematic study of the structure and behavior of the physical and natural world through observation and experiment.

---

## 1. The Core Scientific Method
The scientific method is a logical framework used by researchers to investigate phenomena:

1. **Observation**: Notice an interesting pattern or unexplained event in nature.
2. **Question**: Formulate a specific, measurable question.
3. **Hypothesis**: Formulate a testable, falsifiable explanation.
4. **Controlled Experiment**: Test only one variable at a time (independent variable) while keeping control variables constant.
5. **Data Collection & Analysis**: Record quantitative and qualitative measurements carefully.
6. **Conclusion**: Evaluate if the empirical evidence supports or rejects the hypothesis.

---

## 2. Key Terminology
- **Independent Variable**: The factor intentionally changed by the scientist.
- **Dependent Variable**: The factor measured to observe the effect.
- **Control Group**: The standard of comparison that receives no experimental treatment.

---

## 3. Real-World Applications
From developing life-saving vaccines to designing clean solar energy grids, the scientific method provides a reliable path to discovering objective truth.''',
        orderIndex: 1,
        isCompleted: false,
        updatedAt: now,
        syncStatus: 'synced',
      ),
      Lesson(
        id: 'lesson_2',
        title: '2. The Solar System & Planetary Orbits',
        description: 'Explore the Sun, terrestrial planets, gas giants, asteroid belts, and gravity.',
        content: '''# The Solar System

Our solar system was formed approximately 4.6 billion years ago from a dense cloud of interstellar gas and dust.

---

## 1. The Sun — Our Central Star
The Sun accounts for 99.86% of the solar system's entire mass. Nuclear fusion in its core converts hydrogen into helium, releasing enormous amounts of heat and light energy.

---

## 2. The Eight Planets
1. **Mercury**: Closest to the Sun with extreme temperature swings (-180°C to 430°C).
2. **Venus**: Hottest planetary surface due to a runaway greenhouse effect in its dense CO₂ atmosphere.
3. **Earth**: The only known harbor for life, with abundant liquid surface water and a protective magnetic field.
4. **Mars**: The "Red Planet," colored by oxidized iron dust, home to Olympus Mons (largest volcano).
5. **Jupiter**: Massive gas giant with a Great Red Spot storm larger than Earth.
6. **Saturn**: Known for its spectacular rings made primarily of ice particles and rock fragments.
7. **Uranus**: An ice giant with a unique 98-degree axial tilt, rotating nearly sideways.
8. **Neptune**: Furthest recognized planet, enduring supersonic winds over 2,000 km/h.

---

## 3. Gravitational Dynamics
Sir Isaac Newton and Johannes Kepler proved that planets orbit in elliptical paths held by gravitational attraction proportional to mass and distance.''',
        orderIndex: 2,
        isCompleted: false,
        updatedAt: now,
        syncStatus: 'synced',
      ),
      Lesson(
        id: 'lesson_3',
        title: '3. Plant Biology & Photosynthesis',
        description: 'Discover how chlorophyll converts sunlight, water, and CO2 into glucose and oxygen.',
        content: '''# Plant Biology & Photosynthesis

Plants are the foundation of terrestrial food webs. Through photosynthesis, autotrophic organisms transform light energy into chemical energy.

---

## 1. The Chemical Reaction
The fundamental equation of photosynthesis is:
```text
6 CO₂ (Carbon Dioxide) + 6 H₂O (Water) + Sunlight ➔ C₆H₁₂O₆ (Glucose) + 6 O₂ (Oxygen)
```

---

## 2. Anatomical Structures
- **Chloroplasts**: Specialized cellular organelles containing the pigment **chlorophyll**, which absorbs blue and red wavelengths while reflecting green.
- **Thylakoid Membranes**: Site of light-dependent reactions where water molecules are split, releasing oxygen.
- **Stroma**: Fluid region where the Calvin Cycle synthesizes glucose sugars.
- **Stomata**: Microscopic pores on the underside of leaves that regulate gas exchange and transpiration.

---

## 3. Ecological Significance
Photosynthesis supplies virtually all organic carbon for living organisms and replenishes the breathable oxygen in Earth's atmosphere.''',
        orderIndex: 3,
        isCompleted: false,
        updatedAt: now,
        syncStatus: 'synced',
      ),
      Lesson(
        id: 'lesson_4',
        title: '4. Essential Mathematics: Fractions & Decimals',
        description: 'Understand numerators, denominators, equivalent fractions, and arithmetic operations.',
        content: '''# Essential Mathematics: Fractions

A fraction represents equal parts of a whole object or collection.

---

## 1. Anatomy of a Fraction
- **Numerator (Top)**: Represents how many fractional parts are selected.
- **Denominator (Bottom)**: Represents the total number of equal parts the whole is divided into.
  
*Example: In `3/8`, 3 is the numerator and 8 is the denominator.*

---

## 2. Common Types of Fractions
1. **Proper Fractions**: Numerator is strictly less than denominator (`1/2`, `3/4`).
2. **Improper Fractions**: Numerator is greater than or equal to denominator (`7/4`, `5/5`).
3. **Mixed Numbers**: An integer paired with a proper fraction (`1 ¾`, `3 ½`).

---

## 3. Basic Operations
- **Addition/Subtraction**: Find a Common Denominator:
  `1/3 + 1/6 = 2/6 + 1/6 = 3/6 = 1/2`
- **Multiplication**: Multiply numerators together, then denominators together:
  `2/3 × 4/5 = 8/15`
- **Division**: Invert the second fraction and multiply:
  `2/3 ÷ 4/5 = 2/3 × 5/4 = 10/12 = 5/6`''',
        orderIndex: 4,
        isCompleted: false,
        updatedAt: now,
        syncStatus: 'synced',
      ),
    ]);

    _memQuestions.addAll([
      const QuizQuestion(
        id: 'q_1_1',
        lessonId: 'lesson_1',
        questionText: 'What is the first step in the scientific method?',
        options: ['Formulate a hypothesis', 'Make an observation', 'Draw a conclusion', 'Perform an experiment'],
        correctOptionIndex: 1,
      ),
      const QuizQuestion(
        id: 'q_1_2',
        lessonId: 'lesson_1',
        questionText: 'In a controlled experiment, what factor is intentionally changed by the scientist?',
        options: ['Independent variable', 'Dependent variable', 'Control group', 'Constant factor'],
        correctOptionIndex: 0,
      ),
      const QuizQuestion(
        id: 'q_2_1',
        lessonId: 'lesson_2',
        questionText: 'Which planet is known as the "Red Planet" due to iron oxide on its surface?',
        options: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
        correctOptionIndex: 1,
      ),
      const QuizQuestion(
        id: 'q_2_2',
        lessonId: 'lesson_2',
        questionText: 'Which is the largest planet in our solar system?',
        options: ['Earth', 'Saturn', 'Neptune', 'Jupiter'],
        correctOptionIndex: 3,
      ),
      const QuizQuestion(
        id: 'q_3_1',
        lessonId: 'lesson_3',
        questionText: 'What gas do green plants release into the atmosphere during photosynthesis?',
        options: ['Carbon Dioxide', 'Nitrogen', 'Oxygen', 'Helium'],
        correctOptionIndex: 2,
      ),
      const QuizQuestion(
        id: 'q_3_2',
        lessonId: 'lesson_3',
        questionText: 'Where in a plant cell does photosynthesis primarily take place?',
        options: ['Mitochondria', 'Chloroplasts', 'Nucleus', 'Ribosomes'],
        correctOptionIndex: 1,
      ),
      const QuizQuestion(
        id: 'q_4_1',
        lessonId: 'lesson_4',
        questionText: 'In the fraction 3/8, what is the number 8 called?',
        options: ['Numerator', 'Denominator', 'Quotient', 'Remainder'],
        correctOptionIndex: 1,
      ),
      const QuizQuestion(
        id: 'q_4_2',
        lessonId: 'lesson_4',
        questionText: 'What is 1/2 + 1/4 simplified?',
        options: ['2/6', '3/4', '1/8', '2/4'],
        correctOptionIndex: 1,
      ),
    ]);

    _memProgress = StudentProgress(
      id: 'prog_1',
      studentId: 'student_1',
      lessonsCompleted: 0,
      totalLessons: _memLessons.length,
      quizzesCompleted: 0,
      averageScore: 0.0,
      updatedAt: now,
      syncStatus: 'synced',
    );

    _memInitialized = true;
  }

  // Direct access to universal memory store
  static List<Lesson> get memLessons => _memLessons;
  static List<QuizQuestion> get memQuestions => _memQuestions;
  static List<QuizAttempt> get memAttempts => _memAttempts;
  static StudentProgress? get memProgress => _memProgress;
  static set memProgress(StudentProgress? val) => _memProgress = val;

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web uses memory store
    try {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      debugPrint('[AppDatabase] Mobile SQLite not active, falling back to universal store: $e');
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, v) async {
        // Native SQLite tables setup
        await db.execute('CREATE TABLE IF NOT EXISTS students (id TEXT PRIMARY KEY, name TEXT, created_at TEXT, sync_status TEXT)');
        await db.execute('CREATE TABLE IF NOT EXISTS lessons (id TEXT PRIMARY KEY, title TEXT, description TEXT, content TEXT, order_index INTEGER, is_completed INTEGER, updated_at TEXT, sync_status TEXT)');
        await db.execute('CREATE TABLE IF NOT EXISTS quiz_questions (id TEXT PRIMARY KEY, lesson_id TEXT, question_text TEXT, options_json TEXT, correct_option_index INTEGER)');
        await db.execute('CREATE TABLE IF NOT EXISTS quiz_attempts (id TEXT PRIMARY KEY, student_id TEXT, lesson_id TEXT, score INTEGER, total_questions INTEGER, completed_at TEXT, sync_status TEXT)');
        await db.execute('CREATE TABLE IF NOT EXISTS student_progress (id TEXT PRIMARY KEY, student_id TEXT, lessons_completed INTEGER, total_lessons INTEGER, quizzes_completed INTEGER, average_score REAL, updated_at TEXT, sync_status TEXT)');
      },
    );
  }
}
