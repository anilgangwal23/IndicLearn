import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../ui/game_widgets.dart';

class GameIntro {
  const GameIntro({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}

GameIntro? gameIntroFor(String handler, AppLocalizations l10n) {
  switch (handler) {
    case 'GamePage':
      return GameIntro(
        title: l10n.introQuizTitle,
        body: l10n.introQuizBody,
        icon: Icons.quiz,
      );
    case 'WordMatchPage':
      return GameIntro(
        title: l10n.introMatchTitle,
        body: l10n.introMatchBody,
        icon: Icons.compare_arrows,
      );
    case 'MTSPage':
      return GameIntro(
        title: l10n.introSentenceTitle,
        body: l10n.introSentenceBody,
        icon: Icons.reorder,
      );
    case 'FollowTheSound':
      return GameIntro(
        title: l10n.introSoundTitle,
        body: l10n.introSoundBody,
        icon: Icons.volume_up,
      );
    case 'MemoryFlipPage':
      return GameIntro(
        title: l10n.introMemoryTitle,
        body: l10n.introMemoryBody,
        icon: Icons.flip,
      );
    case 'FillBlankPage':
      return GameIntro(
        title: l10n.introFillTitle,
        body: l10n.introFillBody,
        icon: Icons.edit_note,
      );
    case 'SpeedRoundPage':
      return GameIntro(
        title: l10n.introSpeedTitle,
        body: l10n.introSpeedBody,
        icon: Icons.bolt,
      );
    default:
      return null;
  }
}

/// Remembers which game types the user has already been introduced to.
class GameIntroStore {
  static const _key = 'seen_game_intros';

  static Future<Set<String>> loadSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const <String>[]).toSet();
  }

  static Future<void> markSeen(String handler) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = (prefs.getStringList(_key) ?? const <String>[]).toSet()
      ..add(handler);
    await prefs.setStringList(_key, seen.toList());
  }
}

class GameIntroView extends StatelessWidget {
  const GameIntroView({super.key, required this.intro, required this.onStart});

  final GameIntro intro;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(intro.icon, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              intro.title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              intro.body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            GameButton(
              icon: Icons.play_arrow,
              label: l10n.introStart,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}
