import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:indic_learn/animations/confetti.dart';
import 'package:indic_learn/main.dart';
import 'package:indic_learn/level_loader/level_loader.dart';
import 'package:indic_learn/levels/level.dart';
import 'package:indic_learn/levels/level_model.dart';
import 'package:indic_learn/widgets/svg_mascot.dart';
import 'package:indic_learn/widgets/svg_mascot_parser.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    rootBundle.clear();
    svg.cache.clear();
    final source = await rootBundle.loadString('assets/mascots/sprout.svg');
    for (final layer in SvgMascotParser.parse(source)) {
      final loader = SvgStringLoader(layer.svg);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
    }
  });

  test('Bundled level catalog has ten playable levels using existing data', () {
    const catalog = LevelLoader();
    expect(catalog.scenarios, hasLength(1));
    final levels = catalog.scenarios.single.levels;
    expect(levels, hasLength(10));
    expect(catalog.scenarios.single.unlocked, isTrue);
    expect(levels.map((level) => level.assetPath).toSet(), hasLength(10));
    expect(levels.map((level) => level.title).toSet(), hasLength(10));
    const handlers = {
      'quiz': 'GamePage',
      'match_the_pair': 'WordMatchPage',
      'make_the_sentence': 'MTSPage',
      'follow_the_sound': 'FollowTheSound',
    };
    for (final level in levels) {
      final definition = jsonDecode(File(level.assetPath).readAsStringSync())
          as Map<String, dynamic>;
      final steps = definition['steps'] as List<dynamic>;
      expect(steps, isNotEmpty, reason: level.title);
      for (final entry in steps) {
        final step = LevelStep.fromJson(entry as Map<String, dynamic>);
        expect(step.handler, handlers[step.type], reason: level.title);
        final data = File(step.assetPath);
        expect(data.existsSync(), isTrue, reason: step.assetPath);
        final payload = jsonDecode(data.readAsStringSync());
        expect(payload, step.type == 'quiz' ? isA<List<dynamic>>() : isA<Map<String, dynamic>>());
      }
    }
  });

  test('Scenario definitions enforce level and progress limits', () {
    const level = LevelDefinition(title: 'Practice', assetPath: 'practice.json');
    for (final count in [0, 13]) {
      final scenario = ScenarioDefinition(
        id: 'invalid', title: 'Invalid', levels: List.filled(count, level),
      );
      expect(scenario.validate, throwsArgumentError);
    }
    final full = ScenarioDefinition(
      id: 'full', title: 'Full', levels: List.filled(12, level), completedLevels: 12,
    );
    expect(full.validate, returnsNormally);
    const invalidProgress = ScenarioDefinition(
      id: 'invalid', title: 'Invalid', levels: [level], completedLevels: 2,
    );
    expect(invalidProgress.validate, throwsArgumentError);
  });

  testWidgets('Scenario progress advances only on completion and stays independent', (tester) async {
    final lesson = jsonEncode({
      'steps': [
        {'type': 'quiz', 'data': 'scenario-quiz.json', 'handler': 'GamePage'},
      ],
    });
    final bundle = _QuizAssetBundle(null, assets: {
      'first.json': lesson,
      'second.json': lesson,
      'other.json': lesson,
      'scenario-quiz.json': File('assets/Quizes/whatisthis_fruit_001.json').readAsStringSync(),
    });
    await tester.pumpWidget(DefaultAssetBundle(
      bundle: bundle,
      child: const MaterialApp(home: LevelLoader(scenarios: [
        ScenarioDefinition(id: 'first', title: 'First scenario', levels: [
          LevelDefinition(title: 'First level', assetPath: 'first.json'),
          LevelDefinition(title: 'Second level', assetPath: 'second.json'),
        ]),
        ScenarioDefinition(id: 'other', title: 'Other scenario', levels: [
          LevelDefinition(title: 'Other level', assetPath: 'other.json'),
        ]),
      ])),
    ));
    try {
      await tester.pumpAndSettle();
    } catch (_) {
      debugDumpApp();
      rethrow;
    }
    expect(find.text('0 / 2 complete'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-first')));
    await tester.pumpAndSettle();
    expect(tester.widget<LevelPage>(find.byType(LevelPage)).assetPath, 'first.json');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('0 / 2 complete'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-first')));
    await tester.pumpAndSettle();
    tester.widget<GamePage>(find.byType(GamePage)).onComplete!(1, 1);
    await tester.pumpAndSettle();
    expect(find.text('Level complete!'), findsOneWidget);
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('1 / 2 complete'), findsOneWidget);
    expect(find.text('0 / 1 complete'), findsOneWidget);
    expect(tester.widget<CircularProgressIndicator>(
      find.byKey(const ValueKey('scenario-progress-first')),
    ).value, 0.5);
    await tester.tap(find.byKey(const ValueKey('scenario-first')));
    await tester.pumpAndSettle();
    expect(tester.widget<LevelPage>(find.byType(LevelPage)).assetPath, 'second.json');
    tester.widget<GamePage>(find.byType(GamePage)).onComplete!(1, 1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    tester.widget<GamePage>(find.byType(GamePage)).onComplete!(1, 1);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('2 / 2 complete'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-first')));
    await tester.pumpAndSettle();
    expect(tester.widget<LevelPage>(find.byType(LevelPage)).assetPath, 'second.json');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scenario-other')));
    await tester.pumpAndSettle();
    expect(tester.widget<LevelPage>(find.byType(LevelPage)).assetPath, 'other.json');
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Scenario picker resumes supplied progress and shows twelve levels', (tester) async {
    final levels = List.generate(12, (index) => LevelDefinition(
      title: 'Level ${index + 1}', assetPath: 'lesson-$index.json',
    ));
    await tester.pumpWidget(DefaultAssetBundle(
      bundle: _QuizAssetBundle('{"steps":[]}', path: 'lesson-5.json'),
      child: MaterialApp(home: LevelLoader(scenarios: [
        ScenarioDefinition(id: 'resume', title: 'Resume', levels: levels, completedLevels: 5),
      ])),
    ));
    await tester.pumpAndSettle();
    expect(find.text('5 / 12 complete'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-resume')));
    await tester.pumpAndSettle();
    expect(tester.widget<LevelPage>(find.byType(LevelPage)).assetPath, 'lesson-5.json');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Scenario picker blocks locked scenarios and opens after landing', (
    tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _QuizAssetBundle('{"steps":[]}', path: 'test-level.json'),
        child: const MaterialApp(
          home: LevelLoader(
            scenarios: [
              ScenarioDefinition(id: 'start', title: 'Start', levels: [
                LevelDefinition(title: 'First', assetPath: 'test-level.json'),
              ]),
              ScenarioDefinition(id: 'next', title: 'Next', levels: [
                LevelDefinition(title: 'First', assetPath: 'test-level.json'),
              ]),
              ScenarioDefinition(id: 'locked', title: 'Locked', unlocked: false, levels: [
                LevelDefinition(title: 'First', assetPath: 'test-level.json'),
              ]),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final locked = find.byKey(const ValueKey('scenario-locked'));
    expect(tester.widget<FilledButton>(locked).onPressed, isNull);
    await tester.tap(locked);
    await tester.pump();
    expect(find.byType(LevelPage), findsNothing);
    final mascotStart = tester.getTopLeft(find.byType(SvgMascot));
    expect(tester.widget<SvgMascot>(find.byType(SvgMascot)).autoIdle, isTrue);
    await tester.tap(find.byKey(const ValueKey('scenario-next')));
    await tester.pump();
    expect(tester.widget<SvgMascot>(find.byType(SvgMascot)).autoIdle, isFalse);
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(LevelPage), findsNothing);
    expect(tester.getTopLeft(find.byType(SvgMascot)).dx, greaterThan(mascotStart.dx));
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('scenario-start'))).onPressed, isNull);
    await tester.pumpAndSettle();
    expect(find.byType(LevelPage), findsOneWidget);
    expect(find.textContaining('Unable to load level:'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(tester.widget<SvgMascot>(find.byType(SvgMascot)).autoIdle, isTrue);
    expect(tester.getTopLeft(find.byType(SvgMascot)).dx, greaterThan(mascotStart.dx));
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('scenario-start'))).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Scenario picker handles empty, locked, and narrow layouts', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: LevelLoader(scenarios: [])));
    expect(find.text('No scenarios available'), findsOneWidget);
    await tester.pumpWidget(const MaterialApp(
      home: LevelLoader(key: ValueKey('locked'), scenarios: [
        ScenarioDefinition(id: 'locked', title: 'Coming soon', unlocked: false, levels: [
          LevelDefinition(title: 'First', assetPath: 'missing.json'),
        ]),
      ]),
    ));
    expect(find.byType(SvgMascot), findsNothing);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Scenario picker cancels safely when removed during a jump', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LevelLoader()));
    await tester.tap(find.byKey(const ValueKey('scenario-everyday-practice')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mascot shares jump yawn blink and cleans up idle scheduling', (tester) async {
    rootBundle.evict('assets/mascots/sprout.svg');
    final source = await tester.runAsync(
      () => rootBundle.loadString('assets/mascots/sprout.svg'),
    );
    expect(SvgMascotParser.parse(source!).map((layer) => layer.id), contains('mouth'));
    final mascotKey = GlobalKey<SvgMascotState>();
    await tester.pumpWidget(MaterialApp(home: Center(child: SvgMascot(
      key: mascotKey,
      asset: 'assets/mascots/sprout.svg',
      autoIdle: true,
    ))));
    await tester.pumpAndSettle();
    for (final motion in [MascotAnimation.jump, MascotAnimation.yawn, MascotAnimation.blink]) {
      mascotKey.currentState!.play(motion);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final transforms = tester.widgetList<Transform>(find.descendant(
        of: find.byType(SvgMascot), matching: find.byType(Transform),
      ));
      expect(transforms.any((widget) => !widget.transform.isIdentity()), isTrue);
      await tester.pumpAndSettle();
    }
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
    expect(tester.takeException(), isNull);
  });

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
        await tester.tap(find.byKey(const ValueKey('scenario-everyday-practice')));
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
      final bundle = _QuizAssetBundle(fixture, path: 'assets/levels/level_1.json');
      await tester.pumpWidget(
        DefaultAssetBundle(bundle: bundle, child: const LanguageGameApp()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('scenario-everyday-practice')));
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
