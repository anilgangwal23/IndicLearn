# Level Selection

`LevelLoader` loads [assets/scenarios/catalog.json](../../assets/scenarios/catalog.json),
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
and level screen. See [lib/ui/README.md](../../lib/ui/README.md) for the SVG layer
contract and shared jump, yawn, and blink animations.

Games inside `LevelPage` use `embeddedInLevel: true` to suppress their app bar's
automatic back button; the level header owns navigation. Standalone games keep
their automatic back button by default. Pass the same flag to `GameScaffold`
when adding a new embedded game.

The level completion layout lives in [WinScreen](../../lib/levels/winscreen.dart).
`LevelPage` supplies the score and mascot asset and handles the replay callback,
keeping attempt state separate from the completion UI.
Continue returns `true` to the loader to open the next level in the scenario.
Back returns to the scenario ladder without opening another level; Continue on
the final level also returns to the ladder.
