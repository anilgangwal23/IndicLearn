import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:indic_learn/animations/confetti.dart';
import 'package:indic_learn/main.dart';
import 'package:indic_learn/ui/game_theme.dart';
import 'package:indic_learn/ui/game_widgets.dart';
import 'package:indic_learn/games/match_the_pair/pairing.dart';
import 'package:indic_learn/games/match_the_pair/pairing_loader.dart'
    as pairing;
import 'package:indic_learn/games/quiz_ui/quiz_loader.dart';
import 'package:indic_learn/games/quiz_ui/quiz.dart' show GamePage;
import 'package:indic_learn/games/quiz_ui/widgets/choice_button.dart';
import 'package:indic_learn/games/quiz_ui/widgets/question_view.dart';

void main() {
  testWidgets('Shared controls preserve feedback and support text input', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildGameTheme(),
        home: GameScaffold(
          title: 'Shared controls',
          child: Column(
            children: [
              const QuestionPrompt(text: 'Build a sentence'),
              const GameAnswerTile(
                state: AnswerVisualState.correct,
                onPressed: null,
                child: Text('Correct word'),
              ),
              const GameAnswerTile(
                state: AnswerVisualState.incorrect,
                onPressed: null,
                child: Text('Wrong word'),
              ),
              GameTextField(controller: controller, label: 'Answer'),
            ],
          ),
          footer: const GameButton(label: 'Continue', onPressed: null),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    final correctButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Correct word'),
    );
    expect(
      correctButton.style!.backgroundColor!.resolve({WidgetState.disabled}),
      const GameFeedbackColors().successSurface,
    );
    await tester.enterText(find.byType(TextFormField), 'My answer');
    expect(controller.text, 'My answer');
    expect(tester.takeException(), isNull);
  });

  for (final answerCorrectly in [true, false]) {
    testWidgets(
      'Level plays ${answerCorrectly ? 'correct' : 'incorrect'} quiz then pairs and restarts from step one',
      (tester) async {
        final assets = <String, String>{};
        for (final path in [
          'levels/level_1.json',
          'Quizes/whatisthis_fruit_001.json',
          'match_the_pairs_json/en_hi_lvl1.json',
        ]) {
          assets[path] = (await tester.runAsync(
            () => rootBundle.loadString(path),
          ))!;
        }
        final bundle = _QuizAssetBundle(null, assets: assets);
        await tester.pumpWidget(
          DefaultAssetBundle(bundle: bundle, child: const LanguageGameApp()),
        );
        await tester.pumpAndSettle();
        expect(find.text('Step 1/2'), findsOneWidget);

        var questionCount = 0;
        while (find.byType(QuestionView).evaluate().isNotEmpty) {
          questionCount++;
          final view = tester.widget<QuestionView>(find.byType(QuestionView));
          await tester.tap(
            find
                .byWidgetPredicate(
                  (widget) =>
                      widget is ChoiceButton &&
                      widget.choice.correct == answerCorrectly,
                )
                .first,
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.text(view.isLastQuestion ? 'Finish' : 'Continue'),
          );
          await tester.pumpAndSettle();
        }
        expect(find.text('Step 2/2'), findsOneWidget);
        expect(find.byType(WordMatchPage), findsOneWidget);
        expect(find.text('Continue'), findsNothing);
        for (final id in [0, 1, 2]) {
          await tester.tap(find.byKey(ValueKey('left-$id')));
          await tester.pump();
          await tester.tap(find.byKey(ValueKey('right-$id')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Level complete!'), findsOneWidget);
        final expectedScore = (answerCorrectly ? questionCount : 0) + 3;
        expect(
          find.text('You scored $expectedScore out of ${questionCount + 3}'),
          findsOneWidget,
        );
        await tester.tap(find.text('Play Again'));
        await tester.pumpAndSettle();
        expect(find.text('Step 1/2'), findsOneWidget);
        final view = tester.widget<QuestionView>(find.byType(QuestionView));
        expect(view.answered, isFalse);
        expect(view.selectedChoiceId, isNull);
        expect(find.text('Question 1/$questionCount'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final fixture in <String?>[
    null,
    '{"steps":[]}',
    '{"steps":[{"type":"unknown","data":"missing.json"}]}',
  ]) {
    testWidgets('Level reports invalid or missing data: $fixture', (
      tester,
    ) async {
      final bundle = _QuizAssetBundle(fixture, path: 'levels/level_1.json');
      await tester.pumpWidget(
        DefaultAssetBundle(bundle: bundle, child: const LanguageGameApp()),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Unable to load level:'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Pairs load the bundled word_pair_list asset', (tester) async {
    final pairs = await tester.runAsync(
      () => pairing.GameLoader.loadPairings(
        'match_the_pairs_json/en_hi_lvl1.json',
      ),
    );
    expect(pairs!.map((pair) => pair.leftWord), ['Apple', 'Banana', 'Carrot']);
    expect(pairs.map((pair) => pair.originalIndex), [0, 1, 2]);
  });

  testWidgets('Pairs require left first and reset only incorrect matches', (
    WidgetTester tester,
  ) async {
    final bundle = _QuizAssetBundle(
      jsonEncode([
        {'left_word': 'Apple', 'right_definition': 'Seb', 'original_index': 1},
        {'left_word': 'Mango', 'right_definition': 'Aam', 'original_index': 2},
      ]),
      path: 'match_the_pairs_json/en_hi_lvl1.json',
    );
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: MaterialApp(
          theme: buildGameTheme(),
          home: const WordMatchPage(
            initialJsonData: 'match_the_pairs_json/en_hi_lvl1.json',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    OutlinedButton button(String key) =>
        tester.widget<OutlinedButton>(find.byKey(ValueKey(key)));
    Color? background(String key) =>
        button(key).style!.backgroundColor!.resolve(<WidgetState>{});
    final errorSurface = buildGameTheme().colorScheme.errorContainer;
    final successSurface = const GameFeedbackColors().successSurface;

    expect(button('right-1').onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('left-1')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('right-2')));
    await tester.pump();
    expect(background('left-1'), errorSurface);
    expect(background('right-2'), errorSurface);
    expect(button('left-2').onPressed, isNull);
    expect(find.text('Match Words (Score 0)'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    expect(background('left-1'), isNot(errorSurface));
    expect(background('right-2'), isNot(errorSurface));
    expect(button('right-1').onPressed, isNull);
    expect(button('left-1').onPressed, isNotNull);

    for (final id in [1, 2]) {
      await tester.tap(find.byKey(ValueKey('left-$id')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('right-$id')));
      await tester.pump();
      expect(background('left-$id'), successSurface);
      expect(background('right-$id'), successSurface);
      expect(button('left-$id').onPressed, isNull);
      expect(button('right-$id').onPressed, isNull);
    }
    expect(find.text('Match Words (Score 2)'), findsOneWidget);
    expect(find.text('All pairs matched!'), findsOneWidget);
    expect(background('left-1'), successSurface);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Shared game layout fits narrow screens with larger text and reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var presses = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: GameScaffold(
            title: 'Practice',
            child: Column(
              children: [
                const QuestionPrompt(
                  text: 'A longer question that wraps onto multiple lines',
                ),
                const SizedBox(height: 24),
                const GameAnswerArea(child: Text('Your sentence')),
                const SizedBox(height: 24),
                GameAnswerTile(
                  onPressed: () => presses++,
                  child: const Text('A longer answer choice'),
                ),
                const GameFeedback(correct: false),
              ],
            ),
            footer: const GameButton(
              label: 'Continue to the next question',
              icon: Icons.arrow_forward,
              onPressed: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('A longer answer choice'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A longer answer choice'));
      expect(presses, 1);
      expect(tester.takeException(), isNull);
    },
  );

  for (final assetAvailable in [true, false]) {
    testWidgets(
      'Quiz ${assetAvailable ? 'loads' : 'reports failure'} with inherited asset bundle',
      (WidgetTester tester) async {
        final json = await tester.runAsync(
          () => rootBundle.loadString('Quizes/whatisthis_fruit_001.json'),
        );
        final bundle = _QuizAssetBundle(assetAvailable ? json : null);

        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: bundle,
            child: const MaterialApp(home: GamePage()),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          bundle.requestedPaths,
          contains('Quizes/whatisthis_fruit_001.json'),
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
        if (assetAvailable) {
          expect(find.byType(QuestionView), findsOneWidget);
        } else {
          expect(find.textContaining('Unable to load quiz:'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final answerCorrectly in [true, false]) {
    testWidgets(
      'Quiz scores ${answerCorrectly ? 'correct' : 'incorrect'} answers and restarts',
      (WidgetTester tester) async {
        final questions = (await tester.runAsync(
          () => GameLoader.loadQuestions('Quizes/whatisthis_fruit_001.json'),
        ))!;

        await tester.runAsync(() async {
          await tester.pumpWidget(const MaterialApp(home: GamePage()));
        });
        await tester.pumpAndSettle();

        for (var index = 0; index < questions.length; index++) {
          expect(
            find.text('Question ${index + 1}/${questions.length}'),
            findsOneWidget,
          );
          expect(find.byType(FilledButton), findsNothing);

          final choice = find
              .byWidgetPredicate(
                (widget) =>
                    widget is ChoiceButton &&
                    widget.choice.correct == answerCorrectly,
              )
              .first;
          await tester.tap(choice);
          await tester.pumpAndSettle();

          for (final button in tester.widgetList<OutlinedButton>(
            find.byType(OutlinedButton),
          )) {
            expect(button.onPressed, isNull);
          }

          final isLastQuestion = index == questions.length - 1;
          await tester.tap(find.text(isLastQuestion ? 'Finish' : 'Continue'));
          await tester.pumpAndSettle();
        }

        final expectedScore = answerCorrectly ? questions.length : 0;
        expect(
          find.text('You scored $expectedScore out of ${questions.length}'),
          findsOneWidget,
        );

        await tester.tap(find.text('Play Again'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final questionView = tester.widget<QuestionView>(
          find.byType(QuestionView),
        );
        expect(questionView.question.id, questions.first.id);
        expect(questionView.answered, isFalse);
        expect(questionView.selectedChoiceId, isNull);

        final confetti = tester.widget<CustomPaint>(
          find.byWidgetPredicate(
            (widget) =>
                widget is CustomPaint && widget.painter is ConfettiPainter,
          ),
        );
        expect(
          (confetti.painter! as ConfettiPainter).progress.value,
          greaterThan(0),
        );

        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _QuizAssetBundle extends CachingAssetBundle {
  _QuizAssetBundle(
    this.json, {
    this.path = 'Quizes/whatisthis_fruit_001.json',
    this.assets = const {},
  });

  final String? json;
  final String path;
  final Map<String, String> assets;
  final List<String> requestedPaths = [];

  @override
  Future<ByteData> load(String key) async {
    requestedPaths.add(key);
    if (assets.containsKey(key)) {
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(assets[key]!)),
      );
    }
    if (key == path) {
      if (json == null) {
        throw FlutterError('Preview fixture unavailable');
      }
      return ByteData.sublistView(Uint8List.fromList(utf8.encode(json!)));
    }
    return rootBundle.load(key);
  }
}
