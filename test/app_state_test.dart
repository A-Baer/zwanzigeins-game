import 'package:flutter_test/flutter_test.dart';
import 'package:zwanzigeins_game/app/app_state.dart';
import 'package:zwanzigeins_game/data/progress_store.dart';
import 'package:zwanzigeins_game/domain/lesson.dart';

void main() {
  test('all six stations unlock and restore sequentially', () async {
    final store = MemoryProgressStore();
    var state = await AppState.load(store);
    expect(state.isUnlocked(-1), isFalse);
    expect(state.isUnlocked(lessons.length), isFalse);
    for (var i = 0; i < lessons.length; i++) {
      expect(state.isUnlocked(i), isTrue);
      if (i + 1 < lessons.length) expect(state.isUnlocked(i + 1), isFalse);
      await state.recordLesson(
        lessonId: lessons[i].id,
        correctAnswers: 7,
        totalAnswers: 7,
      );
      state = await AppState.load(store);
    }
    expect(state.completedLessonIds.length, 6);
    expect(state.clarityEnergy, 60);
  });

  test('path lessons unlock sequentially and persist completion', () async {
    final MemoryProgressStore store = MemoryProgressStore();
    final AppState state = await AppState.load(store);

    expect(state.isUnlocked(0), isTrue);
    expect(state.isUnlocked(1), isFalse);

    await state.recordLesson(
      lessonId: 'first-turns',
      correctAnswers: 6,
      totalAnswers: 7,
    );

    expect(state.isUnlocked(1), isTrue);
    expect(store.snapshot.completedLessonIds, contains('first-turns'));
    expect(state.clarityEnergy, 10);
  });

  test('free practice records answers without completing the path', () async {
    final AppState state = await AppState.load(MemoryProgressStore());

    await state.recordLesson(
      lessonId: 'tens-city',
      correctAnswers: 5,
      totalAnswers: 7,
      completeLesson: false,
    );

    expect(state.completedLessonIds, isEmpty);
    expect(state.isUnlocked(1), isFalse);
    expect(state.correctAnswers, 5);
    expect(state.totalAnswers, 7);
    expect(state.clarityEnergy, 2);
  });

  test('repeating a completed lesson awards practice energy', () async {
    final AppState state = await AppState.load(MemoryProgressStore());

    await state.recordLesson(
      lessonId: 'first-turns',
      correctAnswers: 7,
      totalAnswers: 7,
    );
    await state.recordLesson(
      lessonId: 'first-turns',
      correctAnswers: 7,
      totalAnswers: 7,
    );

    expect(state.clarityEnergy, 12);
    expect(state.completedLessonIds, hasLength(1));
  });

  test('a lesson below seventy percent does not unlock the path', () async {
    final AppState state = await AppState.load(MemoryProgressStore());

    await state.recordLesson(
      lessonId: 'first-turns',
      correctAnswers: 4,
      totalAnswers: 7,
    );

    expect(state.completedLessonIds, isEmpty);
    expect(state.isUnlocked(1), isFalse);
    expect(state.clarityEnergy, 2);
  });
}

class MemoryProgressStore implements ProgressStore {
  ProgressSnapshot snapshot = const ProgressSnapshot(
    completedLessonIds: <String>{},
    clarityEnergy: 0,
    correctAnswers: 0,
    totalAnswers: 0,
  );

  @override
  Future<void> clear() async {}

  @override
  Future<ProgressSnapshot> load() async => snapshot;

  @override
  Future<void> save(ProgressSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}
