import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/app_theme.dart';
import '../../domain/lesson.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';

class LearningPathScreen extends StatelessWidget {
  const LearningPathScreen({
    super.key,
    required this.appState,
    required this.speechService,
  });

  final AppState appState;
  final SpeechService speechService;

  Future<void> _open(BuildContext context, int index) async {
    if (!appState.isUnlocked(index)) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => LessonScreen(
          lesson: lessons[index],
          appState: appState,
          speechService: speechService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(
                child: PageIntro(
                  eyebrow: 'Dein Lernweg',
                  title: 'Die direkte Route',
                  subtitle: 'Sechs kurze Stationen zeigen dir, wie sich Zahlen hören, lesen und vergleichen lassen.',
                ),
              ),
              const SizedBox(width: 12),
              EnergyBadge(value: appState.clarityEnergy),
            ],
          ),
          const SizedBox(height: 30),
          ...List<Widget>.generate(lessons.length, (int index) {
            final bool unlocked = appState.isUnlocked(index);
            final bool completed = appState.isCompleted(lessons[index].id);
            return _PathNode(
              key: Key('lesson-node-$index'),
              lesson: lessons[index],
              index: index,
              unlocked: unlocked,
              completed: completed,
              onTap: () => _open(context, index),
            );
          }),
          const SizedBox(height: 12),
          const ContentCard(
            child: Row(
              children: <Widget>[
                Icon(Icons.museum_rounded, color: AppColors.violet, size: 34),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Entdecke das Zahlenlabor im Lernbereich und das Zahlenmuseum unter Mehr.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    super.key,
    required this.lesson,
    required this.index,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final LessonDefinition lesson;
  final int index;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double indent = MediaQuery.sizeOf(context).width < 500
        ? 0
        : (index.isOdd ? 80 : 0);
    final Color color = completed
        ? AppColors.darkGreen
        : unlocked
        ? AppColors.green
        : const Color(0xFFB7C1BD);

    return Padding(
      padding: EdgeInsets.only(left: indent, bottom: 18),
      child: Semantics(
        button: true,
        enabled: unlocked,
        label:
            '${lesson.title}, ${completed
                ? 'abgeschlossen'
                : unlocked
                ? 'verfügbar'
                : 'gesperrt'}',
        child: InkWell(
          onTap: unlocked ? onTap : null,
          borderRadius: BorderRadius.circular(26),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: unlocked
                    ? color.withValues(alpha: 0.32)
                    : AppColors.border,
                width: 2,
              ),
              boxShadow: unlocked
                  ? <BoxShadow>[
                      BoxShadow(
                        color: color.withValues(alpha: 0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 68,
                  height: 68,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: completed
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 34,
                        )
                      : unlocked
                      ? Text(
                          lesson.icon,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        )
                      : const Icon(Icons.lock_rounded, color: Colors.white),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        lesson.chapter,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(lesson.subtitle),
                    ],
                  ),
                ),
                if (unlocked) Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
