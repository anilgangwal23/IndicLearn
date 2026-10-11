import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'svg_mascot.dart';

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
              asset: 'packages/indic_learn/assets/mascots/fox.svg',
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
