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

## Localised titles and learning pair

Scenario and level `title` values are language maps (for example `{"en": "...", "hi": "..."}`).
`ScenarioDefinition.titleFor` and `LevelDefinition.titleFor` resolve the title for the
app UI locale, falling back to `en`. A plain string title is treated as English.

The learning pair is independent of the UI locale. `LanguagePair` (`lib/language/language_pair.dart`)
holds a `source` (prompt language) and `target` (answer language), both from
`supportedLanguageCodes`. `LanguagePairController` persists the choice in SharedPreferences.
The picker (`LanguagePairMenuButton`) sits in the level loader app bar.

Quiz and game choices are read with `resolveLanguage`, which falls back to `en` and then
to any entry, so a missing language key does not crash.

Progress is scoped per pair. The document ID is `<source>-<target>~<scenarioId>`
(see `scopedProgressId`). Unprefixed legacy IDs count toward `en-hi`, the default pair.

Game content uses the same six-key language maps. Each text leaf is `{"en","hi","kn","mr","pa","te"}`.
Readers (`localizedJson`, and `resolveLanguage`) pick the value for a pair role:

- Prompt side (`source`): speed_round prompt, match_the_pair `left_word`, memory_flip `word`, make_the_sentence `source`.
- Answer and learning side (`target`): speed_round answers and distractors, fill_blank sentence, answer and distractors, match_the_pair `right_definition`, memory_flip `translation`, make_the_sentence `translation`, `words`, and `index`.

Plain strings still pass through unchanged. `test/language_pair_test.dart` checks that every
bundled map has all six keys.

Audio: `assets/audio/mapping.json` only has clips for `en` and `hi`. kn, mr, pa, and te
fall back to runtime `flutter_tts`. Generating clips for those languages is deferred.

