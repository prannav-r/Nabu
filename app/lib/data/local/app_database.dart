import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _dbName = 'offline_ai_tutor.db';
  static const int _dbVersion = 1;

  static AppDatabase? _instance;
  static Database? _database;

  AppDatabase._();

  factory AppDatabase() {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced'
      )
    ''');

    await db.execute('''
      CREATE TABLE lessons (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        content TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'synced'
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_questions (
        id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        question_text TEXT NOT NULL,
        options_json TEXT NOT NULL,
        correct_option_index INTEGER NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_attempts (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        lesson_id TEXT NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        completed_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    await db.execute('''
      CREATE TABLE student_progress (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        lessons_completed INTEGER NOT NULL,
        total_lessons INTEGER NOT NULL,
        quizzes_completed INTEGER NOT NULL,
        average_score REAL NOT NULL,
        updated_at TEXT NOT NULL,
        sync_status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    // Seed default student profile
    final now = DateTime.now().toIso8601String();
    await db.insert('students', {
      'id': 'student_1',
      'name': 'Student',
      'created_at': now,
      'sync_status': 'synced',
    });

    // Seed default offline lessons
    await _seedInitialLessons(db, now);
  }

  Future<void> _seedInitialLessons(Database db, String timestamp) async {
    final lessons = [
      {
        'id': 'lesson_1',
        'title': '1. Introduction to Science',
        'description': 'Learn the scientific method, observation, and hypothesis testing.',
        'content': '''# Introduction to Science

Science is the systematic study of the structure and behavior of the physical and natural world through observation and experiment.

## The Scientific Method
1. **Observation**: Notice something interesting in nature.
2. **Question**: Formulate a clear question about your observation.
3. **Hypothesis**: Propose a testable explanation.
4. **Experiment**: Test the hypothesis using controlled experiments.
5. **Analysis**: Examine the data collected.
6. **Conclusion**: Determine whether the hypothesis is supported or refuted.

## Importance in Everyday Life
Science helps us understand weather patterns, cure diseases, invent new technologies, and care for our planet.''',
        'order_index': 1,
        'is_completed': 0,
        'updated_at': timestamp,
        'sync_status': 'synced',
      },
      {
        'id': 'lesson_2',
        'title': '2. The Solar System',
        'description': 'Explore planets, orbits, and celestial objects in our solar neighborhood.',
        'content': '''# The Solar System

Our solar system consists of the Sun and everything bound to it by gravity.

## The Sun
The Sun is a yellow dwarf star at the center of the solar system, providing heat and light necessary for life on Earth.

## The Planets (In order from the Sun)
1. **Mercury**: Closest planet to the Sun, rocky and heavily cratered.
2. **Venus**: Hottest planet with a dense, toxic atmosphere.
3. **Earth**: Our home planet, the only known world with liquid water and life.
4. **Mars**: The Red Planet, known for its iron-rich dust and thin atmosphere.
5. **Jupiter**: Largest planet in the solar system, a gas giant.
6. **Saturn**: Known for its prominent and beautiful ring system.
7. **Uranus**: An ice giant with a unique sideways tilt.
8. **Neptune**: The farthest planet, windy and cold ice giant.''',
        'order_index': 2,
        'is_completed': 0,
        'updated_at': timestamp,
        'sync_status': 'synced',
      },
      {
        'id': 'lesson_3',
        'title': '3. Plant Biology & Photosynthesis',
        'description': 'Understand how green plants make energy, oxygen, and support ecosystems.',
        'content': '''# Plant Biology & Photosynthesis

Plants are autotrophs, meaning they produce their own food using sunlight, water, and carbon dioxide.

## The Photosynthesis Equation
Carbon Dioxide + Water + Light Energy → Glucose + Oxygen

## Key Plant Structures
- **Roots**: Absorb water and minerals from the soil.
- **Stem**: Transports water and nutrients throughout the plant.
- **Leaves**: Primary site of photosynthesis containing chlorophyll.
- **Chloroplasts**: Organelles where photosynthesis takes place.
- **Stomata**: Microscopic pores for gas exchange (intake of CO2, release of O2).''',
        'order_index': 3,
        'is_completed': 0,
        'updated_at': timestamp,
        'sync_status': 'synced',
      },
      {
        'id': 'lesson_4',
        'title': '4. Basic Mathematics: Fractions',
        'description': 'Master understanding parts of a whole, numerators, and denominators.',
        'content': '''# Basic Mathematics: Fractions

A fraction represents a part of a whole number or any number of equal parts.

## Anatomy of a Fraction
- **Numerator (Top)**: How many parts we have.
- **Denominator (Bottom)**: Total number of equal parts the whole is divided into.

Example: In 3/4, 3 is the numerator and 4 is the denominator.

## Common Types
1. **Proper Fractions**: Numerator is less than denominator (e.g., 1/2, 3/5).
2. **Improper Fractions**: Numerator is greater or equal to denominator (e.g., 5/3, 4/4).
3. **Mixed Numbers**: Whole number combined with a fraction (e.g., 1 1/2).''',
        'order_index': 4,
        'is_completed': 0,
        'updated_at': timestamp,
        'sync_status': 'synced',
      },
    ];

    for (final lesson in lessons) {
      await db.insert('lessons', lesson);
    }

    // Seed default quiz questions
    final questions = [
      {
        'id': 'q_1_1',
        'lesson_id': 'lesson_1',
        'question_text': 'What is the first step in the scientific method?',
        'options_json': '["Hypothesis","Observation","Conclusion","Experiment"]',
        'correct_option_index': 1,
      },
      {
        'id': 'q_1_2',
        'lesson_id': 'lesson_1',
        'question_text': 'What is a testable explanation in science called?',
        'options_json': '["Hypothesis","Fact","Observation","Theory"]',
        'correct_option_index': 0,
      },
      {
        'id': 'q_2_1',
        'lesson_id': 'lesson_2',
        'question_text': 'Which planet is known as the Red Planet?',
        'options_json': '["Venus","Mars","Jupiter","Mercury"]',
        'correct_option_index': 1,
      },
      {
        'id': 'q_2_2',
        'lesson_id': 'lesson_2',
        'question_text': 'Which is the largest planet in our solar system?',
        'options_json': '["Earth","Saturn","Neptune","Jupiter"]',
        'correct_option_index': 3,
      },
      {
        'id': 'q_3_1',
        'lesson_id': 'lesson_3',
        'question_text': 'What gas do plants release during photosynthesis?',
        'options_json': '["Carbon Dioxide","Nitrogen","Oxygen","Helium"]',
        'correct_option_index': 2,
      },
      {
        'id': 'q_4_1',
        'lesson_id': 'lesson_4',
        'question_text': 'In the fraction 3/5, what is the number 3 called?',
        'options_json': '["Denominator","Numerator","Quotient","Remainder"]',
        'correct_option_index': 1,
      },
    ];

    for (final q in questions) {
      await db.insert('quiz_questions', q);
    }

    // Seed initial student progress
    await db.insert('student_progress', {
      'id': 'prog_1',
      'student_id': 'student_1',
      'lessons_completed': 0,
      'total_lessons': lessons.length,
      'quizzes_completed': 0,
      'average_score': 0.0,
      'updated_at': timestamp,
      'sync_status': 'synced',
    });
  }
}
