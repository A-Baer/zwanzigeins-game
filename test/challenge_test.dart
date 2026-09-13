import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zwanzigeins_game/app/challenge_state.dart';
import 'package:zwanzigeins_game/data/challenge_store.dart';
import 'package:zwanzigeins_game/domain/challenges/challenge.dart';
import 'package:zwanzigeins_game/domain/number_words.dart';

ChallengeResult result(
  String id, {
  int correct = 8,
  int ms = 2000,
  SpeechMode mode = SpeechMode.traditional,
  ChallengeCategory category = ChallengeCategory.match,
  bool eligible = true,
}) => ChallengeResult(
  id: id,
  category: category,
  mode: mode,
  correct: correct,
  total: 10,
  elapsedMs: ms,
  playedAt: DateTime.utc(2026, 9, 13),
  eligible: eligible,
);

void main() {
  test(
    'all categories have ten solvable tasks in both modes over many seeds',
    () {
      for (var seed = 0; seed < 100; seed++) {
        for (final category in ChallengeCategory.values) {
          final round = ChallengeFactory(random: Random(seed)).create(category);
          expect(round.questions.length, 10);
          if (category == ChallengeCategory.mixed) {
            expect(round.questions.map((q) => q.category).toSet().length, 3);
          }
          for (final q in round.questions) {
            expect(q.number, inInclusiveRange(11, 99));
            for (final mode in SpeechMode.values) {
              expect(q.options(mode).toSet().length, 4);
              expect(q.options(mode), contains(q.answer(mode)));
              if (q.category == ChallengeCategory.build) {
                final tokens = q.tokens(mode);
                final expected = mode == SpeechMode.placeValue
                    ? NumberWords.placeValueParts(q.number)
                    : [
                        q.number % 10 == 1
                            ? 'ein'
                            : NumberWords.traditional(q.number % 10),
                        'und',
                        NumberWords.traditional(q.number ~/ 10 * 10),
                      ];
                expect(tokens.toSet(), expected.toSet());
                expect(expected.join(), q.answer(mode));
                expect(q.tokens(mode), tokens);
              }
            }
          }
        }
      }
    },
  );
  test(
    'accuracy beats speed; modes and categories have independent records',
    () async {
      final store = MemoryChallengeStore();
      var state = await ChallengeState.load(store);
      await state.record(result('a', correct: 9, ms: 9000));
      await state.record(result('b', correct: 8, ms: 100));
      await state.record(result('c', correct: 9, ms: 8000));
      await state.record(result('d', mode: SpeechMode.placeValue));
      await state.record(result('e', category: ChallengeCategory.listen));
      await state.record(result('f', correct: 10, eligible: false));
      await state.record(result('f', correct: 10, eligible: false));
      state = await ChallengeState.load(store);
      expect(state.results.length, 6);
      expect(state.bests.map((r) => r.id), ['c', 'd', 'e']);
      await state.setMode(SpeechMode.placeValue);
      final encoded = jsonEncode(store.snapshot.toJson());
      final decoded = ChallengeSnapshot.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
      expect(decoded.preferredMode, SpeechMode.placeValue);
      expect(decoded.bests.map((r) => r.id), ['c', 'd', 'e']);
      await state.clearResults();
      expect(state.results, isEmpty);
      expect(state.bests, isEmpty);
      expect(state.preferredMode, SpeechMode.placeValue);
    },
  );
  test('best survives bounded history and writes serialize', () async {
    final state = await ChallengeState.load(MemoryChallengeStore());
    await state.record(result('best', correct: 10));
    await Future.wait([
      for (var i = 0; i < 55; i++) state.record(result('r$i')),
    ]);
    expect(state.results.length, 50);
    expect(state.bests.single.id, 'best');
  });
  test('failed save does not claim persistence and can be retried', () async {
    final store = FailingStore();
    final state = await ChallengeState.load(store);
    await expectLater(state.record(result('retry')), throwsStateError);
    expect(state.results, isEmpty);
    store.fail = false;
    await state.record(result('retry'));
    expect(state.results.single.id, 'retry');
  });
}

class FailingStore extends MemoryChallengeStore {
  bool fail = true;
  @override
  Future<void> save(ChallengeSnapshot snapshot) async {
    if (fail) throw StateError('disk unavailable');
    await super.save(snapshot);
  }
}
