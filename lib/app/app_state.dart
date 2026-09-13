import 'package:flutter/foundation.dart';

import '../data/progress_store.dart';
import '../domain/lesson.dart';

class AppState extends ChangeNotifier {
  AppState._(this._store, ProgressSnapshot snapshot)
    : _completedLessonIds = Set<String>.from(snapshot.completedLessonIds),
      _clarityEnergy = snapshot.clarityEnergy,
      _correctAnswers = snapshot.correctAnswers,
      _totalAnswers = snapshot.totalAnswers;

  final ProgressStore _store;
  Set<String> _completedLessonIds;
  int _clarityEnergy;
  int _correctAnswers;
  int _totalAnswers;

  static Future<AppState> load(ProgressStore store) async {
    return AppState._(store, await store.load());
  }

  Set<String> get completedLessonIds =>
      Set<String>.unmodifiable(_completedLessonIds);
  int get clarityEnergy => _clarityEnergy;
  int get correctAnswers => _correctAnswers;
  int get totalAnswers => _totalAnswers;
  double get accuracy =>
      _totalAnswers == 0 ? 0 : _correctAnswers / _totalAnswers;

  bool isCompleted(String lessonId) => _completedLessonIds.contains(lessonId);

  bool isUnlocked(int lessonIndex) {
    if (lessonIndex < 0 || lessonIndex >= lessons.length) return false;
    return lessonIndex == 0 || isCompleted(lessons[lessonIndex - 1].id);
  }

  Future<void> recordLesson({
    required String lessonId,
    required int correctAnswers,
    required int totalAnswers,
    bool completeLesson = true,
  }) async {
    final bool qualifiesForCompletion =
        completeLesson &&
        totalAnswers > 0 &&
        correctAnswers * 10 >= totalAnswers * 7;
    final bool firstCompletion =
        qualifiesForCompletion && _completedLessonIds.add(lessonId);
    _clarityEnergy += firstCompletion ? 10 : 2;
    _correctAnswers += correctAnswers;
    _totalAnswers += totalAnswers;
    notifyListeners();
    await _persist();
  }

  Future<void> reset() async {
    _completedLessonIds = <String>{};
    _clarityEnergy = 0;
    _correctAnswers = 0;
    _totalAnswers = 0;
    notifyListeners();
    await _store.clear();
  }

  Future<void> _persist() {
    return _store.save(
      ProgressSnapshot(
        completedLessonIds: _completedLessonIds,
        clarityEnergy: _clarityEnergy,
        correctAnswers: _correctAnswers,
        totalAnswers: _totalAnswers,
      ),
    );
  }
}
