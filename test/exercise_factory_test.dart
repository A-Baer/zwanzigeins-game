import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zwanzigeins_game/domain/lesson.dart';

void main() {
  for (final LessonDefinition lesson in lessons) {
    test('${lesson.id} creates seven answerable exercises', () {
      final List<Exercise> exercises = ExerciseFactory(random: Random(42))
          .create(lesson);

      expect(exercises, hasLength(7));
      for (final Exercise exercise in exercises) {
        expect(
          exercise.options,
          hasLength(lesson.kind == ExerciseKind.compare ? 2 : 4),
        );
        expect(exercise.options, contains(exercise.answer));
        expect(exercise.options.toSet().length, exercise.options.length);
        expect(exercise.explanation, isNotEmpty);
      }
    });
  }
}
