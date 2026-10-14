import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.35,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

class ContentCard extends StatelessWidget {
  const ContentCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(22),
        child: child,
      ),
    );
  }
}

class EnergyBadge extends StatelessWidget {
  const EnergyBadge({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$value Klarheitsenergie',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.bolt_rounded, color: AppColors.green, size: 20),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberMascot extends StatelessWidget {
  const NumberMascot({super.key, this.size = 112});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Fröhliche Zahl 21 auf direkter Route',
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.surfaceGreen,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              '21',
              style: TextStyle(
                color: AppColors.darkGreen,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w900,
              ),
            ),
            Positioned(
              bottom: size * 0.18,
              child: Container(
                width: size * 0.26,
                height: size * 0.08,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyProgress extends StatelessWidget {
  const EmptyProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContentCard(
      child: Row(
        children: <Widget>[
          Icon(Icons.route_rounded, color: AppColors.green, size: 34),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Deine Reise beginnt mit der ersten kurzen Lektion.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 44});
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(size * .24),
    child: Image.asset(
      'assets/brand/zwanzigeins.png',
      width: size,
      height: size,
      semanticLabel: 'Zwanzigeins',
    ),
  );
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, this.trailing});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      const BrandLogo(size: 42),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('zwanzigeins', style: Theme.of(context).textTheme.titleLarge),
            const Text(
              'ENTWIRR DIE ZAHLEN',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.35,
              ),
            ),
          ],
        ),
      ),
      ?trailing,
    ],
  );
}

class MetricPill extends StatelessWidget {
  const MetricPill({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.inverted = false,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final foreground = inverted ? Colors.white : AppColors.ink;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: inverted ? Colors.white.withValues(alpha: .1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: inverted
              ? Colors.white.withValues(alpha: .16)
              : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 19,
            color: inverted ? AppColors.green : AppColors.darkGreen,
          ),
          const SizedBox(width: 7),
          Text(
            value,
            style: TextStyle(color: foreground, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: inverted ? Colors.white70 : AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
