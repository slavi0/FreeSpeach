import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_speach/games/rapid_fire/rapid_fire_controller.dart';

void main() {
  group('RapidFireController State Management', () {
    testWidgets('initializes with correct default values', (
      WidgetTester tester,
    ) async {
      final controller = RapidFireController(
        vsync: tester,
        totalRounds: 3,
        secondsPerRound: 10,
      );

      expect(controller.roundNotifier.value, 0);
      expect(controller.isPausedNotifier.value, false);
      expect(controller.finishedNotifier.value, false);

      controller.dispose();
    });

    testWidgets('finishes immediately if totalRounds is 0 or negative', (
      WidgetTester tester,
    ) async {
      final controller = RapidFireController(
        vsync: tester,
        totalRounds: 0,
        secondsPerRound: 10,
      );

      controller.start();
      expect(controller.finishedNotifier.value, true);
      expect(controller.roundNotifier.value, 0);

      controller.dispose();
    });

    testWidgets('initializes round to 1 when started', (
      WidgetTester tester,
    ) async {
      final controller = RapidFireController(
        vsync: tester,
        totalRounds: 3,
        secondsPerRound: 10,
      );

      controller.start();
      expect(controller.roundNotifier.value, 1);

      // Stop the animation before dispose
      controller.pause();
      await tester.pumpWidget(const Placeholder());
      controller.dispose();
    });

    testWidgets('pause sets isPausedNotifier to true', (
      WidgetTester tester,
    ) async {
      final controller = RapidFireController(
        vsync: tester,
        totalRounds: 1,
        secondsPerRound: 5,
      );

      controller.start();
      controller.pause();
      expect(controller.isPausedNotifier.value, true);

      controller.dispose();
    });

    testWidgets('resume sets isPausedNotifier to false', (
      WidgetTester tester,
    ) async {
      final controller = RapidFireController(
        vsync: tester,
        totalRounds: 1,
        secondsPerRound: 5,
      );

      controller.start();
      controller.pause();
      expect(controller.isPausedNotifier.value, true);

      controller.resume();
      expect(controller.isPausedNotifier.value, false);

      // Clean up
      controller.pause();
      controller.dispose();
    });

    testWidgets('notifiers are disposed without error', (
      WidgetTester tester,
    ) async {
      final controller = RapidFireController(
        vsync: tester,
        totalRounds: 1,
        secondsPerRound: 1,
      );

      var roundChangedCount = 0;
      controller.roundNotifier.addListener(() {
        roundChangedCount++;
      });

      controller.start();
      expect(roundChangedCount, 1);

      controller.pause();
      controller.dispose();
      // After dispose, further state changes should not trigger errors
    });

    testWidgets('timeNotifier has reasonable initial value', (
      WidgetTester tester,
    ) async {
      final controller = RapidFireController(
        vsync: tester,
        totalRounds: 1,
        secondsPerRound: 10,
      );

      controller.start();
      // time should be close to the secondsPerRound value
      expect(controller.timeNotifier.value, greaterThan(0));

      controller.pause();
      controller.dispose();
    });
  });
}
