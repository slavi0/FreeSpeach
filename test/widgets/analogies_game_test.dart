import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_speach/analogiesGame.dart';

void main() {
  group('AnalogiesGame', () {
    testWidgets('displays correct title in AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      expect(find.text('Analogies'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows initial game view with prompt', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      // Should show game content, not finished view
      expect(find.text('Round 1 / 3'), findsOneWidget);
      expect(find.text('PAUSE'), findsOneWidget);
      expect(find.text('QUIT GAME'), findsOneWidget);
    });

    testWidgets('displays round counter correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 7, timer: 10)),
      );

      expect(find.text('Round 1 / 7'), findsOneWidget);
    });

    testWidgets('displays time text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      // Time should be displayed (format: "Time: X.Xs")
      expect(
        find.byWidgetPredicate((widget) {
          return widget is Text && widget.data!.startsWith('Time:');
        }),
        findsOneWidget,
      );
    });

    testWidgets('pause button toggles to resume', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      expect(find.text('PAUSE'), findsOneWidget);

      await tester.tap(find.text('PAUSE'));
      await tester.pumpAndSettle();

      expect(find.text('RESUME'), findsOneWidget);
    });

    testWidgets('quit button pops the route', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AnalogiesGame(quantity: 3, timer: 10)),
        ),
      );

      await tester.tap(find.text('QUIT GAME'));
      await tester.pumpAndSettle();

      // Should pop back
      expect(find.byType(AnalogiesGame), findsNothing);
    });

    testWidgets('has dark background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor, Colors.black87);
    });

    testWidgets('shows game over screen after finish', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 1, timer: 1)),
      );

      // Initial state: playing
      expect(find.text('Round 1 / 1'), findsOneWidget);
      expect(find.text('PAUSE'), findsOneWidget);

      // Advance time past the round
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After finish: should show Game Over screen
      expect(find.text('Game Over!'), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
      expect(find.text('Back to Menu'), findsOneWidget);
    });

    testWidgets('displays analogy prompt text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      // At least one analogy prompt should be visible
      final prompts = [
        'A is like B because',
        'Life is like a box of chocolates because',
        'Love is like a',
      ];

      bool foundPrompt = false;
      for (final prompt in prompts) {
        if (find.textContaining(prompt).evaluate().isNotEmpty) {
          foundPrompt = true;
          break;
        }
      }
      expect(foundPrompt, true);
    });
  });
}
