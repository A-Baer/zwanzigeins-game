import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../app/app_theme.dart';
import '../../domain/lesson.dart';
import '../widgets/common.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final int percentage = (appState.accuracy * 100).round();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageIntro(
            eyebrow: 'Dein Fortschritt',
            title: 'Jede Zahl wird klarer',
            subtitle: 'Du vergleichst dich nur mit dir selbst. Fehler gehören zum Lernen und kosten keinen Fortschritt.',
          ),
          const SizedBox(height: 28),
          if (appState.totalAnswers == 0)
            const EmptyProgress()
          else
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final int columns = constraints.maxWidth >= 680 ? 3 : 1;
                final double width =
                    (constraints.maxWidth - (columns - 1) * 14) / columns;
                return Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: <Widget>[
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.route_rounded,
                        value:
                            '${appState.completedLessonIds.length}/${lessons.length}',
                        label: 'Routen gemeistert',
                        color: AppColors.green,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.check_circle_rounded,
                        value: '$percentage %',
                        label: 'direkt richtig',
                        color: AppColors.violet,
                      ),
                    ),
                    SizedBox(
                      width: width,
                      child: _StatCard(
                        icon: Icons.bolt_rounded,
                        value: '${appState.clarityEnergy}',
                        label: 'Klarheitsenergie',
                        color: AppColors.orange,
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 22),
          ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Deine Stationen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                ...lessons.map((LessonDefinition lesson) {
                  final bool complete = appState.isCompleted(lesson.id);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: complete
                          ? const Color(0xFFE7F8EE)
                          : AppColors.canvas,
                      child: Icon(
                        complete
                            ? Icons.check_rounded
                            : Icons.more_horiz_rounded,
                        color: complete ? AppColors.darkGreen : AppColors.muted,
                      ),
                    ),
                    title: Text(lesson.title),
                    subtitle: Text(complete ? 'Gemeistert' : 'Noch offen'),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 14),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
