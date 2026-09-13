import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../app/challenge_state.dart';
import '../../domain/challenges/challenge.dart';
import '../../domain/number_words.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';
import 'challenge_round_screen.dart';

class ModePicker extends StatelessWidget {
  const ModePicker({super.key, required this.value, required this.onChanged});
  final SpeechMode value;
  final ValueChanged<SpeechMode> onChanged;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final mode in [SpeechMode.traditional, SpeechMode.placeValue])
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Semantics(
            selected: value == mode,
            child: OutlinedButton(
              onPressed: () => onChanged(mode),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: value == mode
                    ? const Color(0xFFE8F3DD)
                    : Colors.white,
                side: BorderSide(
                  color: value == mode ? AppColors.darkGreen : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    value == mode
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(mode.example),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

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
    this.initialMode,
  });
  final ChallengeState state;
  final SpeechService speech;
  final ChallengeCategory category;
  final bool duel;
  final SpeechMode? initialMode;
  @override
  State<ChallengeSetupScreen> createState() => _ChallengeSetupScreenState();
}

class _ChallengeSetupScreenState extends State<ChallengeSetupScreen> {
  late SpeechMode _first = widget.initialMode ?? widget.state.preferredMode;
  SpeechMode _second = SpeechMode.placeValue;
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
                    ? 'Jede Person wählt ihre eigene Sprechweise. Ihr bekommt denselben zufälligen Aufgabenmix.'
                    : 'Wähle deine Sprechweise. Deine Bestwerte werden für beide Modi getrennt gespeichert.',
              ),
              const SizedBox(height: 24),
              Text(
                widget.duel ? 'Spieler 1' : 'Sprechweise',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ModePicker(
                value: _first,
                onChanged: (m) => setState(() => _first = m),
              ),
              if (widget.duel) ...[
                const SizedBox(height: 16),
                Text(
                  'Spieler 2',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ModePicker(
                  value: _second,
                  onChanged: (m) => setState(() => _second = m),
                ),
              ],
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
                          modes: [_first, if (widget.duel) _second],
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
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
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
          const Chip(label: Text('Lokal')),
        ],
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: const Color(0xFF203D31),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DEIN KOPF. DEINE RICHTUNG.',
              style: TextStyle(
                color: Color(0xFFBCED86),
                letterSpacing: 1.2,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Wie gut ist dein\nZahlengefühl?',
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 14),
            const Text(
              'Hören, finden, zusammensetzen. Spiele den Zahlenmix in deiner Sprechweise.',
              style: TextStyle(
                color: Color(0xFFDAE8DF),
                fontSize: 17,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton.icon(
              key: const Key('start-mixed'),
              onPressed: () => openChallenge(
                context,
                state,
                speech,
                ChallengeCategory.mixed,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBCED86),
                foregroundColor: const Color(0xFF203D31),
              ),
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Zahlenmix spielen'),
            ),
            const SizedBox(height: 12),
            const Text(
              '10 Aufgaben · persönlicher Versuch',
              style: TextStyle(color: Color(0xFFDAE8DF)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      ActionCard(
        icon: Icons.people_alt_rounded,
        title: 'Fordert euch heraus',
        text: 'Zwei Personen, ein Gerät. Gleiche Aufgaben, freie Sprechweise.',
        action: 'Lokales Duell starten',
        onTap: () => openChallenge(
          context,
          state,
          speech,
          ChallengeCategory.mixed,
          duel: true,
        ),
      ),
      const SizedBox(height: 14),
      const ContentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Online-Duelle kommen als Nächstes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'Freunde einladen und zufällige Gegner finden ist noch nicht verfügbar. Bis dahin könnt ihr an einem Gerät gegeneinander spielen.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 26),
      Text(
        'Finde deine Disziplin',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      for (final category in ChallengeCategory.values.where(
        (c) => c != ChallengeCategory.mixed,
      )) ...[
        ActionCard(
          icon: categoryIcon(category),
          title: category.label,
          text: category.description,
          action: 'Kategorie trainieren',
          onTap: () => openChallenge(context, state, speech, category),
        ),
        const SizedBox(height: 12),
      ],
      TextButton.icon(
        onPressed: onBoards,
        icon: const Icon(Icons.leaderboard_rounded),
        label: const Text('Meine Bestwerte ansehen'),
      ),
      const SizedBox(height: 12),
      ActionCard(
        icon: Icons.route_rounded,
        title: 'Zahlen verstehen. In deinem Tempo.',
        text: 'Entdecke beide Sprechweisen im Zahlenlabor oder folge deinem Lernweg.',
        action: 'Zum Lernbereich',
        onTap: onLearn,
      ),
    ],
  );
}

IconData categoryIcon(ChallengeCategory category) => switch (category) {
  ChallengeCategory.mixed => Icons.shuffle_rounded,
  ChallengeCategory.listen => Icons.headphones_rounded,
  ChallengeCategory.match => Icons.find_in_page_rounded,
  ChallengeCategory.build => Icons.extension_rounded,
};

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
    required this.action,
    required this.onTap,
  });
  final IconData icon;
  final String title, text, action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.darkGreen, size: 28),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(text),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    action,
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.darkGreen,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
