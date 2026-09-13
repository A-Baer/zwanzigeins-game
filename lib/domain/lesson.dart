import 'dart:math';

import 'number_words.dart';

enum ExerciseKind { listen, build, compare }

class LessonDefinition {
  const LessonDefinition({
    required this.id,
    required this.chapter,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.numbers,
    required this.icon,
  });

  final String id;
  final String chapter;
  final String title;
  final String subtitle;
  final ExerciseKind kind;
  final String icon;
  final List<int> numbers;
}

const List<LessonDefinition> lessons = <LessonDefinition>[
  LessonDefinition(
    id: 'first-turns',
    chapter: 'Kapitel 1 · Die ersten Dreher',
    title: 'Zehner zuerst',
    subtitle: 'Baue Zahlen von 11 bis 19 in Leserichtung.',
    kind: ExerciseKind.build,
    numbers: <int>[11, 12, 13, 14, 15, 16, 17, 18, 19],
    icon: '10→1',
  ),
  LessonDefinition(
    id: 'tens-city',
    chapter: 'Kapitel 2 · Zehnerstadt',
    title: 'Hörspur',
    subtitle: 'Höre genau hin und finde die passende Zahl.',
    kind: ExerciseKind.listen,
    numbers: <int>[21, 24, 32, 37, 43, 46, 58, 64, 71, 86, 92, 97],
    icon: '♪',
  ),
  LessonDefinition(
    id: 'track-switch',
    chapter: 'Kapitel 3 · Das Stellenwertwerk',
    title: 'Gleiswechsel',
    subtitle: 'Erkenne die direkte Route von Zehner zu Einer.',
    kind: ExerciseKind.compare,
    numbers: <int>[21, 35, 42, 57, 63, 76, 84, 98],
    icon: 'Z→E',
  ),
  LessonDefinition(
    id: 'number-workshop',
    chapter: 'Kapitel 4 · Zahlenwerkstatt',
    title: 'Zahlen zusammensetzen',
    subtitle: 'Übertrage die direkte Sprechweise auf größere Zahlen.',
    kind: ExerciseKind.build,
    numbers: <int>[23, 34, 45, 56, 67, 78, 89, 91, 99],
    icon: 'Z+E',
  ),
  LessonDefinition(
    id: 'mirror-numbers',
    chapter: 'Kapitel 5 · Spiegelgasse',
    title: 'Dreher durchschauen',
    subtitle: 'Unterscheide 24 und 42, 37 und 73 beim Hören.',
    kind: ExerciseKind.listen,
    numbers: <int>[24, 42, 37, 73, 56, 65, 19, 91, 28, 82],
    icon: '⇄',
  ),
  LessonDefinition(
    id: 'route-master',
    chapter: 'Kapitel 6 · Klarblick',
    title: 'Dein Zahlenkompass',
    subtitle: 'Vergleiche beide Sprechweisen von 11 bis 99.',
    kind: ExerciseKind.compare,
    numbers: <int>[11, 16, 21, 38, 49, 54, 67, 75, 83, 99],
    icon: '✓',
  ),
];

class Exercise {
  const Exercise({
    required this.number,
    required this.prompt,
    required this.answer,
    required this.options,
    required this.explanation,
    required this.kind,
  });

  final int number;
  final String prompt;
  final String answer;
  final List<String> options;
  final String explanation;
  final ExerciseKind kind;
}

class ExerciseFactory {
  ExerciseFactory({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<Exercise> create(LessonDefinition lesson, {int count = 7}) {
    final List<int> pool = List<int>.from(lesson.numbers)..shuffle(_random);
    return List<Exercise>.generate(
      count,
      (int index) => _createExercise(lesson, pool[index % pool.length]),
    );
  }

  Exercise _createExercise(LessonDefinition lesson, int number) {
    final String direct = NumberWords.placeValue(number);
    switch (lesson.kind) {
      case ExerciseKind.build:
        return Exercise(
          number: number,
          prompt: 'Wie klingt $number auf der direkten Route?',
          answer: direct,
          options: _wordOptions(number),
          explanation: _placeValueExplanation(number),
          kind: lesson.kind,
        );
      case ExerciseKind.listen:
        return Exercise(
          number: number,
          prompt: 'Welche Zahl hörst du?',
          answer: '$number',
          options: _numberOptions(number),
          explanation: _placeValueExplanation(number),
          kind: lesson.kind,
        );
      case ExerciseKind.compare:
        return Exercise(
          number: number,
          prompt: 'Welche Form folgt bei $number den Stellenwerten?',
          answer: direct,
          options: <String>[direct, NumberWords.traditional(number)]
            ..shuffle(_random),
          explanation:
              '${number ~/ 10} Zehner kommen vor ${number % 10} Einern.',
          kind: lesson.kind,
        );
    }
  }

  List<String> _wordOptions(int number) {
    final String answer = NumberWords.placeValue(number);
    final Set<String> candidates = <String>{NumberWords.traditional(number)};
    for (final int delta in <int>[-11, -10, -1, 1, 10, 11]) {
      final int nearby = _nearby(number, delta);
      candidates
        ..add(NumberWords.placeValue(nearby))
        ..add(NumberWords.traditional(nearby));
    }
    final List<String> distractors =
        candidates.where((String option) => option != answer).toList()
          ..shuffle(_random);
    return <String>[answer, ...distractors.take(3)]..shuffle(_random);
  }

  List<String> _numberOptions(int number) {
    final int reversed = (number % 10) * 10 + number ~/ 10;
    final List<int> distractors = <int>{
      if (reversed >= 11) reversed,
      _nearby(number, 10),
      _nearby(number, -10),
      _nearby(number, 1),
      _nearby(number, 11),
      _nearby(number, -11),
    }.where((int value) => value != number).toList()..shuffle(_random);
    return <int>[
      number,
      ...distractors.take(3),
    ].map((int value) => '$value').toList()..shuffle(_random);
  }

  int _nearby(int number, int delta) => (number + delta).clamp(11, 99);

  String _placeValueExplanation(int number) {
    final List<String> parts = NumberWords.placeValueParts(number);
    if (parts.length == 1) return '$number ist ein voller Zehner.';
    return '${parts.first} zuerst, dann ${parts.last}: $number.';
  }
}
