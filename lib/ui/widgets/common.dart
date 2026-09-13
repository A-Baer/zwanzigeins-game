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
            letterSpacing: 1.2,
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
          color: const Color(0xFFFFF2DB),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.bolt_rounded, color: AppColors.orange, size: 20),
            const SizedBox(width: 4),
            Text(
              '$value',
              style: const TextStyle(
                color: AppColors.ink,
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
          color: Color(0xFFDDF5EC),
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
