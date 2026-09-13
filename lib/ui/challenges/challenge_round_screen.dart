import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../app/challenge_state.dart';
import '../../domain/challenges/challenge.dart';
import '../../domain/number_words.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';

enum _Phase { handoff, playing, results }

class ChallengeRoundScreen extends StatefulWidget {
  const ChallengeRoundScreen({
    super.key,
    required this.round,
    required this.modes,
    required this.state,
    required this.speechService,
  });
  final ChallengeRound round;
  final List<SpeechMode> modes;
  final ChallengeState state;
  final SpeechService speechService;
  @override
  State<ChallengeRoundScreen> createState() => _ChallengeRoundScreenState();
}

class _ChallengeRoundScreenState extends State<ChallengeRoundScreen>
    with WidgetsBindingObserver {
  _Phase _phase = _Phase.handoff;
  final _clock = Stopwatch();
  final List<ChallengeResult> _results = [];
  final List<int> _selectedTokens = [];
  int _player = 0, _index = 0, _correct = 0, _elapsed = 0;
  bool _checked = false, _right = false, _fallback = false, _assisted = false;
  bool _heard = false,
      _speechPending = false,
      _saving = false,
      _saved = false,
      _allowExit = false;
  String? _saveError;
  bool get _duel => widget.modes.length == 2;
  SpeechMode get _mode => widget.modes[_player];
  ChallengeQuestion get _question => widget.round.questions[_index];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.stop();
    widget.speechService.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_phase == _Phase.playing &&
        (state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden)) {
      _assisted = true;
    }
  }

  void _begin() {
    if (_phase != _Phase.handoff) return;
    setState(() {
      _phase = _Phase.playing;
      _clock
        ..reset()
        ..start();
    });
  }

  Future<void> _speak() async {
    if (_speechPending || _checked) return;
    setState(() => _speechPending = true);
    bool worked = false;
    try {
      worked = await widget.speechService.speak(
        NumberWords.speakable(_question.number, _mode),
      );
    } catch (_) {
      worked = false;
    }
    if (!mounted) return;
    setState(() {
      _speechPending = false;
      _heard = worked;
      if (!worked) {
        _fallback = true;
        _assisted = true;
      }
    });
  }

  void _check(String answer) {
    if (_checked || _speechPending) return;
    _clock.stop();
    widget.speechService.stop();
    setState(() {
      _elapsed += _clock.elapsedMilliseconds;
      _right = answer == _question.answer(_mode);
      if (_right) _correct++;
      _checked = true;
    });
  }

  Future<void> _next() async {
    if (!_checked || _phase != _Phase.playing) return;
    if (_index + 1 < widget.round.questions.length) {
      setState(() {
        _index++;
        _checked = false;
        _fallback = false;
        _heard = false;
        _selectedTokens.clear();
        _clock
          ..reset()
          ..start();
      });
      return;
    }
    _results.add(
      ChallengeResult(
        id: '${widget.round.id}/$_player',
        category: widget.round.category,
        mode: _mode,
        correct: _correct,
        total: widget.round.questions.length,
        elapsedMs: _elapsed,
        playedAt: DateTime.now().toUtc(),
        eligible: !_assisted,
      ),
    );
    if (_duel && _player == 0) {
      setState(() {
        _player = 1;
        _index = 0;
        _correct = 0;
        _elapsed = 0;
        _checked = false;
        _fallback = false;
        _assisted = false;
        _heard = false;
        _selectedTokens.clear();
        _phase = _Phase.handoff;
      });
    } else {
      setState(() => _phase = _Phase.results);
      if (!_duel) await _save();
    }
  }

  Future<void> _save() async {
    if (_saving || _saved) return;
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await widget.state.record(_results.single);
      if (mounted) setState(() => _saved = true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _saveError = 'Dein Ergebnis konnte nicht gespeichert werden. Bitte erneut versuchen.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _exit() async {
    if (_saving) return;
    final quit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Runde verlassen?'),
        content: const Text('Die laufende Runde wird nicht gespeichert.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Weiterspielen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verlassen'),
          ),
        ],
      ),
    );
    if (quit == true && mounted) {
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop:
        _allowExit ||
        (!_saving &&
            _phase != _Phase.playing &&
            !(_duel && _player == 1 && _phase == _Phase.handoff)),
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _exit();
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          _duel ? 'Duell an einem Gerät' : widget.round.category.label,
        ),
        backgroundColor: AppColors.canvas,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _phase == _Phase.playing
                ? _play()
                : _phase == _Phase.handoff
                ? _handoff()
                : _summary(),
          ),
        ),
      ),
    ),
  );

  Widget _handoff() => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const Icon(
        Icons.swap_horiz_rounded,
        size: 70,
        color: AppColors.darkGreen,
      ),
      const SizedBox(height: 24),
      PageIntro(
        eyebrow: _duel ? 'Lokales Freundschaftsduell' : 'Persönlicher Versuch',
        title: _duel
            ? 'Spieler ${_player + 1}, bist du bereit?'
            : 'Bereit für deine Runde?',
        subtitle: _duel
            ? 'Spielt nacheinander. Die andere Person schaut während der Runde weg.'
            : 'Zehn Aufgaben. Erst zählen richtige Antworten, bei Gleichstand die Antwortzeit.',
      ),
      const SizedBox(height: 24),
      ContentCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_mode.label, style: Theme.of(context).textTheme.titleLarge),
            Text('21 → ${_mode.example}'),
            const SizedBox(height: 12),
            const Text(
              'Die Zeit läuft nur während der Aufgaben, inklusive Anhören und Eingabe. Feedback und Übergabe zählen nicht.',
            ),
            const SizedBox(height: 10),
            const Text(
              'Texthilfe bei Hörfragen oder ein App-Wechsel machen diese Runde zum Training ohne Bestwert.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        key: const Key('begin-challenge'),
        onPressed: _begin,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Jetzt starten'),
      ),
    ],
  );

  Widget _play() {
    final q = _question;
    final tokens = q.category == ChallengeCategory.build
        ? q.tokens(_mode)
        : <String>[];
    return ListView(
      key: ValueKey('$_player/$_index'),
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          '${_duel ? 'Spieler ${_player + 1} · ' : ''}${_mode.label}',
          style: const TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (_index + 1) / widget.round.questions.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 12),
        Text(
          'Aufgabe ${_index + 1} von ${widget.round.questions.length} · ${q.category.label}',
        ),
        const SizedBox(height: 24),
        Text(switch (q.category) {
          ChallengeCategory.listen => 'Welche Zahl hörst du?',
          ChallengeCategory.build => 'Ordne die Bausteine.',
          _ => 'Welches Zahlwort passt?',
        }, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        if (q.category == ChallengeCategory.listen) ...[
          FilledButton.icon(
            key: const Key('challenge-speak'),
            onPressed: _checked || _speechPending ? null : _speak,
            icon: const Icon(Icons.volume_up_rounded),
            label: Text(
              _speechPending ? 'Audio wird gestartet …' : 'Zahl anhören',
            ),
          ),
          TextButton(
            onPressed: _checked
                ? null
                : () => setState(() {
                    _fallback = true;
                    _assisted = true;
                  }),
            child: const Text('Stattdessen lesen (ohne Bestwert)'),
          ),
          if (_fallback)
            Text(
              NumberWords.speakable(q.number, _mode),
              key: const Key('challenge-fallback'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
        ] else
          Center(
            child: Text(
              '${q.number}',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        const SizedBox(height: 20),
        if (q.category == ChallengeCategory.build) ...[
          ContentCard(
            child: Text(
              _selectedTokens.isEmpty
                  ? 'Tippe die Bausteine in der richtigen Reihenfolge an.'
                  : _selectedTokens.map((i) => tokens[i]).join(' · '),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var i = 0; i < tokens.length; i++)
                OutlinedButton(
                  key: Key('token-${tokens[i]}'),
                  onPressed: _checked || _selectedTokens.contains(i)
                      ? null
                      : () => setState(() => _selectedTokens.add(i)),
                  child: Text(tokens[i]),
                ),
            ],
          ),
          TextButton(
            onPressed: _checked || _selectedTokens.isEmpty
                ? null
                : () => setState(_selectedTokens.clear),
            child: const Text('Neu ordnen'),
          ),
          ElevatedButton(
            key: const Key('check-build'),
            onPressed: _checked || _selectedTokens.length != tokens.length
                ? null
                : () => _check(_selectedTokens.map((i) => tokens[i]).join()),
            child: const Text('Prüfen'),
          ),
        ] else
          ...q
              .options(_mode)
              .map(
                (option) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OutlinedButton(
                    key: Key('challenge-answer-$option'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                      alignment: Alignment.centerLeft,
                    ),
                    onPressed:
                        _checked ||
                            _speechPending ||
                            (q.category == ChallengeCategory.listen &&
                                !_heard &&
                                !_fallback)
                        ? null
                        : () => _check(option),
                    child: Text(option, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
        if (_checked) ...[
          const SizedBox(height: 18),
          ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _right
                      ? 'Richtig!'
                      : 'Das war noch nicht die richtige Antwort.',
                  style: TextStyle(
                    color: _right ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${q.number} → ${_mode.word(q.number)}'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            key: const Key('challenge-next'),
            onPressed: _next,
            child: Text(
              _index + 1 == widget.round.questions.length
                  ? 'Runde abschließen'
                  : 'Nächste Aufgabe',
            ),
          ),
        ],
      ],
    );
  }

  Widget _summary() {
    final equal = _duel && _results[0].compareScore(_results[1]) == 0;
    final training = _results.any((r) => !r.eligible);
    final title = !_duel
        ? 'Runde geschafft!'
        : training
        ? 'Trainingsduell beendet'
        : equal
        ? 'Unentschieden!'
        : 'Spieler ${_results[0].compareScore(_results[1]) < 0 ? 1 : 2} gewinnt!';
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(
          Icons.emoji_events_rounded,
          color: AppColors.darkOrange,
          size: 72,
        ),
        const SizedBox(height: 20),
        PageIntro(
          eyebrow: _duel
              ? 'Freundschaftsduell · lokal'
              : 'Nur auf diesem Gerät',
          title: title,
          subtitle: _duel
              ? 'Gleiche Aufgaben, eigene Sprechweise. Dieses Duell zählt nicht für Bestwerte.'
              : training
              ? 'Texthilfe oder App-Unterbrechung: als Training gespeichert, ohne Bestwert.'
              : 'Dein persönlicher Versuch. Keine öffentliche Ranglistenwertung.',
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < _results.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ContentCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_duel ? 'Spieler ${i + 1} · ' : ''}${_results[i].mode.label}',
                  ),
                  Text(
                    '${_results[i].correct} / ${_results[i].total} richtig',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('${_results[i].timeLabel} Antwortzeit'),
                  if (!_results[i].eligible)
                    const Text('Training ohne Bestwert'),
                ],
              ),
            ),
          ),
        if (_saving) const Center(child: CircularProgressIndicator()),
        if (_saved) const Text('Ergebnis auf diesem Gerät gespeichert.'),
        if (_saveError != null) ...[
          Text(_saveError!, style: const TextStyle(color: AppColors.error)),
          TextButton(
            onPressed: _save,
            child: const Text('Speichern erneut versuchen'),
          ),
        ],
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Zurück zur Übersicht'),
        ),
      ],
    );
  }
}
