import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:offline_ai_tutor/main.dart';

void main() {
  testWidgets('App shell loads and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const OfflineAiTutorApp());

    // Verify app title and student greeting
    expect(find.text('Offline AI Tutor'), findsOneWidget);
    expect(find.text('Hello, Student!'), findsOneWidget);
    expect(find.text('Offline — Working locally'), findsOneWidget);

    // Verify navigation tabs
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
    expect(find.text('Tutor'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);

    // Tap Lessons tab
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();

    expect(find.textContaining('Introduction to Science'), findsOneWidget);
  });
}
