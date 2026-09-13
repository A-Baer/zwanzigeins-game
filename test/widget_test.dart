import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zwanzigeins_game/app/app_state.dart';
import 'package:zwanzigeins_game/app/app_theme.dart';
import 'package:zwanzigeins_game/app/zwanzigeins_app.dart';
import 'package:zwanzigeins_game/data/progress_store.dart';
import 'package:zwanzigeins_game/domain/lesson.dart';
import 'package:zwanzigeins_game/services/speech_service.dart';
import 'package:zwanzigeins_game/ui/screens/lesson_screen.dart';
import 'package:zwanzigeins_game/ui/screens/number_lab_screen.dart';
import 'package:zwanzigeins_game/ui/home_shell.dart';
import 'package:zwanzigeins_game/data/challenge_store.dart';
import 'package:zwanzigeins_game/app/challenge_state.dart';

void main() {
  testWidgets('home updates after completing a lesson without changing tabs', (
    tester,
  ) async {
    final state = await AppState.load(MemoryProgressStore());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: HomeShell(
          appState: state,
          speechService: FakeSpeechService(),
          challengeState: await ChallengeState.load(MemoryChallengeStore()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lernen'));
    await tester.pumpAndSettle();
    expect(find.text('Zehner zuerst'), findsOneWidget);
    await state.recordLesson(
      lessonId: 'first-turns',
      correctAnswers: 7,
      totalAnswers: 7,
    );
    await tester.pumpAndSettle();
    expect(find.text('Hörspur'), findsOneWidget);
    expect(find.text('1 / 6'), findsOneWidget);
  });

  testWidgets('number lab changes both forms and handles unavailable speech', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: NumberLabScreen(speechService: UnavailableSpeechService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('zwanzigeins'), findsOneWidget);
    expect(find.text('einundzwanzig'), findsOneWidget);
    await tester.tap(find.byTooltip('Einer erhöhen'));
    await tester.pumpAndSettle();
    expect(find.text('zwanzigzwei'), findsOneWidget);
    expect(find.text('zweiundzwanzig'), findsOneWidget);
    await tester.ensureVisible(find.text('Anhören').first);
    await tester.tap(find.text('Anhören').first);
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Sprachausgabe nicht verfügbar. Du kannst beide Formen hier lesen.',
      ),
      findsOneWidget,
    );
  });

  for (final size in [
    const Size(320, 700),
    const Size(390, 844),
    const Size(1300, 900),
  ]) {
    testWidgets('home and lab fit at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ZwanzigeinsApp(
          progressStore: MemoryProgressStore(),
          challengeStore: MemoryChallengeStore(),
          speechService: FakeSpeechService(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Lernen'));
      await tester.pumpAndSettle();
      final lab = find.byKey(const Key('open-number-lab'));
      await tester.ensureVisible(lab);
      await tester.tap(lab);
      await tester.pumpAndSettle();
      expect(find.text('Eine Zahl. Zwei Wege.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('shows the learning home and opens the first lesson', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ZwanzigeinsApp(
        progressStore: MemoryProgressStore(),
        challengeStore: MemoryChallengeStore(),
        speechService: FakeSpeechService(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lernen'));
    await tester.pumpAndSettle();
    expect(find.text('Entwirr die Zahlen!'), findsOneWidget);
    expect(find.text('Lernweg fortsetzen'), findsOneWidget);
    expect(find.text('Challenges'), findsOneWidget);

    await tester.tap(find.byKey(const Key('continue-button')));
    await tester.pumpAndSettle();

    expect(find.text('Zehner zuerst'), findsWidgets);
    expect(find.byKey(const Key('exercise-prompt')), findsOneWidget);
    expect(find.byKey(const Key('next-button')), findsOneWidget);
  });

  testWidgets('adapts navigation to a wide desktop window', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1300, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ZwanzigeinsApp(
        progressStore: MemoryProgressStore(),
        challengeStore: MemoryChallengeStore(),
        speechService: FakeSpeechService(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('exposes the current association application from More', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ZwanzigeinsApp(
        progressStore: MemoryProgressStore(),
        challengeStore: MemoryChallengeStore(),
        speechService: FakeSpeechService(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Mehr'));
    await tester.pumpAndSettle();

    expect(find.text('Aufnahmeantrag für den Verein'), findsOneWidget);
    expect(find.text('MITGLIEDSCHAFT & ANTRAG ÖFFNEN'), findsOneWidget);
  });

  testWidgets('offers a readable fallback when speech is unavailable', (
    WidgetTester tester,
  ) async {
    final AppState state = await AppState.load(MemoryProgressStore());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LessonScreen(
          lesson: lessons[1],
          appState: state,
          speechService: UnavailableSpeechService(),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('speak-button')));
    await tester.pump();

    expect(find.byKey(const Key('speech-fallback')), findsOneWidget);
  });

  testWidgets('shows the smaller reward when repeating a lesson', (
    WidgetTester tester,
  ) async {
    final MemoryProgressStore store = MemoryProgressStore(
      initial: const ProgressSnapshot(
        completedLessonIds: <String>{'first-turns'},
        clarityEnergy: 10,
        correctAnswers: 7,
        totalAnswers: 7,
      ),
    );
    final AppState state = await AppState.load(store);
    final List<Exercise> expected = ExerciseFactory(random: Random(7))
        .create(lessons.first);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LessonScreen(
          lesson: lessons.first,
          appState: state,
          speechService: FakeSpeechService(),
          exerciseFactory: ExerciseFactory(random: Random(7)),
        ),
      ),
    );

    for (final Exercise exercise in expected) {
      await tester.tap(find.byKey(Key('answer-${exercise.answer}')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('next-button')));
      await tester.pumpAndSettle();
    }

    expect(
      find.text('+2 Klarheitsenergie für deine Übungsrunde'),
      findsOneWidget,
    );
    expect(state.clarityEnergy, 12);
  });
}

class MemoryProgressStore implements ProgressStore {
  MemoryProgressStore({ProgressSnapshot? initial})
    : snapshot =
          initial ??
          const ProgressSnapshot(
            completedLessonIds: <String>{},
            clarityEnergy: 0,
            correctAnswers: 0,
            totalAnswers: 0,
          );

  ProgressSnapshot snapshot;

  @override
  Future<void> clear() async {
    snapshot = const ProgressSnapshot(
      completedLessonIds: <String>{},
      clarityEnergy: 0,
      correctAnswers: 0,
      totalAnswers: 0,
    );
  }

  @override
  Future<ProgressSnapshot> load() async => snapshot;

  @override
  Future<void> save(ProgressSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class FakeSpeechService implements SpeechService {
  @override
  Future<bool> speak(String text) async => true;

  @override
  Future<void> stop() async {}
}

class UnavailableSpeechService implements SpeechService {
  @override
  Future<bool> speak(String text) async => false;

  @override
  Future<void> stop() async {}
}
