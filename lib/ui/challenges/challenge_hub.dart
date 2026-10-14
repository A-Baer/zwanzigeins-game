import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../app/challenge_state.dart';
import '../../domain/challenges/challenge.dart';
import '../../domain/number_words.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';
import 'challenge_round_screen.dart';

void openChallenge(
  BuildContext context,
  ChallengeState state,
  SpeechService speech,
  ChallengeCategory category, {
  bool duel = false,
}) {
  Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ChallengeSetupScreen(
        state: state,
        speech: speech,
        category: category,
        duel: duel,
      ),
    ),
  );
}

class ChallengeSetupScreen extends StatefulWidget {
  const ChallengeSetupScreen({
    super.key,
    required this.state,
    required this.speech,
    required this.category,
    required this.duel,
  });
  final ChallengeState state;
  final SpeechService speech;
  final ChallengeCategory category;
  final bool duel;
  @override
  State<ChallengeSetupScreen> createState() => _ChallengeSetupScreenState();
}

class _ChallengeSetupScreenState extends State<ChallengeSetupScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.duel ? 'Duell vorbereiten' : widget.category.label),
      backgroundColor: AppColors.canvas,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              PageIntro(
                eyebrow: widget.duel
                    ? 'Zwei Personen · ein Gerät'
                    : 'Persönliche Bestwerte',
                title: 'Deine Zahl. Deine Richtung.',
                subtitle: widget.duel
                    ? 'Spieler 1 nutzt die traditionelle, Spieler 2 die Zwanzigeins-Sprechweise. Beide bekommen denselben Aufgabenmix.'
                    : 'Alle Disziplinen werden in der Zwanzigeins-Sprechweise gespielt.',
              ),
              const SizedBox(height: 24),
              if (widget.duel)
                const Column(
                  children: [
                    _FixedModeCard(
                      player: 'Spieler 1',
                      mode: SpeechMode.traditional,
                    ),
                    SizedBox(height: 12),
                    _FixedModeCard(
                      player: 'Spieler 2',
                      mode: SpeechMode.placeValue,
                    ),
                  ],
                )
              else
                const _FixedModeCard(
                  player: 'Sprechweise',
                  mode: SpeechMode.placeValue,
                ),
              const SizedBox(height: 16),
              const Text(
                '10 Aufgaben · Zahlen 11–99\nBausteine: 21–99 ohne volle Zehner. Richtig vor schnell. Kein Zeitlimit.',
              ),
              const SizedBox(height: 10),
              const Text(
                'Lokale Übungsregeln. Für faire Online-Ranglisten werden später standardisierte Aufgaben, Audio und servergeprüfte Ergebnisse verwendet.',
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                key: const Key('start-configured-challenge'),
                onPressed: () =>
                    Navigator.of(context).pushReplacement<void, void>(
                      MaterialPageRoute(
                        builder: (_) => ChallengeRoundScreen(
                          round: ChallengeFactory().create(widget.category),
                          modes: widget.duel
                              ? const [
                                  SpeechMode.traditional,
                                  SpeechMode.placeValue,
                                ]
                              : const [SpeechMode.placeValue],
                          state: widget.state,
                          speechService: widget.speech,
                        ),
                      ),
                    ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(
                  widget.duel ? 'Duell starten' : 'Runde vorbereiten',
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _FixedModeCard extends StatelessWidget {
  const _FixedModeCard({required this.player, required this.mode});

  final String player;
  final SpeechMode mode;

  @override
  Widget build(BuildContext context) => ContentCard(
    child: Row(
      children: [
        const Icon(Icons.lock_rounded, color: AppColors.darkGreen),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(player, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 3),
              Text(mode.label, style: Theme.of(context).textTheme.titleLarge),
              Text('21 → ${mode.example}'),
            ],
          ),
        ),
      ],
    ),
  );
}

