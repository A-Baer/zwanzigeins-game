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
  String? _answer;
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
      _answer = answer;
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
        _answer = null;
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
        _answer = null;
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
        leading: IconButton(
          tooltip: 'Runde schließen',
          onPressed: _saving
              ? null
              : () {
                  if (_phase == _Phase.playing ||
                      (_duel && _player == 1 && _phase == _Phase.handoff)) {
                    _exit();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
          icon: const Icon(Icons.close_rounded),
        ),
        title: _phase == _Phase.playing
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: (_index + 1) / widget.round.questions.length,
                  minHeight: 10,
                ),
              )
            : Text(
                _duel ? 'Duell an einem Gerät' : widget.round.category.label,
              ),
        actions: _phase == _Phase.playing
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Center(
                    child: Text(
                      '${_index + 1}/${widget.round.questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ]
            : null,
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
    padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
    children: [
      Center(
        child: Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _duel ? Icons.swap_horiz_rounded : Icons.arrow_forward_rounded,
            size: 46,
            color: AppColors.green,
          ),
        ),
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
            const Text(
              'DEINE SPRECHWEISE',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(_mode.label, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '21  →  ${_mode.example}',
              style: const TextStyle(fontSize: 18),
            ),
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
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_duel ? 'Spieler ${_player + 1} · ' : ''}${_mode.label}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              q.category.label,
              maxLines: 1,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(switch (q.category) {
          ChallengeCategory.listen => 'Welche Zahl hörst du?',
          ChallengeCategory.build => 'Bringe die Zahl in Leserichtung.',
          ChallengeCategory.addition => 'Wie viel ist das?',
          ChallengeCategory.match => 'Welches Zahlwort passt?',
          ChallengeCategory.mixed => 'Welche Antwort passt?',
        }, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(switch (q.category) {
          ChallengeCategory.listen => 'Höre genau hin und wähle die Ziffern.',
          ChallengeCategory.build => 'Tippe die Bausteine nacheinander an.',
          ChallengeCategory.addition => 'Addiere beide Zahlen im Kopf.',
          _ => 'Wähle eine Antwort aus.',
        }, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 28),
        if (q.category == ChallengeCategory.listen) ...[
          Center(
            child: SizedBox(
              width: 132,
              height: 132,
              child: FilledButton(
                key: const Key('challenge-speak'),
                onPressed: _checked || _speechPending ? null : _speak,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  backgroundColor: _speechPending
                      ? AppColors.darkGreen
                      : AppColors.ink,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _speechPending
                          ? Icons.graphic_eq_rounded
                          : _heard
                          ? Icons.replay_rounded
                          : Icons.volume_up_rounded,
                      color: AppColors.green,
                      size: 42,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _speechPending
                          ? 'Läuft …'
                          : _heard
                          ? 'Nochmal'
                          : 'Anhören',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
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
            Center(
              child: Container(
                key: const Key('challenge-fallback'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  NumberWords.speakable(q.number, _mode),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
        ] else
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 22),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Text(
                q.category == ChallengeCategory.addition
                    ? q.additionExpression
                    : '${q.number}',
                key: q.category == ChallengeCategory.addition
                    ? const Key('addition-expression')
                    : null,
                style: TextStyle(
                  fontSize: q.category == ChallengeCategory.addition ? 46 : 68,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        if (q.category == ChallengeCategory.build) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green),
            ),
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
          ...q.options(_mode).map((option) {
            final correct = option == q.answer(_mode);
            final selected = option == _answer;
            final background = !_checked
                ? Colors.white
                : correct
                ? AppColors.surfaceGreen
                : selected
                ? const Color(0xFFFFECEC)
                : Colors.white;
            final border = !_checked
                ? AppColors.border
                : correct
                ? AppColors.success
                : selected
                ? AppColors.error
                : AppColors.border;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                key: Key('challenge-answer-$option'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                  alignment: Alignment.centerLeft,
                  backgroundColor: background,
                  disabledBackgroundColor: background,
                  disabledForegroundColor: AppColors.ink,
                  side: BorderSide(
                    color: border,
                    width: selected || correct ? 2 : 1.4,
                  ),
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
            );
          }),
        if (_checked) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _right ? AppColors.surfaceGreen : const Color(0xFFFFECEC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _right ? AppColors.success : AppColors.error,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _right
                      ? 'Richtig – genau so!'
                      : q.category == ChallengeCategory.addition
                      ? 'Fast. Rechne beide Zahlen noch einmal zusammen.'
                      : 'Fast. Schau dir die Richtung noch einmal an.',
                  style: TextStyle(
                    color: _right ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  q.category == ChallengeCategory.addition
                      ? '${q.additionExpression} = ${q.number}'
                      : '${q.number} → ${_mode.word(q.number)}',
                ),
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
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
      children: [
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: AppColors.ink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.green,
              size: 52,
            ),
          ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_duel ? 'Spieler ${i + 1} · ' : ''}${_results[i].mode.label}',
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_results[i].correct} / ${_results[i].total} richtig',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      MetricPill(
                        icon: Icons.timer_outlined,
                        value: _results[i].timeLabel,
                        label: 'Antwortzeit',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: _results[i].correct / _results[i].total,
                    ),
                  ),
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
