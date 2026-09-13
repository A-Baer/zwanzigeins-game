import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/app_theme.dart';
import '../../domain/lesson.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';
import 'number_lab_screen.dart';
import 'practice_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.appState,
    required this.speechService,
    required this.showLearningPath,
  });

  final AppState appState;
  final SpeechService speechService;
  final VoidCallback showLearningPath;

  int get _nextLessonIndex {
    for (int i = 0; i < lessons.length; i++) {
      if (!appState.isCompleted(lessons[i].id) && appState.isUnlocked(i)) {
        return i;
      }
    }
    return lessons.length - 1;
  }

  @override
  Widget build(BuildContext context) {
    final LessonDefinition next = lessons[_nextLessonIndex];
    final int completed = lessons
        .where((l) => appState.isCompleted(l.id))
        .length;
    void start() => Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LessonScreen(
          lesson: next,
          appState: appState,
          speechService: speechService,
        ),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const BrandLogo(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'zwanzigeins',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              EnergyBadge(value: appState.clarityEnergy),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: const Color(0xFF203D31),
              borderRadius: BorderRadius.circular(30),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final copy = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KLEINE SCHRITTE. KLARE ZAHLEN.',
                      style: TextStyle(
                        color: Color(0xFFAEE7C4),
                        fontSize: 11,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Entwirr die Zahlen!',
                      style: Theme.of(context).textTheme.displaySmall
                          ?.copyWith(color: Colors.white, fontSize: 36),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Erst die Zehner. Dann die Einer.\nEntdecke Zahlen in Leserichtung.',
                      style: TextStyle(
                        color: Color(0xFFDAE8DF),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton.icon(
                      key: const Key('continue-button'),
                      onPressed: start,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBCED86),
                        foregroundColor: const Color(0xFF203D31),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        completed == lessons.length
                            ? 'Noch einmal üben'
                            : 'Lernweg fortsetzen',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '7 Aufgaben · in deinem Tempo',
                      style: TextStyle(color: Color(0xFFDAE8DF), fontSize: 12),
                    ),
                  ],
                );
                if (constraints.maxWidth < 650) return copy;
                return Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 24),
                    const Expanded(child: _NumberPicture()),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Freie Übungen')),
                  body: PracticeScreen(
                    appState: appState,
                    speechService: speechService,
                  ),
                ),
              ),
            ),
            icon: const Icon(Icons.extension_rounded),
            label: const Text('Alle freien Übungen'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Deine nächste Station',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: showLearningPath,
                child: const Text('Lernweg'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            child: InkWell(
              onTap: start,
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3DD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_nextLessonIndex + 1}'.padLeft(2, '0'),
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            next.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(next.subtitle),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.darkGreen,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.route_rounded, color: AppColors.darkGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dein Lernweg',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '$completed / ${lessons.length}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completed / lessons.length,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  completed == lessons.length
                      ? 'Alle Stationen gemeistert. Bleib mit freiem Training dran!'
                      : 'Jede abgeschlossene Station öffnet die nächste.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Einfach mal ausprobieren',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFEEEBFA),
            child: InkWell(
              key: const Key('open-number-lab'),
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => NumberLabScreen(speechService: speechService),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      color: AppColors.violet,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dein Zahlenlabor',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Verändere eine Zahl. Höre beide Sprechweisen. Entdecke den Unterschied.',
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.violet,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberPicture extends StatelessWidget {
  const _NumberPicture();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final (digit, label, color) in [
            ('2', 'ZEHNER', const Color(0xFFBCED86)),
            ('1', 'EINER', const Color(0xFFF6D18B)),
          ])
            Flexible(
              child: Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Text(
                      digit,
                      style: const TextStyle(
                        fontSize: 76,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF203D31),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF203D31),
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'zwanzig → eins',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
    ],
  );
}
