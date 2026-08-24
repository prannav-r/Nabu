import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'features/home/home_screen.dart';
import 'features/lessons/lessons_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/quiz/quiz_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/tutor/tutor_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(const OfflineAiTutorApp());
}

class OfflineAiTutorApp extends StatelessWidget {
  const OfflineAiTutorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Offline AI Tutor',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: const MainNavigationShell(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  int _refreshCounter = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _refreshCounter++;
    });
  }

  void _navigateToSettings() {
    Navigator.of(context).pushNamed('/settings');
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    switch (_currentIndex) {
      case 0:
        currentScreen = HomeScreen(
          key: ValueKey('home_$_refreshCounter'),
          onNavigateToLessons: () => _onTabSelected(1),
          onNavigateToTutor: () => _onTabSelected(2),
          onNavigateToQuiz: () => _onTabSelected(3),
          onNavigateToSettings: _navigateToSettings,
        );
        break;
      case 1:
        currentScreen = LessonsScreen(
          key: ValueKey('lessons_$_refreshCounter'),
          onLessonUpdated: () {
            setState(() {
              _refreshCounter++;
            });
          },
        );
        break;
      case 2:
        currentScreen = TutorScreen(
          key: ValueKey('tutor_$_refreshCounter'),
        );
        break;
      case 3:
        currentScreen = QuizScreen(
          key: ValueKey('quiz_$_refreshCounter'),
        );
        break;
      case 4:
        currentScreen = ProgressScreen(
          key: ValueKey('progress_$_refreshCounter'),
        );
        break;
      default:
        currentScreen = HomeScreen(
          onNavigateToLessons: () => _onTabSelected(1),
          onNavigateToTutor: () => _onTabSelected(2),
          onNavigateToQuiz: () => _onTabSelected(3),
          onNavigateToSettings: _navigateToSettings,
        );
    }

    return Scaffold(
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book_rounded),
            label: 'Lessons',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy_rounded),
            label: 'Tutor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz_rounded),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
