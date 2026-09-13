import 'dart:math';

import '../number_words.dart';

enum ChallengeCategory { mixed, listen, match, build }

extension CategoryLabel on ChallengeCategory {
  String get label => switch (this) {
    ChallengeCategory.mixed => 'Zahlenmix',
    ChallengeCategory.listen => 'Hörspur',
    ChallengeCategory.match => 'Zahlwort finden',
    ChallengeCategory.build => 'Bausteine ordnen',
  };
  String get description => switch (this) {
    ChallengeCategory.mixed =>
      'Zehn Aufgaben. Drei Spielarten. Dein Zahlengefühl zählt.',
    ChallengeCategory.listen =>
      'Höre die Zahl und wähle die richtigen Ziffern.',
    ChallengeCategory.match => 'Finde zu den Ziffern das passende Zahlwort.',
    ChallengeCategory.build =>
      'Setze die Wortbausteine in die richtige Reihenfolge.',
  };
}

extension ModeLabel on SpeechMode {
  String get label =>
      this == SpeechMode.traditional ? 'Traditionell' : 'Links nach rechts';
  String get example =>
      this == SpeechMode.traditional ? 'einundzwanzig' : 'zwanzigeins';
  String word(int number) => this == SpeechMode.traditional
      ? NumberWords.traditional(number)
      : NumberWords.placeValue(number);
}

/// Local practice rules only. Online tasks must be supplied by the server.
class ChallengeQuestion {
  ChallengeQuestion({
    required this.number,
    required this.category,
    required List<int> choices,
    required this.shuffleSeed,
  }) : choices = List.unmodifiable(choices);
  final int number;
  final ChallengeCategory category;
  final List<int> choices;
  final int shuffleSeed;

  String answer(SpeechMode mode) =>
      category == ChallengeCategory.listen ? '$number' : mode.word(number);
  List<String> options(SpeechMode mode) => choices
      .map((n) => category == ChallengeCategory.listen ? '$n' : mode.word(n))
      .toList();
  List<String> tokens(SpeechMode mode) {
    final direct = NumberWords.placeValueParts(number);
    final parts = mode == SpeechMode.placeValue
        ? direct
        : <String>[
            number % 10 == 1 ? 'ein' : NumberWords.traditional(number % 10),
            'und',
            NumberWords.traditional(number ~/ 10 * 10),
          ];
    return List<String>.from(parts)..shuffle(Random(shuffleSeed));
  }
}

class ChallengeRound {
  ChallengeRound({
    required this.id,
    required this.category,
    required List<ChallengeQuestion> questions,
  }) : questions = List.unmodifiable(questions);
  static const rules = 'local-v1';
  final String id;
  final ChallengeCategory category;
  final List<ChallengeQuestion> questions;
}

class ChallengeFactory {
  ChallengeFactory({Random? random}) : random = random ?? Random();
  final Random random;
  ChallengeRound create(ChallengeCategory category) {
    final kinds = List.generate(
      10,
      (i) => category == ChallengeCategory.mixed
          ? [
              ChallengeCategory.listen,
              ChallengeCategory.match,
              ChallengeCategory.build,
            ][i % 3]
          : category,
    )..shuffle(random);
    final questions = kinds.map((kind) {
      final pool = [
        for (int n = 11; n <= 99; n++)
          if (kind != ChallengeCategory.build || (n >= 21 && n % 10 != 0)) n,
      ]..shuffle(random);
      final number = pool.first;
      final distractors = pool.skip(1).take(3);
      final choices = [number, ...distractors]..shuffle(random);
      return ChallengeQuestion(
        number: number,
        category: kind,
        choices: choices,
        shuffleSeed: random.nextInt(1 << 30),
      );
    }).toList();
    return ChallengeRound(
      id: '${DateTime.now().microsecondsSinceEpoch}-${random.nextInt(1 << 30)}',
      category: category,
      questions: questions,
    );
  }
}

class ChallengeResult {
  const ChallengeResult({
    required this.id,
    required this.category,
    required this.mode,
    required this.correct,
    required this.total,
    required this.elapsedMs,
    required this.playedAt,
    required this.eligible,
    this.rules = ChallengeRound.rules,
  });
  final String id;
  final ChallengeCategory category;
  final SpeechMode mode;
  final int correct;
  final int total;
  final int elapsedMs;
  final DateTime playedAt;
  final bool eligible;
  final String rules;
  String get boardKey => '${category.name}/${mode.name}/$rules/$total';
  String get timeLabel => '${(elapsedMs / 1000).toStringAsFixed(1)} s';
  int compareScore(ChallengeResult other) {
    final accuracy = other.correct.compareTo(correct);
    return accuracy != 0 ? accuracy : elapsedMs.compareTo(other.elapsedMs);
  }

  Map<String, Object> toJson() => {
    'id': id,
    'category': category.name,
    'mode': mode.name,
    'correct': correct,
    'total': total,
    'elapsedMs': elapsedMs,
    'playedAt': playedAt.toIso8601String(),
    'eligible': eligible,
    'rules': rules,
  };
  factory ChallengeResult.fromJson(Map<String, dynamic> json) {
    final result = ChallengeResult(
      id: json['id'] as String,
      category: ChallengeCategory.values.byName(json['category'] as String),
      mode: SpeechMode.values.byName(json['mode'] as String),
      correct: json['correct'] as int,
      total: json['total'] as int,
      elapsedMs: json['elapsedMs'] as int,
      playedAt: DateTime.parse(json['playedAt'] as String),
      eligible: json['eligible'] as bool,
      rules: json['rules'] as String,
    );
    if (result.total <= 0 ||
        result.correct < 0 ||
        result.correct > result.total ||
        result.elapsedMs < 0) {
      throw const FormatException('Invalid local result');
    }
    return result;
  }
}
