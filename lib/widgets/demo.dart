import 'package:material_ui/material_ui.dart';
import 'package:flutter/widget_previews.dart';
import '../l10n/app_localizations.dart';
import 'svg_mascot.dart';

@Preview(name: 'Fox Mascot', size: Size(390, 844))
Widget previewFoxMascot() {
  final key = GlobalKey<SvgMascotState>();

  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
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
                      child: Text(l10n.demoSpin),
                    ),
                    ElevatedButton(
                      onPressed: () => key.currentState?.play(MascotAnimation.jump),
                      child: Text(l10n.demoJump),
                    ),
                    ElevatedButton(
                      onPressed: () => key.currentState?.play(MascotAnimation.raiseHands),
                      child: Text(l10n.demoRaiseHands),
                    ),
                    ElevatedButton(
                      onPressed: () => key.currentState?.play(MascotAnimation.blink),
                      child: Text(l10n.demoBlink),
                    ),
                    ElevatedButton(
                      onPressed: () => key.currentState?.play(MascotAnimation.raiseEyebrows),
                      child: Text(l10n.demoRaiseEyebrows),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
