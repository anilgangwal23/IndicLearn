# SVG Mascot starter

## Files
- `lib/ui/svg_mascot.dart`: reusable Flutter widget. Re-exports the motion API from `lib/animations/mascot_motions.dart`.
- `lib/animations/mascot_motions.dart`: `MascotAnimation` enum and per-motion pose calculation.
- `lib/ui/svg_mascot_parser.dart`: extracts named top-level SVG groups into renderable layers.
- `assets/mascots/fox.svg`: sample mascot asset.
- `assets/mascots/sprout.svg`: default learning-path character with an animated mouth.
- `assets/mascots/parrot.svg`: speaking mascot with an animated mouth, used while pronunciation audio plays.
- `assets/mascots/reaper.svg`, `monkey_king.svg`, `saint.svg`, `satan.svg`, `zeus.svg`: additional characters with the same layer contract and a `mouth` group.
- `assets/mascots/grim_reaper.svg`: failure mascot using the same direct-child layer contract.

## Dependencies
Add these to your app's `pubspec.yaml` (use versions compatible with your project):

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.17
  xml: ^6.5.0

flutter:
  assets:
    - assets/mascots/
```

Then run `flutter pub get`.

## Preview
```dart
import 'package:flutter/material.dart';
import 'package:your_package/ui/svg_mascot.dart';

@Preview(name: 'Fox Mascot', size: Size(390, 844))
Widget previewFoxMascot() {
  final key = GlobalKey<SvgMascotState>();

  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgMascot(
              key: key,
              asset: 'assets/mascots/fox.svg',
              width: 260,
              height: 260,
            ),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => key.currentState?.play(MascotAnimation.spin),
                  child: const Text('Spin'),
                ),
                ElevatedButton(
                  onPressed: () => key.currentState?.play(MascotAnimation.jump),
                  child: const Text('Jump'),
                ),
                ElevatedButton(
                  onPressed: () => key.currentState?.play(MascotAnimation.raiseHands),
                  child: const Text('Raise hands'),
                ),
                ElevatedButton(
                  onPressed: () => key.currentState?.play(MascotAnimation.blink),
                  child: const Text('Blink'),
                ),
                ElevatedButton(
                  onPressed: () => key.currentState?.play(MascotAnimation.raiseEyebrows),
                  child: const Text('Raise eyebrows'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
```

Replace `your_package` with your package name, or use a relative import from your test/preview file.

## SVG authoring contract and limitations
- SVG root should use `viewBox="0 0 300 300"`.
- Each animatable part must be a direct child `<g id="...">` of the root SVG.
- Required IDs: `body`, `left_leg`, `right_leg`, `left_hand`, `right_hand`, `left_eye`, `right_eye`, `left_eyebrow`, `right_eyebrow`.
- The arm pivots and eye centers in `svg_mascot.dart` (pivot values; motion math lives in `mascot_motions.dart`) are calibrated to the sample fox's 300 x 300 coordinates. For different artwork, update those pivot coordinates or extend the SVG contract to provide them as metadata.
- Keep shared `<defs>` and `<style>` at the root. The parser keeps these in each extracted layer.
- Each `play()` call runs a single motion and returns the mascot to its resting pose. Calling `play()` again replaces the current motion.
- `autoIdle: true` randomly plays jump, yawn, or blink every 3-7 seconds. `autoBlink: true` schedules only blinks when idle mode is off. Timers are disposed with the widget; idle motion pauses for hidden routes and reduced-motion settings.
- For yawning, add an optional direct-child `<g id="mouth">` centered at `(150, 145)`. Keep the resting mouth separate from `body`. Existing assets without a mouth still animate the eyes and arms.
- Speaking: pass `speaking: PronunciationService.instance.speaking` to `SvgMascot`. While true, the mascot loops the `speakingPose` (mouth open/close plus a small bob). The mouth group scales up to 5x vertically from `(150, 145)`, so keep the closed mouth thin (about `ry` 2.5 to 3) and the open shape stays inside the face. Assets without a mouth bob but do not open their mouth.
- Speaking games (level header and follow-the-sound) pick a random mascot from `speakingMascotAssets` in `lib/ui/mascot_catalog.dart` once per widget. Passing `mascotAsset` overrides the random pick. Add new speaking mascots to that list.
- This is a lightweight XML-group extraction approach, not a complete SVG renderer/parser. Complex SVGs that rely on inherited styles, clipping paths, masks, filters, or nested transforms may need additional handling and testing.
