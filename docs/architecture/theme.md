# Theme

The app and game previews share `buildGameTheme()` in
[lib/ui/game_theme.dart](../../lib/ui/game_theme.dart). This is the single source of
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
