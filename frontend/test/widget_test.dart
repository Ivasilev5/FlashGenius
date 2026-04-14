import 'package:flashcard_app/features/study/presentation/widgets/difficulty_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Difficulty buttons render all review options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DifficultyButtons(
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Снова'), findsOneWidget);
    expect(find.text('Сложно'), findsOneWidget);
    expect(find.text('Хорошо'), findsOneWidget);
    expect(find.text('Легко'), findsOneWidget);
  });
}
