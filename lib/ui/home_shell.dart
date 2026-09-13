import 'package:flutter/material.dart';

import '../app/app_state.dart';
import '../app/challenge_state.dart';
import 'challenges/challenge_hub.dart';
import 'challenges/challenge_boards.dart';
import '../services/speech_service.dart';
import 'screens/learning_path_screen.dart';
import 'screens/more_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/today_screen.dart';
import 'widgets/common.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.appState,
    required this.speechService,
    required this.challengeState,
  });

  final AppState appState;
  final SpeechService speechService;
  final ChallengeState challengeState;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([widget.appState, widget.challengeState]),
      builder: (BuildContext context, Widget? child) {
        void openPage(Widget page) =>
            Navigator.of(context)
                .push<void>(MaterialPageRoute(builder: (_) => page));
        final List<Widget> pages = <Widget>[
          ChallengeHub(
            state: widget.challengeState,
            speech: widget.speechService,
            onLearn: () => setState(() => _index = 1),
            onBoards: () => setState(() => _index = 2),
          ),
          TodayScreen(
            appState: widget.appState,
            speechService: widget.speechService,
            showLearningPath: () => openPage(
              ListenableBuilder(
                listenable: widget.appState,
                builder: (_, _) => Scaffold(
                  appBar: AppBar(title: const Text('Lernen')),
                  body: LearningPathScreen(
                    appState: widget.appState,
                    speechService: widget.speechService,
                  ),
                ),
              ),
            ),
          ),
          ChallengeBoards(
            state: widget.challengeState,
            speech: widget.speechService,
          ),
          ChallengeProfile(
            state: widget.challengeState,
            onLearningProgress: () => openPage(
              ListenableBuilder(
                listenable: widget.appState,
                builder: (_, _) => Scaffold(
                  appBar: AppBar(title: const Text('Lernfortschritt')),
                  body: ProgressScreen(appState: widget.appState),
                ),
              ),
            ),
          ),
          MoreScreen(appState: widget.appState),
        ];
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 900;
            final Widget content = SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: IndexedStack(index: _index, children: pages),
                ),
              ),
            );

            if (wide) {
              return Scaffold(
                body: Row(
                  children: <Widget>[
                    SafeArea(
                      child: NavigationRail(
                        extended: constraints.maxWidth >= 1180,
                        selectedIndex: _index,
                        onDestinationSelected: (int value) {
                          setState(() => _index = value);
                        },
                        leading: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: BrandLogo(),
                        ),
                        destinations: _railDestinations,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                ),
              );
            }

            return Scaffold(
              body: content,
              bottomNavigationBar: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (int value) {
                  setState(() => _index = value);
                },
                destinations: _barDestinations,
              ),
            );
          },
        );
      },
    );
  }
}

const List<NavigationRailDestination> _railDestinations =
    <NavigationRailDestination>[
      NavigationRailDestination(
        icon: Icon(Icons.bolt_outlined),
        selectedIcon: Icon(Icons.bolt_rounded),
        label: Text('Challenges'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.route_outlined),
        selectedIcon: Icon(Icons.route_rounded),
        label: Text('Lernen'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.leaderboard_outlined),
        selectedIcon: Icon(Icons.leaderboard_rounded),
        label: Text('Ranglisten'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.person_outline_rounded),
        selectedIcon: Icon(Icons.person_rounded),
        label: Text('Profil'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.more_horiz),
        selectedIcon: Icon(Icons.more_horiz_rounded),
        label: Text('Mehr'),
      ),
    ];

const List<NavigationDestination> _barDestinations = <NavigationDestination>[
  NavigationDestination(icon: Icon(Icons.bolt_outlined), label: 'Challenges'),
  NavigationDestination(icon: Icon(Icons.route_outlined), label: 'Lernen'),
  NavigationDestination(
    icon: Icon(Icons.leaderboard_outlined),
    label: 'Ranglisten',
  ),
  NavigationDestination(
    icon: Icon(Icons.person_outline_rounded),
    label: 'Profil',
  ),
  NavigationDestination(icon: Icon(Icons.more_horiz), label: 'Mehr'),
];
