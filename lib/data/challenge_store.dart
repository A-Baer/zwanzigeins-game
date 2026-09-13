import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/challenges/challenge.dart';
import '../domain/number_words.dart';

class ChallengeSnapshot {
  const ChallengeSnapshot({
    this.results = const [],
    this.bests = const [],
    this.preferredMode = SpeechMode.traditional,
  });
  final List<ChallengeResult> results;
  final List<ChallengeResult> bests;
  final SpeechMode preferredMode;
  Map<String, Object> toJson() => {
    'version': 1,
    'mode': preferredMode.name,
    'results': results.map((r) => r.toJson()).toList(),
    'bests': bests.map((r) => r.toJson()).toList(),
  };
  factory ChallengeSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1) {
      throw const FormatException('Unsupported challenge data');
    }
    List<ChallengeResult> read(String key) => (json[key] as List)
        .map(
          (r) => ChallengeResult.fromJson(Map<String, dynamic>.from(r as Map)),
        )
        .toList();
    return ChallengeSnapshot(
      results: read('results'),
      bests: read('bests'),
      preferredMode: SpeechMode.values.byName(json['mode'] as String),
    );
  }
}

abstract interface class ChallengeStore {
  Future<ChallengeSnapshot> load();
  Future<void> save(ChallengeSnapshot snapshot);
}

class PreferencesChallengeStore implements ChallengeStore {
  PreferencesChallengeStore({SharedPreferencesAsync? preferences})
    : preferences = preferences ?? SharedPreferencesAsync();
  final SharedPreferencesAsync preferences;
  static const key = 'challenge_practice_v1';
  @override
  Future<ChallengeSnapshot> load() async {
    final raw = await preferences.getString(key);
    if (raw == null) return const ChallengeSnapshot();
    return ChallengeSnapshot.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> save(ChallengeSnapshot snapshot) =>
      preferences.setString(key, jsonEncode(snapshot.toJson()));
}

class MemoryChallengeStore implements ChallengeStore {
  ChallengeSnapshot snapshot = const ChallengeSnapshot();
  @override
  Future<ChallengeSnapshot> load() async => snapshot;
  @override
  Future<void> save(ChallengeSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}
