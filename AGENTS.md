# IndicLearn Agent Guide

Flutter app for learning Indian languages through scenario-based lessons. Windows
is the primary dev target; Android, iOS, and macOS folders also exist.

## Directory map

- `lib/`: app code. `levels/` (level pages, factory, WinScreen), `level_loader/`
  (scenario catalog), `games/` (quiz, match, sentence, sound games), `ui/`
  (theme, shared widgets, SVG mascots), `l10n/` (ARB strings), `progress/`, `account/`.
- `test/`: widget and unit tests.
- `assets/`: scenarios, levels, quizzes, SVGs, audio, mascots. Each folder must be
  listed in `pubspec.yaml` under `flutter: assets:`.
- `content/`: authoring sources, such as `content/scenario_groups/*/plan.md`.
- `tools/hardcoded_string_lint/`: custom lint package for UI string literals.
- `docs/`: product docs. `docs/architecture/` covers theme, level selection, accounts.

## Commands

Verified on Flutter 3.47.8 (Windows):

- `flutter pub get`: install dependencies. Passes.
- `dart run custom_lint`: runs the `no_hardcoded_ui_string` rule. Passes.
- `flutter analyze`: currently reports 13 existing issues. Do not add new issues.
- `flutter test`: passes (60 tests). Narrow to a file with `flutter test test/<file>.dart`.
  Level-flow quiz tests were removed from `test/widget_test.dart` because the quiz audio
  stack (`flutter_tts`, `just_audio`) cannot run under widget tests without a fake platform.
- `flutter run -d windows`: run the app (not run by the verification pass).

Before finishing, run `flutter analyze` and `dart run custom_lint`, and any test files
related to your change. Report any new failures.

## Conventions

- **User-facing text:** add strings to `lib/l10n/app_en.arb` and `app_hi.arb` and read
  them through `AppLocalizations`. The `no_hardcoded_ui_string` lint flags literals
  passed to `Text`, `labelText`, `tooltip`, `message`, and similar parameters.
- **Theme:** use `Theme.of(context).colorScheme` and `textTheme` roles. Do not hard-code
  colors or override shared borders per page. The central theme is `buildGameTheme()`
  in `lib/ui/game_theme.dart`. Details: [docs/architecture/theme.md](docs/architecture/theme.md).
- **Games inside a level:** pass `embeddedInLevel: true` so the level header owns
  navigation. Add the same flag to any new `GameScaffold` (`lib/ui/game_widgets.dart`).
- **IDs are stable:** scenario and level IDs in JSON are referenced by saved progress.
  Never rename or renumber them.
- **Level and scenario data:** see [docs/architecture/level-selection.md](docs/architecture/level-selection.md).
- **Assets:** new asset directories must be added to `pubspec.yaml`. Mascot layer
  contract: [lib/ui/README.md](lib/ui/README.md).
- **Accounts:** Firebase setup in [docs/accounts.md](docs/accounts.md).

## Skills

Project skills live in `.agents/skills/`:

- `scenario-group-creation`: build a scenario lesson group.
- `new-game`: add a game or step handler.
- `new-level`: add scenarios and levels to the catalog.
- `new-svg-asset`: add SVG artwork and mascots.

## Repository preferences

- Do not use `rg`, `ripgrep`, or tools that invoke ripgrep, including package
  ripgrep searches. Use `grep`, `find`, file-search tools, or structured parsers
  instead. This is a persistent user preference for future sessions.