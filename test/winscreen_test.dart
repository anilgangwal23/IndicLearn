import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indic_learn/levels/winscreen.dart';
import 'package:indic_learn/widgets/svg_mascot.dart';

void main() {
  testWidgets('WinScreen displays results and delegates replay', (tester) async {
    var replayCount = 0;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: WinScreen(
            score: 7,
            total: 10,
            mascotAsset: 'assets/mascots/sprout.svg',
            onPlayAgain: () => replayCount++,
          ),
        ),
      );
    });
    await tester.pump();

    expect(find.text('Level complete!'), findsOneWidget);
    expect(find.text('You scored 7 out of 10'), findsOneWidget);
    final mascot = tester.widget<SvgMascot>(find.byType(SvgMascot));
    expect(mascot.asset, 'assets/mascots/sprout.svg');
    expect(mascot.autoIdle, isTrue);
    expect(mascot.height, 100);
    expect(replayCount, 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Play Again'));
    expect(replayCount, 1);
    expect(find.text('You scored 7 out of 10'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
