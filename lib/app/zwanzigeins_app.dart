import 'package:flutter/material.dart';

import '../data/progress_store.dart';
import '../data/challenge_store.dart';
import 'challenge_state.dart';
import '../services/speech_service.dart';
import '../ui/home_shell.dart';
import 'app_state.dart';
import 'app_theme.dart';

class ZwanzigeinsApp extends StatefulWidget {
  const ZwanzigeinsApp({
    super.key,
    this.progressStore,
    this.speechService,
    this.challengeStore,
  });

  final ProgressStore? progressStore;
  final ChallengeStore? challengeStore;
  final SpeechService? speechService;

  @override
  State<ZwanzigeinsApp> createState() => _ZwanzigeinsAppState();
}

class _ZwanzigeinsAppState extends State<ZwanzigeinsApp> {
  late final SpeechService _speechService;
  late final Future<(AppState, ChallengeState)> _state;

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? FlutterSpeechService();
    _state = _load();
  }

  Future<(AppState, ChallengeState)> _load() async {
    final learning = await AppState.load(
      widget.progressStore ?? SharedPreferencesProgressStore(),
    );
    final challenges = await ChallengeState.load(
      widget.challengeStore ?? PreferencesChallengeStore(),
    );
    return (learning, challenges);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zwanzigeins',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<(AppState, ChallengeState)>(
        future: _state,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<(AppState, ChallengeState)> snapshot,
            ) {
              if (snapshot.hasError) {
                return const _StartupError();
              }
              if (!snapshot.hasData) {
                return const _LoadingScreen();
              }
              return HomeShell(
                appState: snapshot.requireData.$1,
                challengeState: snapshot.requireData.$2,
                speechService: _speechService,
              );
            },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _StartupError extends StatelessWidget {
  const _StartupError();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Der lokale Spielstand konnte nicht geladen werden. Bitte starte die App neu.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
