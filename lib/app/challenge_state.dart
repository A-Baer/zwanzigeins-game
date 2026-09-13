import 'package:flutter/foundation.dart';

import '../data/challenge_store.dart';
import '../domain/challenges/challenge.dart';
import '../domain/number_words.dart';

class ChallengeState extends ChangeNotifier {
  ChallengeState._(this.store, this._snapshot);
  final ChallengeStore store;
  ChallengeSnapshot _snapshot;
  Future<void> _pending = Future<void>.value();
  static Future<ChallengeState> load(ChallengeStore store) async =>
      ChallengeState._(store, await store.load());
  SpeechMode get preferredMode => _snapshot.preferredMode;
  List<ChallengeResult> get results => List.unmodifiable(_snapshot.results);
  List<ChallengeResult> get bests => List.unmodifiable(_snapshot.bests);

  // Serialize read-modify-write operations; publish only after durable save.
  Future<void> _update(ChallengeSnapshot Function() create) {
    final operation = _pending.then((_) async {
      final next = create();
      await store.save(next);
      _snapshot = next;
      notifyListeners();
    });
    _pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> setMode(SpeechMode mode) => _update(
    () =>
        ChallengeSnapshot(results: results, bests: bests, preferredMode: mode),
  );
  Future<void> record(ChallengeResult result) => _update(() {
    if (results.any((r) => r.id == result.id) ||
        bests.any((r) => r.id == result.id)) {
      return _snapshot;
    }
    final updated = [...bests];
    if (result.eligible) {
      final index = updated.indexWhere((r) => r.boardKey == result.boardKey);
      if (index == -1) {
        updated.add(result);
      } else if (result.compareScore(updated[index]) < 0) {
        updated[index] = result;
      }
    }
    return ChallengeSnapshot(
      results: [result, ...results].take(50).toList(),
      bests: updated,
      preferredMode: preferredMode,
    );
  });
  Future<void> clearResults() =>
      _update(() => ChallengeSnapshot(preferredMode: preferredMode));
}
