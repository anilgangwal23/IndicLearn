---
name: new-svg-asset
description: 'Add SVG artwork to IndicLearn, including scenario illustrations, quiz images, and mascots. Use when asked to add an SVG, register an image asset, create a mascot, or check that an image path is bundled. Covers pubspec asset directories, the mascot SVG layer contract, and speaking mascot registration.'
---

# New SVG Asset

Place artwork where the app already loads it, bundle it, and follow the layer
contract for animated mascots.

## Steps

1. **Pick the directory.** Scenario and quiz illustrations go under `assets/svg_assets/`
   (or an existing subfolder such as `rickshaw_scenario/`). Mascots go under
   `assets/mascots/`. Reuse an existing file for the same concept.
2. **Name the file** in lowercase snake_case describing what it depicts. Keep names
   stable once JSON references them.
3. **Bundle it.** Confirm the directory is listed under `flutter: assets:` in
   `pubspec.yaml`. Add the folder explicitly if it is new.
4. **Reference by exact path** in quiz or level JSON. Confirm the file exists first.
5. **Mascots only.** Follow the contract in [lib/ui/README.md](../../../lib/ui/README.md):
   - Use `viewBox="0 0 300 300"`.
   - Make each animatable part a direct child `<g id="...">` of the root, with the
     required IDs listed in that file.
   - Add an optional `mouth` group centered at `(150, 145)`.
   - Keep shared `<defs>` and `<style>` at the root.
6. **Speaking mascots.** To use one during pronunciation audio, add it to
   `speakingMascotAssets` in `lib/ui/mascot_catalog.dart`.

## Validation

- Confirm the file exists at the referenced path and its directory is in `pubspec.yaml`.
- For mascots, confirm every required ID is present as a direct child of the root.
- Confirm the image matches its concept.
- Run `flutter analyze`, comparing against the baseline in [AGENTS.md](../../../AGENTS.md).
- Preview a mascot with `flutter run -d windows` if the change affects animation.
