---
name: new-game
description: 'Add a new IndicLearn game or game step type. Use when asked to create a game, add a new level step handler, or wire a game into LevelPage. Covers GameScaffold, embeddedInLevel, buildGameTheme, the level factory handler switch, and l10n for user-facing text.'
---

# New Game

Add a game that plugs into the existing level flow. Reuse the shared theme and
scaffold; do not build a parallel navigation or styling system.

## Steps

1. **Pick the closest existing game** under `lib/games/` (for example
   `quiz_ui/`, `match_the_pair/`, `make_the_sentence/`, `follow_the_sound/`) and
   copy its structure, not its styling.
2. **Use the shared scaffold.** Build the screen on `GameScaffold`
   (`lib/ui/game_widgets.dart`). Accept an `embeddedInLevel` parameter (default
   `false`) and pass it to `GameScaffold`, so the level header owns navigation when
   the game runs inside `LevelPage`.
3. **Theme through roles.** Use `Theme.of(context).colorScheme` and `textTheme`. Do not
   hard-code colors. See [docs/architecture/theme.md](../../../docs/architecture/theme.md).
4. **Localize all user-facing text.** Add keys to `lib/l10n/app_en.arb` and
   `app_hi.arb`, then read them through `AppLocalizations`. The
   `no_hardcoded_ui_string` lint enforces this.
5. **Register the handler** in `lib/levels/level_factory.dart`. Add a `case` in
   `getHandler` that passes the game's required parameters, including `embeddedInLevel`.
6. **Add the step type.** Confirm how `lib/levels/level_model.dart` parses step
   `type` and `handler` before writing level JSON.
7. **Report completion** through the `onComplete` callback the factory passes in.

## Validation

- `dart run custom_lint` must pass with no new `no_hardcoded_ui_string` findings.
- `flutter analyze` must not add new issues beyond the baseline in
  [AGENTS.md](../../../AGENTS.md).
- Run a related test file if one exists. The full `flutter test` suite passes, so any failure is a regression.
- Check the flow manually with `flutter run -d windows`: the game should open from a
  level, and its back behavior should match `embeddedInLevel`.

Do not add a new test file just to validate a game unless the user asks for one.
