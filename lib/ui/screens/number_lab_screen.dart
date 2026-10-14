import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../domain/number_words.dart';
import '../../services/speech_service.dart';
import '../widgets/common.dart';

class NumberLabScreen extends StatefulWidget {
  const NumberLabScreen({super.key, required this.speechService});
  final SpeechService speechService;

  @override
  State<NumberLabScreen> createState() => _NumberLabScreenState();
}

class _NumberLabScreenState extends State<NumberLabScreen> {
  int _number = 21;
  bool _speaking = false;

  @override
  void dispose() {
    widget.speechService.stop();
    super.dispose();
  }

  Future<void> _speak(SpeechMode mode) async {
    setState(() => _speaking = true);
    try {
      final worked = await widget.speechService.speak(
        NumberWords.speakable(_number, mode),
      );
      if (!worked && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sprachausgabe nicht verfügbar. Du kannst beide Formen hier lesen.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _speaking = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Zahlenlabor'),
      backgroundColor: AppColors.canvas,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const PageIntro(
                eyebrow: 'Entdecken ohne Punkte',
                title: 'Eine Zahl. Zwei Wege.',
                subtitle: 'Verändere Zehner und Einer und vergleiche, wie deine Zahl klingt.',
              ),
              const SizedBox(height: 26),
              ContentCard(
                child: Column(
                  children: [
                    Text(
                      '$_number',
                      key: const Key('lab-number'),
                      style: const TextStyle(
                        fontSize: 80,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    Text('${_number ~/ 10} Zehner + ${_number % 10} Einer'),
                    const SizedBox(height: 22),
                    _control(
                      'Zehner',
                      _number ~/ 10,
                      1,
                      9,
                      (v) => _number = v * 10 + _number % 10,
                    ),
                    const SizedBox(height: 12),
                    _control(
                      'Einer',
                      _number % 10,
                      0,
                      9,
                      (v) => _number = (_number ~/ 10) * 10 + v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _speechCard(
                'STELLENWERTGERECHT',
                NumberWords.placeValue(_number),
                SpeechMode.placeValue,
                const Color(0xFFE7F8EE),
              ),
              const SizedBox(height: 12),
              _speechCard(
                'TRADITIONELL',
                NumberWords.traditional(_number),
                SpeechMode.traditional,
                const Color(0xFFE7F8EE),
              ),
              const SizedBox(height: 20),
              Text(
                _number % 10 == 0
                    ? 'Bei vollen Zehnern stimmen beide Sprechweisen überein.'
                    : 'Die stellenwertgerechte Form nennt zuerst den Zehner und dann den Einer. '
                          'Die traditionelle Form ist die heute übliche deutsche Sprechweise.',
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _control(
    String label,
    int value,
    int min,
    int max,
    void Function(int) change,
  ) => Row(
    children: [
      Expanded(
        child: Text(label, style: Theme.of(context).textTheme.titleMedium),
      ),
      IconButton.filledTonal(
        tooltip: '$label verringern',
        onPressed: value > min ? () => setState(() => change(value - 1)) : null,
        icon: const Icon(Icons.remove_rounded),
      ),
      SizedBox(
        width: 42,
        child: Text(
          '$value',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      IconButton.filledTonal(
        tooltip: '$label erhöhen',
        onPressed: value < max ? () => setState(() => change(value + 1)) : null,
        icon: const Icon(Icons.add_rounded),
      ),
    ],
  );

  Widget _speechCard(String label, String word, SpeechMode mode, Color color) =>
      Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.1,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(word, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _speaking ? null : () => _speak(mode),
                icon: const Icon(Icons.volume_up_rounded),
                label: const Text('Anhören'),
              ),
            ],
          ),
        ),
      );
}