class ChallengeHub extends StatelessWidget {
  const ChallengeHub({
    super.key,
    required this.state,
    required this.speech,
    required this.onLearn,
    required this.onBoards,
  });
  final ChallengeState state;
  final SpeechService speech;
  final VoidCallback onLearn, onBoards;
  @override
  Widget build(BuildContext context) {
    final lastResult = state.results.firstOrNull;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
      children: [
        const BrandHeader(trailing: Chip(label: Text('Lokal'))),
        const SizedBox(height: 22),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            children: [
              const Positioned(
                right: -24,
                top: -34,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0x222DCE78),
                  size: 190,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final copy = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEINE RUNDE FÜR HEUTE',
                          style: TextStyle(
                            color: AppColors.green,
                            letterSpacing: 1.35,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Zahlen hören.\nRichtung erkennen.',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ein schneller Mix aus Hörspur, Zahlwort, Bausteinen und Kopfrechnen.',
                          style: TextStyle(
                            color: Color(0xFFC8D0CC),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          key: const Key('start-mixed'),
                          onPressed: () => openChallenge(
                            context,
                            state,
                            speech,
                            ChallengeCategory.mixed,
                          ),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Zahlenmix starten'),
                        ),
                        const SizedBox(height: 14),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            MetricPill(
                              icon: Icons.grid_view_rounded,
                              value: '10',
                              label: 'Aufgaben',
                              inverted: true,
                            ),
                            MetricPill(
                              icon: Icons.timer_outlined,
                              value: 'ca. 2',
                              label: 'Minuten',
                              inverted: true,
                            ),
                          ],
                        ),
                      ],
                    );
                    if (constraints.maxWidth < 650) return copy;
                    return Row(
                      children: [
                        Expanded(flex: 3, child: copy),
                        const SizedBox(width: 28),
                        const Expanded(flex: 2, child: _DirectionVisual()),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MetricPill(
              icon: Icons.sports_score_rounded,
              value: '${state.results.length}',
              label: 'Runden',
            ),
            MetricPill(
              icon: Icons.workspace_premium_outlined,
              value: '${state.bests.length}',
              label: 'Bestwerte',
            ),
            if (lastResult != null)
              MetricPill(
                icon: Icons.check_circle_outline_rounded,
                value: '${lastResult.correct}/${lastResult.total}',
                label: 'zuletzt',
              ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          'Gemeinsam spielen',
          key: const Key('shared-play-heading'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ActionCard(
          icon: Icons.people_alt_rounded,
          title: 'Duell an einem Gerät',
          text: 'Spieler 1 spricht traditionell, Spieler 2 spielt mit Zwanzigeins. Beide lösen dieselben Aufgaben.',
          action: 'Duell vorbereiten',
          dark: true,
          onTap: () => openChallenge(
            context,
            state,
            speech,
            ChallengeCategory.mixed,
            duel: true,
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Wähle deine Disziplin',
                key: const Key('discipline-heading'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            TextButton(onPressed: onBoards, child: const Text('Bestwerte')),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = 12.0;
            final columns = constraints.maxWidth >= 760 ? 3 : 1;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final category in ChallengeCategory.values.where(
                  (c) => c != ChallengeCategory.mixed,
                ))
                  SizedBox(
                    width: width,
                    child: ActionCard(
                      icon: categoryIcon(category),
                      title: category.label,
                      text: category.description,
                      action: 'Trainieren',
                      onTap: () =>
                          openChallenge(context, state, speech, category),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        ActionCard(
          icon: Icons.route_rounded,
          title: 'Lieber erst verstehen?',
          text: 'Folge dem Lernweg oder vergleiche beide Sprechweisen im Zahlenlabor.',
          action: 'Zum Lernbereich',
          onTap: onLearn,
        ),
        const SizedBox(height: 18),
        const Text(
          'Online-Duelle und öffentliche Ranglisten sind noch nicht verfügbar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    );
  }
}

class _DirectionVisual extends StatelessWidget {
  const _DirectionVisual();

  @override
  Widget build(BuildContext context) => Semantics(
    label: '21 wird von links nach rechts gelesen',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '21',
          style: TextStyle(
            color: Colors.white,
            fontSize: 96,
            height: .9,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.green,
            size: 46,
          ),
        ),
      ],
    ),
  );
}

IconData categoryIcon(ChallengeCategory category) => switch (category) {
  ChallengeCategory.mixed => Icons.shuffle_rounded,
  ChallengeCategory.listen => Icons.headphones_rounded,
  ChallengeCategory.match => Icons.find_in_page_rounded,
  ChallengeCategory.build => Icons.extension_rounded,
  ChallengeCategory.addition => Icons.calculate_rounded,
};

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.action,
    required this.onTap,
    this.dark = false,
  });
  final IconData icon;
  final String title, text, action;
  final VoidCallback onTap;
  final bool dark;
  @override
  Widget build(BuildContext context) => Card(
    color: dark ? AppColors.ink : Colors.white,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: dark ? AppColors.green : AppColors.surfaceGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: dark ? AppColors.ink : AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: dark ? Colors.white : AppColors.ink),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                color: dark ? const Color(0xFFC8D0CC) : AppColors.muted,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    action,
                    style: TextStyle(
                      color: dark ? AppColors.green : AppColors.darkGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: dark ? AppColors.green : AppColors.darkGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
