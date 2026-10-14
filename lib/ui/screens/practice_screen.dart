import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/app_theme.dart';
import '../../domain/lesson.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';
import 'number_lab_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({
    super.key,
    required this.appState,
    required this.speechService,
  });

  final AppState appState;
  final SpeechService speechService;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageIntro(
            eyebrow: 'Freies Training',
            title: 'Wähle eine Übung',
            subtitle: 'Hier kannst du jede Spielart unabhängig vom Lernweg wiederholen.',
          ),
          const SizedBox(height: 24),
          Card(
            color: const Color(0xFFE7F8EE),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: const Icon(Icons.tune_rounded, color: AppColors.violet),
              title: const Text('Zahlenlabor'),
              subtitle: const Text(
                'Zehner und Einer verändern, beide Sprechweisen anhören.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => NumberLabScreen(speechService: speechService),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final int columns = constraints.maxWidth >= 760 ? 3 : 1;
              final double width =
                  (constraints.maxWidth - (columns - 1) * 16) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: lessons.map((LessonDefinition lesson) {
                  return SizedBox(
                    width: width,
                    child: _PracticeCard(
                      lesson: lesson,
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => LessonScreen(
                            lesson: lesson,
                            appState: appState,
                            speechService: speechService,
                            completesPath: false,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.lesson, required this.onTap});

  final LessonDefinition lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 62,
                height: 62,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE7F8EE),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  lesson.icon,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 7),
              Text(lesson.subtitle),
              const SizedBox(height: 18),
              const Row(
                children: <Widget>[
                  Text(
                    'STARTEN',
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.arrow_forward_rounded, color: AppColors.darkGreen),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
