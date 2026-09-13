import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/app_theme.dart';
import '../../domain/lesson.dart';
import '../../domain/number_words.dart';
import '../../services/speech_service.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.appState,
    required this.speechService,
    this.exerciseFactory,
    this.completesPath = true,
  });

  final LessonDefinition lesson;
  final AppState appState;
  final SpeechService speechService;
  final ExerciseFactory? exerciseFactory;
  final bool completesPath;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final List<Exercise> _exercises;
  int _index = 0;
  int _correct = 0;
  String? _selected;
  bool _finished = false;
  bool _saving = false;
  bool _speechUnavailable = false;
  int _earnedEnergy = 0;
  bool _passed = false;

  Exercise get _exercise => _exercises[_index];
  bool get _isCorrect => _selected == _exercise.answer;

  @override
  void initState() {
    super.initState();
    _exercises = (widget.exerciseFactory ?? ExerciseFactory()).create(
      widget.lesson,
    );
  }

  @override
  void dispose() {
    widget.speechService.stop();
    super.dispose();
  }

  Future<void> _speak() async {
    final bool worked = await widget.speechService.speak(
      NumberWords.speakable(_exercise.number, SpeechMode.placeValue),
    );
    if (!worked && mounted) {
      setState(() => _speechUnavailable = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Die Sprachausgabe ist auf diesem Gerät nicht verfügbar.',
          ),
        ),
      );
    }
  }

  void _select(String option) {
    if (_selected != null) return;
    setState(() {
      _selected = option;
      if (_isCorrect) _correct++;
    });
  }

  Future<void> _next() async {
    if (_selected == null || _saving) return;
    if (_index < _exercises.length - 1) {
      setState(() {
        _index++;
        _selected = null;
      });
      return;
    }

    setState(() => _saving = true);
    _passed = _correct * 10 >= _exercises.length * 7;
    final bool firstPathCompletion =
        widget.completesPath &&
        _passed &&
        !widget.appState.isCompleted(widget.lesson.id);
    _earnedEnergy = firstPathCompletion ? 10 : 2;
    await widget.appState.recordLesson(
      lessonId: widget.lesson.id,
      correctAnswers: _correct,
      totalAnswers: _exercises.length,
      completeLesson: widget.completesPath && _passed,
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _finished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) {
      return _CompletionScreen(
        correct: _correct,
        total: _exercises.length,
        earnedEnergy: _earnedEnergy,
        passed: _passed,
        isPractice: !widget.completesPath,
        onClose: () => Navigator.of(context).pop(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          tooltip: 'Lektion schließen',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 12,
            value: (_index + 1) / _exercises.length,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                '${_index + 1}/${_exercises.length}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        widget.lesson.title,
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _exercise.prompt,
                        key: const Key('exercise-prompt'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 26),
                      _ExerciseVisual(
                        exercise: _exercise,
                        onSpeak: _speak,
                        showTextFallback: _speechUnavailable,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _OptionsGrid(
                            exercise: _exercise,
                            selected: _selected,
                            onSelected: _select,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _selected == null
                            ? const SizedBox.shrink()
                            : _Feedback(
                                key: ValueKey<String>(_selected!),
                                correct: _isCorrect,
                                exercise: _exercise,
                              ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        key: const Key('next-button'),
                        onPressed: _selected == null ? null : _next,
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _index == _exercises.length - 1
                                    ? 'Lektion abschließen'
                                    : 'Weiter',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseVisual extends StatelessWidget {
  const _ExerciseVisual({
    required this.exercise,
    required this.onSpeak,
    required this.showTextFallback,
  });

  final Exercise exercise;
  final VoidCallback onSpeak;
  final bool showTextFallback;

  @override
  Widget build(BuildContext context) {
    if (exercise.kind == ExerciseKind.listen) {
      return Column(
        children: <Widget>[
          Center(
            child: Semantics(
              button: true,
              label: 'Zahl noch einmal anhören',
              child: InkWell(
                key: const Key('speak-button'),
                onTap: onSpeak,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 116,
                  height: 116,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDDF5EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    size: 54,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
          if (showTextFallback) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              'Lies stattdessen: „${NumberWords.speakable(exercise.number, SpeechMode.placeValue)}“',
              key: const Key('speech-fallback'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ],
      );
    }

    final int tens = exercise.number ~/ 10;
    final int ones = exercise.number % 10;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _DigitTile(label: 'ZEHNER', digit: '$tens', color: AppColors.darkGreen),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.arrow_forward_rounded, color: AppColors.muted),
        ),
        _DigitTile(label: 'EINER', digit: '$ones', color: AppColors.orange),
      ],
    );
  }
}

class _DigitTile extends StatelessWidget {
  const _DigitTile({
    required this.label,
    required this.digit,
    required this.color,
  });

  final String label;
  final String digit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          Text(
            digit,
            style: TextStyle(
              color: color,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsGrid extends StatelessWidget {
  const _OptionsGrid({
    required this.exercise,
    required this.selected,
    required this.onSelected,
  });

  final Exercise exercise;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= 560 ? 2 : 1;
        final double width =
            (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: exercise.options.map((String option) {
            final bool isSelected = option == selected;
            final bool isAnswer = option == exercise.answer;
            Color border = AppColors.border;
            Color background = Colors.white;
            IconData? icon;
            if (selected != null && isAnswer) {
              border = AppColors.success;
              background = const Color(0xFFE5F7F0);
              icon = Icons.check_circle_rounded;
            } else if (isSelected) {
              border = AppColors.error;
              background = const Color(0xFFFFECEC);
              icon = Icons.cancel_rounded;
            }

            return SizedBox(
              width: width,
              child: Semantics(
                button: true,
                selected: isSelected,
                child: InkWell(
                  key: Key('answer-$option'),
                  onTap: selected == null ? () => onSelected(option) : null,
                  borderRadius: BorderRadius.circular(17),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(minHeight: 62),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: border, width: 2),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (icon != null) Icon(icon, color: border),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({super.key, required this.correct, required this.exercise});

  final bool correct;
  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final Color color = correct ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            correct ? Icons.celebration_rounded : Icons.lightbulb_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              correct
                  ? 'Genau! ${exercise.explanation}'
                  : 'Fast! Richtig ist „${exercise.answer}“. ${exercise.explanation}',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionScreen extends StatelessWidget {
  const _CompletionScreen({
    required this.correct,
    required this.total,
    required this.earnedEnergy,
    required this.passed,
    required this.isPractice,
    required this.onClose,
  });

  final int correct;
  final int total;
  final int earnedEnergy;
  final bool passed;
  final bool isPractice;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: AppColors.orange,
                    size: 100,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPractice
                        ? 'Übungsrunde beendet!'
                        : passed
                        ? 'Route gemeistert!'
                        : 'Fast geschafft!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isPractice || passed
                        ? '$correct von $total Antworten waren direkt richtig.'
                        : '$correct von $total waren richtig. Für diese Route brauchst du mindestens 5 richtige Antworten.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2DB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(Icons.bolt_rounded, color: AppColors.orange),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            earnedEnergy == 10
                                ? '+10 Klarheitsenergie für den ersten Abschluss'
                                : '+2 Klarheitsenergie für deine Übungsrunde',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    key: const Key('finish-button'),
                    onPressed: onClose,
                    child: Text(
                      isPractice ? 'Zurück zum Training' : 'Zurück zum Lernweg',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
