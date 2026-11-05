---
name: new-level
description: 'Add scenarios or levels to the IndicLearn level catalog. Use when asked to add a level, add a scenario, register a new lesson in the level picker, or change unlock flags. Covers catalog.json, scenario and level JSON, stable IDs, and pubspec asset registration.'
---

# New Level

Add lessons to the level picker by editing the catalog and scenario JSON. Do not
hard-code levels in widgets. Full behavior:
[docs/architecture/level-selection.md](../../../docs/architecture/level-selection.md).

## Steps

1. **Read the catalog** at `assets/scenarios/catalog.json`. It holds `schemaVersion` and
   a `scenarios` list of scenario file paths only.
2. **Add a scenario** by creating `assets/scenarios/<name>.json` with `id`, `title`,
   `unlocked`, and `levels`, copying `everyday_practice.json` as the template. Then
   append its path to the catalog's `scenarios` list.
3. **Add a level** by appending `{id, title, assetPath, unlocked}` to the scenario's
   `levels` array.
4. **Set the level's step data** using the step `type` and `handler` pairs documented in
   `.agents/skills/scenario-group-creation/references/indic-learn-formats.md`.
5. **Register asset directories** in `pubspec.yaml` under `flutter: assets:` if you add
   a new folder. Files in an already-listed folder need no change.
6. **Keep IDs stable.** Saved progress references scenario and level IDs. Never rename
   or renumber an existing ID. Add new entries at the end.
7. **Unlock flags.** Change `unlocked` only when the user asks. Do not unlock content
   as a side effect.

## Validation

- Confirm the JSON parses, every referenced asset path exists, and every new directory
  is listed in `pubspec.yaml`.
- Confirm scenario and level IDs are unique and existing IDs are unchanged.
- Run `dart run custom_lint` and `flutter analyze`, comparing against the baseline in
  [AGENTS.md](../../../AGENTS.md).
- `test/scenario_catalog_test.dart` covers catalog parsing and passes. Run it after catalog
  changes. Do not add tests just to validate data.
