import 'package:flutter_tts/flutter_tts.dart';

abstract interface class SpeechService {
  Future<bool> speak(String text);
  Future<void> stop();
}

class FlutterSpeechService implements SpeechService {
  FlutterSpeechService({FlutterTts? engine}) : _engine = engine ?? FlutterTts();

  final FlutterTts _engine;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    await _engine.setLanguage('de-DE');
    await _engine.setSpeechRate(0.42);
    await _engine.setVolume(1);
    _initialized = true;
  }

  @override
  Future<bool> speak(String text) async {
    try {
      await _initialize();
      await _engine.stop();
      final dynamic result = await _engine.speak(text);
      return result == 1 || result == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _engine.stop();
    } catch (_) {
      // Some desktop targets have no TTS implementation. Stopping is optional.
    }
  }
}
