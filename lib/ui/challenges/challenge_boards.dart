import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../app/challenge_state.dart';
import '../../domain/challenges/challenge.dart';
import '../../domain/number_words.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';
import 'challenge_hub.dart';

class ChallengeBoards extends StatefulWidget {
  const ChallengeBoards({super.key, required this.state, required this.speech});
  final ChallengeState state;
  final SpeechService speech;
  @override
  State<ChallengeBoards> createState() => _ChallengeBoardsState();
}

class _ChallengeBoardsState extends State<ChallengeBoards> {
  ChallengeCategory _category = ChallengeCategory.mixed;
  SpeechMode _mode = SpeechMode.traditional;
  @override
  Widget build(BuildContext context) {
    final bests = widget.state.bests
        .where(
          (r) =>
              r.category == _category &&
              r.mode == _mode &&
              r.rules == ChallengeRound.rules &&
              r.total == 10,
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const PageIntro(
          eyebrow: 'Deine Disziplin. Dein Bestwert.',
          title: 'Ranglisten',
          subtitle: 'Öffentliche Bestenlisten folgen mit dem Online-Spiel. Hier siehst du schon jetzt deine persönlichen Bestwerte auf diesem Gerät.',
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in ChallengeCategory.values)
              ChoiceChip(
                label: Text(c.label),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              ),
          ],
        ),
        const SizedBox(height: 18),
        ModePicker(value: _mode, onChanged: (m) => setState(() => _mode = m)),
        const SizedBox(height: 14),
        ContentCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DEIN LOKALER BESTWERT',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 12),
              if (bests.isEmpty)
                const Text('Hier ist noch Platz für deinen ersten Versuch.')
              else ...[
                Text(
                  '${bests.single.correct} / ${bests.single.total} richtig',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text('${bests.single.timeLabel} · ${bests.single.mode.label}'),
              ],
              const SizedBox(height: 12),
              const Text(
                '10 Aufgaben · richtig vor schnell · keine Online-Platzierung',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => ChallengeSetupScreen(
                state: widget.state,
                speech: widget.speech,
                category: _category,
                duel: false,
                initialMode: _mode,
              ),
            ),
          ),
          child: const Text('In dieser Kategorie spielen'),
        ),
        const SizedBox(height: 22),
        const Text(
          'Lokale Zeiten hängen unter anderem von Gerät und Sprachausgabe ab. Sie werden später nicht in öffentliche Ranglisten übernommen.',
        ),
      ],
    );
  }
}

class ChallengeProfile extends StatefulWidget {
  const ChallengeProfile({
    super.key,
    required this.state,
    required this.onLearningProgress,
  });
  final ChallengeState state;
  final VoidCallback onLearningProgress;
  @override
  State<ChallengeProfile> createState() => _ChallengeProfileState();
}

class _ChallengeProfileState extends State<ChallengeProfile> {
  bool _busy = false;
  Future<void> _change(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Änderung konnte nicht gespeichert werden. Bitte erneut versuchen.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Challenge-Ergebnisse löschen?'),
        content: const Text(
          'Lokale Bestwerte und die letzten Versuche werden gelöscht. Dein Lernfortschritt bleibt erhalten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (yes == true && mounted) await _change(widget.state.clearResults);
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const PageIntro(
        eyebrow: 'Dein Profil',
        title: 'Dein Zahlengefühl wächst.',
        subtitle: 'Du spielst lokal ohne Konto. Online-Profil, Einladungen und öffentliche Ergebnisse folgen später.',
      ),
      const SizedBox(height: 24),
      Text(
        'Bevorzugte Sprechweise',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      IgnorePointer(
        ignoring: _busy,
        child: ModePicker(
          value: widget.state.preferredMode,
          onChanged: (m) => _change(() => widget.state.setMode(m)),
        ),
      ),
      if (_busy) const LinearProgressIndicator(),
      const SizedBox(height: 20),
      ActionCard(
        icon: Icons.route_rounded,
        title: 'Dein Lernfortschritt',
        text: 'Gemeisterte Stationen und Klarheitsenergie.',
        action: 'Fortschritt ansehen',
        onTap: widget.onLearningProgress,
      ),
      const SizedBox(height: 24),
      Text(
        'Letzte Einzelversuche',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 12),
      if (widget.state.results.isEmpty)
        const ContentCard(
          child: Text('Dein erster Zahlenmix wartet auf dich.'),
        ),
      for (final r in widget.state.results.take(10))
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.category.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${r.mode.label} · ${r.correct}/${r.total} · ${r.timeLabel}',
                ),
                if (!r.eligible) const Text('Training ohne Bestwert'),
              ],
            ),
          ),
        ),
      const SizedBox(height: 16),
      TextButton(
        onPressed: _busy || widget.state.results.isEmpty ? null : _clear,
        child: const Text('Lokale Challenge-Ergebnisse löschen'),
      ),
    ],
  );
}
