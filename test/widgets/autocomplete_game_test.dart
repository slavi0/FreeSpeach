import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_speach/autocompleteGame.dart';

void main() {
  group('AutocompleteGame', () {
    testWidgets('displays correct title in AppBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AutocompleteGame(quantity: 3, timer: 10)),
      );

      expect(find.text('Autocomplete'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('shows initial game view with prompt', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AutocompleteGame(quantity: 3, timer: 10)),
      );

      // Should show game content, not finished view
      expect(find.text('1 / 3'), findsOneWidget); // HUD round format
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Quit'), findsOneWidget);
    });

    testWidgets('displays round counter correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AutocompleteGame(quantity: 5, timer: 10)),
      );

      expect(find.text('1 / 5'), findsOneWidget);
    });

    testWidgets('displays time text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AutocompleteGame(quantity: 3, timer: 10)),
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
        const MaterialApp(home: AutocompleteGame(quantity: 3, timer: 10)),
      );

      expect(find.text('Pause'), findsOneWidget);

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('quit button pops the route', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AutocompleteGame(quantity: 3, timer: 10)),
        ),
      );

      await tester.tap(find.text('Quit'));
      await tester.pumpAndSettle();

      // Should pop back (we're in a scaffold, so check if autocomplete game is gone)
      expect(find.byType(AutocompleteGame), findsNothing);
    });

    testWidgets('has dark background', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AutocompleteGame(quantity: 3, timer: 10)),
      );

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(
        scaffoldWidget.backgroundColor,
        const Color(0xFF0F0F0F),
      ); // Updated background color
    });

    testWidgets('shows game over screen after finish', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AutocompleteGame(quantity: 1, timer: 1)),
      );

      // Initial state: playing
      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Advance time past the round
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // After finish: should show Game Over screen
      expect(find.text('Great Job!'), findsOneWidget);
      expect(find.text('Back to Menu'), findsOneWidget);
    });

    testWidgets('displays prompt text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AutocompleteGame(quantity: 3, timer: 10)),
      );

      // We expect at least one text widget with the style of the prompt
      expect(
        find.byWidgetPredicate((widget) {
          return widget is Text &&
              widget.data!.length > 10 &&
              widget.data!.endsWith('…');
        }),
        findsOneWidget,
      );
    });
  });
}
