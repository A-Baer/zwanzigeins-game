import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zwanzigeins_game/app/app_theme.dart';
import 'package:zwanzigeins_game/app/challenge_state.dart';
import 'package:zwanzigeins_game/app/zwanzigeins_app.dart';
import 'package:zwanzigeins_game/data/challenge_store.dart';
import 'package:zwanzigeins_game/domain/challenges/challenge.dart';
import 'package:zwanzigeins_game/domain/number_words.dart';
import 'package:zwanzigeins_game/ui/challenges/challenge_round_screen.dart';

import 'widget_test.dart'
    show MemoryProgressStore, FakeSpeechService, UnavailableSpeechService;

Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      250,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> solve(
  WidgetTester tester,
  ChallengeRound round,
  SpeechMode mode,
) async {
  await tap(tester, find.byKey(const Key('begin-challenge')));
  for (final q in round.questions) {
    if (q.category == ChallengeCategory.listen) {
      await tap(tester, find.byKey(const Key('challenge-speak')));
    }
    if (q.category == ChallengeCategory.build) {
      final tokens = mode == SpeechMode.placeValue
          ? NumberWords.placeValueParts(q.number)
          : [
              q.number % 10 == 1
                  ? 'ein'
                  : NumberWords.traditional(q.number % 10),
              'und',
              NumberWords.traditional(q.number ~/ 10 * 10),
            ];
      for (final token in tokens) {
        await tap(tester, find.byKey(Key('token-$token')));
      }
      await tap(tester, find.byKey(const Key('check-build')));
    } else {
      await tap(tester, find.byKey(Key('challenge-answer-${q.answer(mode)}')));
    }
    final next = find.byKey(const Key('challenge-next'));
    if (q == round.questions.last) {
      await reveal(tester, next);
      await tester.tap(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
    } else {
      await tap(tester, next);
    }
  }
}

void main() {
  testWidgets('complete mixed round saves a Zwanzigeins result', (
    tester,
  ) async {
    final state = await ChallengeState.load(MemoryChallengeStore());
    final round = ChallengeFactory(random: Random(4))
        .create(ChallengeCategory.mixed);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChallengeRoundScreen(
          round: round,
          modes: const [SpeechMode.placeValue],
          state: state,
          speechService: FakeSpeechService(),
        ),
      ),
    );
    await solve(tester, round, SpeechMode.placeValue);
    expect(find.text('Runde geschafft!'), findsOneWidget);
    expect(state.results.single.correct, 10);
    expect(state.bests.single.mode, SpeechMode.placeValue);
  });
  testWidgets('duel uses fixed speech roles and creates no personal record', (
    tester,
  ) async {
    final state = await ChallengeState.load(MemoryChallengeStore());
    final round = ChallengeFactory(random: Random(2))
        .create(ChallengeCategory.mixed);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChallengeRoundScreen(
          round: round,
          modes: const [SpeechMode.traditional, SpeechMode.placeValue],
          state: state,
          speechService: FakeSpeechService(),
        ),
      ),
    );
    await solve(tester, round, SpeechMode.traditional);
    expect(find.text('Spieler 2, bist du bereit?'), findsOneWidget);
    expect(find.text('10 / 10 richtig'), findsNothing);
    await solve(tester, round, SpeechMode.placeValue);
    expect(find.text('10 / 10 richtig'), findsNWidgets(2));
    expect(state.results, isEmpty);
    expect(state.bests, isEmpty);
  });
  testWidgets('audio fallback completes as practice without best', (
    tester,
  ) async {
    final state = await ChallengeState.load(MemoryChallengeStore());
    final round = ChallengeFactory(random: Random(1))
        .create(ChallengeCategory.listen);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChallengeRoundScreen(
          round: round,
          modes: const [SpeechMode.placeValue],
          state: state,
          speechService: UnavailableSpeechService(),
        ),
      ),
    );
    await solve(tester, round, SpeechMode.placeValue);
    expect(state.results.single.eligible, isFalse);
    expect(state.bests, isEmpty);
  });
  testWidgets('app backgrounding makes round ineligible', (tester) async {
    final state = await ChallengeState.load(MemoryChallengeStore());
    final round = ChallengeFactory(random: Random(1))
        .create(ChallengeCategory.match);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChallengeRoundScreen(
          round: round,
          modes: const [SpeechMode.placeValue],
          state: state,
          speechService: FakeSpeechService(),
        ),
      ),
    );
    await tap(tester, find.byKey(const Key('begin-challenge')));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    for (final q in round.questions) {
      await tap(
        tester,
        find.byKey(Key('challenge-answer-${q.answer(SpeechMode.placeValue)}')),
      );
      await tap(tester, find.byKey(const Key('challenge-next')));
    }
    expect(state.results.single.eligible, isFalse);
  });
  testWidgets('addition round shows equations and can be completed', (
    tester,
  ) async {
    final state = await ChallengeState.load(MemoryChallengeStore());
    final round = ChallengeFactory(random: Random(8))
        .create(ChallengeCategory.addition);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: ChallengeRoundScreen(
          round: round,
          modes: const [SpeechMode.placeValue],
          state: state,
          speechService: FakeSpeechService(),
        ),
      ),
    );

    await tap(tester, find.byKey(const Key('begin-challenge')));
    expect(find.byKey(const Key('addition-expression')), findsOneWidget);
    expect(find.text(round.questions.first.additionExpression), findsOneWidget);
    for (var index = 0; index < round.questions.length; index++) {
      final q = round.questions[index];
      final answer = index == 0
          ? q
                .options(SpeechMode.placeValue)
                .firstWhere(
                  (option) => option != q.answer(SpeechMode.placeValue),
                )
          : q.answer(SpeechMode.placeValue);
      await tap(tester, find.byKey(Key('challenge-answer-$answer')));
      if (index == 0) {
        expect(
          find.text('Fast. Rechne beide Zahlen noch einmal zusammen.'),
          findsOneWidget,
        );
      }
      await tap(tester, find.byKey(const Key('challenge-next')));
    }
    expect(state.results.single.category, ChallengeCategory.addition);
    expect(state.results.single.correct, 9);
  });
  testWidgets(
    'challenge rules are fixed and shared play precedes disciplines',
    (tester) async {
      tester.view.physicalSize = const Size(1300, 1400);
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

      final shared = find.byKey(const Key('shared-play-heading'));
      final disciplines = find.byKey(const Key('discipline-heading'));
      expect(
        tester.getTopLeft(shared).dy,
        lessThan(tester.getTopLeft(disciplines).dy),
      );
      expect(find.text('Kopfrechnen'), findsOneWidget);

      await tap(tester, find.text('Duell vorbereiten'));
      expect(find.text('Spieler 1'), findsOneWidget);
      expect(find.text('Traditionell'), findsOneWidget);
      expect(find.text('Spieler 2'), findsOneWidget);
      expect(find.text('Zwanzigeins'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNothing);
    },
  );

  testWidgets('rankings and profile offer no speech-mode selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      ZwanzigeinsApp(
        progressStore: MemoryProgressStore(),
        challengeStore: MemoryChallengeStore(),
        speechService: FakeSpeechService(),
      ),
    );
    await tester.pumpAndSettle();

    await tap(tester, find.text('Ranglisten'));
    expect(find.textContaining('ausschließlich'), findsOneWidget);
    expect(find.text('Traditionell'), findsNothing);

    await tap(tester, find.text('Profil'));
    expect(find.text('Bevorzugte Sprechweise'), findsNothing);
  });
  for (final size in [
    const Size(320, 700),
    const Size(390, 844),
    const Size(1300, 900),
  ]) {
    testWidgets('challenge navigation and setup fit $size', (tester) async {
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
      for (final label in ['Ranglisten', 'Profil', 'Lernen', 'Challenges']) {
        await tap(tester, find.text(label).last);
        expect(tester.takeException(), isNull);
      }
      await tap(tester, find.byKey(const Key('start-mixed')));
      expect(find.text('Deine Zahl. Deine Richtung.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tap(tester, find.byKey(const Key('start-configured-challenge')));
      await tap(tester, find.byKey(const Key('begin-challenge')));
      expect(tester.takeException(), isNull);
    });
  }
}
