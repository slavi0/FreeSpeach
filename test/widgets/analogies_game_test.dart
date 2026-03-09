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
      expect(find.text('1 / 3'), findsOneWidget); // New HUD format
      expect(find.text('Pause'), findsOneWidget); // Elevated button label
      expect(find.text('Quit'), findsOneWidget); // Outlined button label
    });

    testWidgets('displays round counter correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 7, timer: 10)),
      );

      expect(find.text('1 / 7'), findsOneWidget);
    });

    testWidgets('displays time progress bar text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      // Time should be displayed (format: "10.0s")
      expect(
        find.byWidgetPredicate((widget) {
          return widget is Text &&
              widget.data!.endsWith('s') &&
              double.tryParse(widget.data!.replaceAll('s', '')) != null;
        }),
        findsOneWidget,
      );
    });

    testWidgets('pause button toggles to resume', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      expect(find.text('Pause'), findsOneWidget);

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('quit button pops the route', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AnalogiesGame(quantity: 3, timer: 10)),
        ),
      );

      await tester.tap(find.text('Quit'));
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
      expect(scaffoldWidget.backgroundColor, const Color(0xFF0F0F0F));
    });

    testWidgets('shows game over screen after finish', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 1, timer: 1)),
      );

      // Initial state: playing
      expect(find.text('1 / 1'), findsOneWidget); // HUD round
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Advance time past the round
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After finish: should show Game Over screen
      expect(find.text('Great Job!'), findsOneWidget);
      expect(find.text('Back to Menu'), findsOneWidget);
    });

    testWidgets('displays dynamic analogy prompt text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AnalogiesGame(quantity: 3, timer: 10)),
      );

      // We expect the text to contain "is like", since it's dynamically generated
      expect(
        find.byWidgetPredicate((widget) {
          return widget is Text &&
              widget.data!.contains('is like') &&
              widget.data!.contains('because...');
        }),
        findsOneWidget,
      );
    });
  });
}
