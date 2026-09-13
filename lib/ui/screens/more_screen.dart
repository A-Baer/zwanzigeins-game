import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_state.dart';
import '../../app/app_theme.dart';
import '../widgets/common.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.appState});

  static final Uri _membershipUri = Uri.parse(
    'https://zwanzigeins.jetzt/verein/mitgliedschaft?analytics=off',
  );
  static final Uri _chronicleUri = Uri.parse(
    'https://zwanzigeins.jetzt/infos/chronik?analytics=off',
  );
  static final Uri _websiteUri = Uri.parse(
    'https://zwanzigeins.jetzt/?analytics=off',
  );
  static final Uri _studiesUri = Uri.parse(
    'https://zwanzigeins.jetzt/aktivitaeten/projekte/unterrichtsversuche?analytics=off',
  );

  final AppState appState;

  Future<void> _open(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Der Link konnte nicht geöffnet werden.')),
      );
    }
  }

  Future<void> _reset(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Fortschritt zurücksetzen?'),
        content: const Text(
          'Alle gemeisterten Stationen, Antworten und Klarheitsenergie werden auf diesem Gerät gelöscht.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
    if (confirmed == true) await appState.reset();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const PageIntro(
            eyebrow: 'Entdecken und mitmachen',
            title: 'Mehr über Zwanzigeins',
            subtitle: 'Die direkte Sprechweise ergänzt die vertraute Form. Hier findest du Geschichte, Forschung und den Verein.',
          ),
          const SizedBox(height: 28),
          _HistoryCard(onOpenChronicle: () => _open(context, _chronicleUri)),
          const SizedBox(height: 16),
          _LinkCard(
            icon: Icons.science_rounded,
            title: 'Was wurde untersucht?',
            subtitle: 'Ergebnisse und Hintergründe zu den Unterrichtsversuchen mit der Zwanzigeins-App.',
            actionLabel: 'Studien ansehen',
            color: AppColors.violet,
            onTap: () => _open(context, _studiesUri),
          ),
          const SizedBox(height: 16),
          _LinkCard(
            icon: Icons.assignment_turned_in_rounded,
            title: 'Aufnahmeantrag für den Verein',
            subtitle: 'Auf der Mitgliedschaftsseite findest du immer das aktuelle PDF-Formular. Die App übermittelt selbst keine persönlichen Daten.',
            actionLabel: 'Mitgliedschaft & Antrag öffnen',
            color: AppColors.green,
            onTap: () => _open(context, _membershipUri),
          ),
          const SizedBox(height: 16),
          _LinkCard(
            icon: Icons.language_rounded,
            title: 'Zwanzigeins im Web',
            subtitle: 'Aktuelles, Positionen, Arbeitsgruppen und Materialien.',
            actionLabel: 'Website öffnen',
            color: AppColors.orange,
            onTap: () => _open(context, _websiteUri),
          ),
          const SizedBox(height: 26),
          Text(
            'Einstellungen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          ContentCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              title: const Text('Lokalen Fortschritt löschen'),
              subtitle: const Text(
                'Entfernt alle Spieldaten von diesem Gerät.',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _reset(context),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Diese MVP-Version benötigt kein Konto und speichert den Lernfortschritt nur lokal auf dem Gerät.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.onOpenChronicle});

  final VoidCallback onOpenChronicle;

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.museum_rounded,
                color: AppColors.darkGreen,
                size: 30,
              ),
              const SizedBox(width: 12),
              Text(
                'Das kleine Zahlenmuseum',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _HistoryItem(
            year: 'vor unserer Ziffernschrift',
            text: 'Die traditionelle Sprechreihenfolge ist älter als das heute verwendete Stellenwertsystem.',
          ),
          const _HistoryItem(
            year: 'um 1520',
            text: 'Jakob Köbel zeigte bereits Formen wie „zwanzigeins“ und „zwanzigzwei“.',
          ),
          const _HistoryItem(
            year: '2004',
            text: 'Der Verein Zwanzigeins wurde gegründet, um die stellenwertgerechte Alternative bekannt zu machen.',
            last: true,
          ),
          const Divider(height: 30),
          Text(
            'Warum sprechen wir „verdreht“?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          const Text(
            'Die Einer-vor-Zehner-Form ist kein absichtlich verdreht entworfenes System. Sie ist ein sprachgeschichtliches Erbe aus einer Zeit, in der unsere heutigen indo-arabischen Stellenwertzahlen noch nicht allgemein verwendet wurden.',
          ),
          const SizedBox(height: 10),
          const Text(
            'Als sich die von links nach rechts gelesene Ziffernschrift verbreitete, blieben vertraute Zahlwörter wie „ein und zwanzig“ erhalten. Deshalb laufen Sprech- und Schriftreihenfolge bei vielen Zahlen von 21 bis 99 heute gegeneinander. Zur genauen Entstehung gibt es mehrere sprachgeschichtliche Erklärungen – es war keine einzelne bewusste Entscheidung.',
          ),
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: onOpenChronicle,
            icon: const Icon(Icons.history_edu_rounded),
            label: const Text('Chronik und Quellen öffnen'),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.year,
    required this.text,
    this.last = false,
  });

  final String year;
  final String text;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
            ),
            if (!last)
              Container(width: 2, height: 58, color: const Color(0xFFDDF5EC)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  year,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final Color color;
  final VoidCallback onTap;

  Color get _accessibleColor {
    if (color == AppColors.green) return AppColors.darkGreen;
    if (color == AppColors.orange) return AppColors.darkOrange;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: _accessibleColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 5),
                    Text(subtitle),
                    const SizedBox(height: 12),
                    Text(
                      actionLabel.toUpperCase(),
                      style: TextStyle(
                        color: _accessibleColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, color: _accessibleColor),
            ],
          ),
        ),
      ),
    );
  }
}
