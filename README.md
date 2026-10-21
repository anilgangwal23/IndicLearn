# indic_learn

A new Flutter project.

## Theme

The app and game previews share `buildGameTheme()` in
[lib/ui/game_theme.dart](lib/ui/game_theme.dart). This is the single source of
truth for the light palette, typography, and component styles. Like Spectrum's
semantic tokens, screens reference roles rather than individual hex colors:

| Role | Flutter token |
| --- | --- |
| Page background | `colorScheme.surface` |
| Input and answer background | `colorScheme.surfaceContainerLowest` |
| Subtle/disabled surface | `colorScheme.surfaceContainerLow` |
| Primary text | `colorScheme.onSurface` |
| Supporting text and icons | `colorScheme.onSurfaceVariant` |
| Primary action | `colorScheme.primary` / `onPrimary` |
| Selected background/text | `colorScheme.primaryContainer` / `onPrimaryContainer` |
| Secondary accent | `colorScheme.secondary` / `onSecondary` |
| Borders and separators | `colorScheme.outline` / `outlineVariant` |
| Error text and feedback | `colorScheme.error`, `errorContainer` / `onErrorContainer` |
| Correct-answer feedback | `theme.extension<GameFeedbackColors>()` |

Use `Theme.of(context).colorScheme` and `Theme.of(context).textTheme` for custom
widgets. Standard `AppBar`, `FilledButton`, `ElevatedButton`, `OutlinedButton`,
`TextButton`, and `TextField`/`TextFormField` inherit their styles automatically.
Inputs include enabled, focused, disabled, error, and focused-error borders;
buttons inherit Material hover, focus, press, and disabled behavior. Keep local
decorations to content such as labels and icons; avoid overriding shared colors
or borders on individual pages. Change the central theme to restyle the app.

## Accounts

Firebase Auth provides email/password, phone/SMS, Google, and Apple sign-in;
Firestore stores user-owned profiles. See [account setup](docs/accounts.md)
for provider configuration, platform support, data format, and security rules.
Live authentication requires configuring your Firebase project first.

## Level Selection

`LevelLoader` loads [assets/scenarios/catalog.json](assets/scenarios/catalog.json),
an ordered list of scenario JSON asset paths with `schemaVersion: 1`. Each scenario
contains `id`, `title`, `unlocked`, and a `levels` array. Each level contains a stable
`id`, `title`, `assetPath`, and `unlocked` flag. Levels are parsed in a loop rather
than declared in the widget constructor.

To add a scenario, create its JSON file in `assets/scenarios/` and add its path to
the catalog. To add a level, append its metadata to the scenario's `levels` array
(1-12 levels per scenario). Keep scenario and level IDs stable: saved progress
references these IDs, not titles or asset filenames.

The bundled catalog contains everyday practice (10 levels) and the Hindi-to-English
auto-rickshaw scenario (12 levels). The existing path and jump animations are
unchanged. Selecting an unlocked scenario opens its first incomplete level; a
finished scenario replays its final level.

`LevelLoader(scenarios: ...)` still accepts injected `ScenarioDefinition` values
for tests and custom catalogs, bypassing asset loading. `catalogAsset` selects an
alternative bundled catalog. Missing or malformed catalog data shows a Retry
state rather than an empty or partially loaded scenario list.

Set `mascotAsset` on `LevelLoader` to use another character throughout the path
and level screen. See `lib/widgets/README.md` for the SVG layer contract and
shared jump, yawn, and blink animations.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
