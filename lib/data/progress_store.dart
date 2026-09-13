import 'package:shared_preferences/shared_preferences.dart';

class ProgressSnapshot {
  const ProgressSnapshot({
    required this.completedLessonIds,
    required this.clarityEnergy,
    required this.correctAnswers,
    required this.totalAnswers,
  });

  final Set<String> completedLessonIds;
  final int clarityEnergy;
  final int correctAnswers;
  final int totalAnswers;
}

abstract interface class ProgressStore {
  Future<ProgressSnapshot> load();
  Future<void> save(ProgressSnapshot snapshot);
  Future<void> clear();
}

class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferencesProgressStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _completedKey = 'completed_lessons';
  static const String _energyKey = 'clarity_energy';
  static const String _correctKey = 'correct_answers';
  static const String _totalKey = 'total_answers';

  final SharedPreferencesAsync _preferences;

  @override
  Future<ProgressSnapshot> load() async {
    return ProgressSnapshot(
      completedLessonIds:
          (await _preferences.getStringList(_completedKey) ?? <String>[])
              .toSet(),
      clarityEnergy: await _preferences.getInt(_energyKey) ?? 0,
      correctAnswers: await _preferences.getInt(_correctKey) ?? 0,
      totalAnswers: await _preferences.getInt(_totalKey) ?? 0,
    );
  }

  @override
  Future<void> save(ProgressSnapshot snapshot) async {
    await Future.wait(<Future<void>>[
      _preferences.setStringList(
        _completedKey,
        snapshot.completedLessonIds.toList()..sort(),
      ),
      _preferences.setInt(_energyKey, snapshot.clarityEnergy),
      _preferences.setInt(_correctKey, snapshot.correctAnswers),
      _preferences.setInt(_totalKey, snapshot.totalAnswers),
    ]);
  }

  @override
  Future<void> clear() async {
    await Future.wait(<Future<void>>[
      _preferences.remove(_completedKey),
      _preferences.remove(_energyKey),
      _preferences.remove(_correctKey),
      _preferences.remove(_totalKey),
    ]);
  }
}
