import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:indic_learn/animations/confetti.dart';
import 'package:indic_learn/main.dart';
import 'package:indic_learn/level_loader/level_loader.dart';
import 'package:indic_learn/level_loader/scenario_catalog.dart';
import 'package:indic_learn/levels/level.dart';
import 'package:indic_learn/levels/level_factory.dart';
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
import 'package:indic_learn/games/make_the_sentence/mts_model.dart';
import 'package:indic_learn/session/session.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Sentence games accept interchangeable repeated word tiles', () {
    const model = MTSModel(
      source: 'जाना',
      translation: 'to go to',
      words: ['to', 'go', 'to'],
      index: [0, 1, 2],
    );
    expect(model.acceptsNextWord([], 2), isTrue);
    expect(model.acceptsNextWord([2], 1), isTrue);
    expect(model.acceptsNextWord([2, 1], 0), isTrue);
    expect(model.acceptsNextWord([2, 1], 2), isFalse);
    expect(model.acceptsNextWord([], 1), isFalse);
    expect(model.acceptsNextWord([2, 1, 0], 0), isFalse);
  });

  test('Shared theme defines semantic component colors and states', () {
    final theme = buildGameTheme();
    final colors = theme.colorScheme;
    expect(theme.scaffoldBackgroundColor, colors.surface);
    expect(theme.textTheme.bodyLarge?.color, colors.onSurface);
    expect(theme.appBarTheme.backgroundColor, colors.primary);
    expect(theme.appBarTheme.foregroundColor, colors.onPrimary);
    for (final style in [
      theme.filledButtonTheme.style!,
      theme.elevatedButtonTheme.style!,
    ]) {
      expect(style.backgroundColor?.resolve({}), colors.primary);
      expect(style.foregroundColor?.resolve({}), colors.onPrimary);
      expect(
        style.foregroundColor?.resolve({WidgetState.disabled}),
        colors.onSurface.withValues(alpha: 0.38),
      );
      expect(style.minimumSize?.resolve({}), const Size(48, 48));
    }
    final input = theme.inputDecorationTheme;
    expect(input.enabledBorder?.borderSide.color, colors.outline);
    expect(input.focusedBorder?.borderSide.color, colors.primary);
    expect(input.focusedBorder?.borderSide.width, 2);
    expect(input.errorBorder?.borderSide.color, colors.error);
    expect(input.focusedErrorBorder?.borderSide.color, colors.error);
    expect(input.disabledBorder?.borderSide.color, colors.outlineVariant);
    expect(theme.extension<GameFeedbackColors>(), isNotNull);
  });

  testWidgets('Shared scaffold inherits app bar and input theme', (
    tester,
  ) async {
    final theme = buildGameTheme();
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const GameScaffold(
          title: 'Theme check',
          child: TextField(decoration: InputDecoration(labelText: 'Name')),
        ),
      ),
    );
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, isNull);
    expect(appBar.foregroundColor, isNull);
    final material = tester.widget<Material>(
      find
          .descendant(of: find.byType(AppBar), matching: find.byType(Material))
          .first,
    );
    expect(material.color, theme.colorScheme.primary);
    final input = tester.widget<InputDecorator>(find.byType(InputDecorator));
    expect(
      WidgetStateProperty.resolveAs<Color>(input.decoration.fillColor!, {}),
      theme.colorScheme.surfaceContainerLowest,
    );
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    expect(
      tester.widget<InputDecorator>(find.byType(InputDecorator)).isFocused,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  for (final entry in {
    'GamePage': 'assets/Quizes/whatisthis_fruit_001.json',
    'WordMatchPage': 'assets/match_the_pairs_json/en_hi_lvl1.json',
    'MTSPage': 'assets/make_the_sentence/en_hi_lvl1.json',
    'FollowTheSound': 'assets/make_the_sentence/en_hi_lvl1.json',
  }.entries) {
    for (final embedded in [false, true]) {
      testWidgets(
        '${entry.key} ${embedded ? 'hides embedded' : 'keeps standalone'} back button',
        (tester) async {
          final json = await tester.runAsync(
            () => rootBundle.loadString(entry.value),
          );
          final bundle = _QuizAssetBundle(
            json,
            path: entry.value,
            assets: {
              'navigation-level.json': jsonEncode({
                'steps': [
                  {
                    'type': 'navigation-test',
                    'data': entry.value,
                    'handler': entry.key,
                  },
                ],
              }),
            },
          );
          final navigator = GlobalKey<NavigatorState>();
          await tester.pumpWidget(
            MaterialApp(
              navigatorKey: navigator,
              home: const Scaffold(body: Text('Home')),
            ),
          );
          await tester.runAsync(() async {
            navigator.currentState!.push<void>(
              MaterialPageRoute(
                builder: (_) => DefaultAssetBundle(
                  bundle: bundle,
                  child: embedded
                      ? LevelPage(assetPath: 'navigation-level.json',sessionStats: SessionStats())
                      : getHandler(
                          entry.key,
                          const ValueKey('navigation-test'),
                          entry.value,
                          (_, _) {},
                        ),
                ),
              ),
            );
            await tester.pump();
          });
          // Level mascots keep animating while the page is visible.
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump();
          expect(find.byType(AppBar), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.byType(BackButton),
            ),
            embedded ? findsNothing : findsOneWidget,
          );
          expect(find.byType(BackButton), findsOneWidget);
          if (embedded) {
            expect(find.text('Step 1/1'), findsOneWidget);
          }
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          expect(find.text('Home'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

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

  test('Failure mascot matches the direct-child layer contract', () async {
    final source = await rootBundle.loadString('assets/mascots/grim_reaper.svg');
    expect(
      SvgMascotParser.parse(source).map((layer) => layer.id),
      [
        'left_leg',
        'right_leg',
        'left_hand',
        'right_hand',
        'body',
        'left_eye',
        'right_eye',
        'left_eyebrow',
        'right_eyebrow',
        'mouth',
      ],
    );
  });

  test('Bundled catalog preserves everyday levels and adds the auto scenario', () async {
    final scenarios = await ScenarioCatalog.load(rootBundle);
    expect(scenarios, hasLength(2));
    expect(scenarios.first.id, 'everyday-practice');
    expect(scenarios.first.levels, hasLength(10));
    expect(scenarios.last.id, 'hi-en-auto-rickshaw');
    expect(scenarios.last.levels, hasLength(12));
    final levels = scenarios.expand((scenario) => scenario.levels).toList();
    expect(scenarios.every((scenario) => scenario.unlocked), isTrue);
    expect(
      scenarios.first.levels.map((level) => level.progressId),
      List.generate(10, (index) => 'everyday-${(index + 1).toString().padLeft(2, '0')}'),
    );
    expect(
      scenarios.last.levels.map((level) => level.progressId),
      List.generate(12, (index) => 'auto-rickshaw-${(index + 1).toString().padLeft(2, '0')}'),
    );
    expect(levels.map((level) => level.assetPath).toSet(), hasLength(22));
    expect(levels.map((level) => level.title).toSet(), hasLength(22));
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
      id: 'full', title: 'Full', levels: List.generate(12, (index) => LevelDefinition(
        id: 'level-$index',
        title: level.title,
        assetPath: level.assetPath,
      )), completedLevels: 12,
    );
    expect(full.validate, returnsNormally);
    const invalidProgress = ScenarioDefinition(
      id: 'invalid', title: 'Invalid', levels: [level], completedLevels: 2,
    );
    expect(invalidProgress.validate, throwsArgumentError);
    const duplicateIds = ScenarioDefinition(
      id: 'duplicate',
      title: 'Duplicate',
      levels: [
        LevelDefinition(id: 'same', title: 'First', assetPath: 'first.json'),
        LevelDefinition(id: 'same', title: 'Second', assetPath: 'second.json'),
      ],
    );
    expect(duplicateIds.validate, throwsArgumentError);
  });

  for (final useSystemBack in [false, true]) {
    testWidgets(
      'Scenario Continue advances and ${useSystemBack ? 'system' : 'header'} Back returns to ladder',
      (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: LevelLoader(
            mascot: const SizedBox.square(dimension: 96),
            levelBuilder: (level, onCompleted) => _FakeLevelPage(
              level: level,
              onCompleted: onCompleted,
            ),
            scenarios: const [
              ScenarioDefinition(id: 'navigation', title: 'Navigation', levels: [
                LevelDefinition(title: 'First level', assetPath: 'first.json'),
                LevelDefinition(title: 'Second level', assetPath: 'second.json'),
                LevelDefinition(title: 'Third level', assetPath: 'third.json'),
              ]),
            ],
          ),
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('scenario-navigation')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Complete lesson'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(find.text('Second level'), findsOneWidget);
        expect(find.text('First level'), findsNothing);

        if (useSystemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byType(BackButton));
        }
        await tester.pumpAndSettle();
        expect(find.byType(_FakeLevelPage), findsNothing);
        expect(find.byKey(const ValueKey('scenario-navigation')), findsOneWidget);
        expect(find.text('1 / 3 complete'), findsOneWidget);

        await tester.tap(find.byKey(const ValueKey('scenario-navigation')));
        await tester.pumpAndSettle();
        expect(find.text('Second level'), findsOneWidget);
        for (final title in ['Third level', null]) {
          await tester.tap(find.text('Complete lesson'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          if (title != null) expect(find.text(title), findsOneWidget);
        }
        expect(find.byType(_FakeLevelPage), findsNothing);
        expect(find.byKey(const ValueKey('scenario-navigation')), findsOneWidget);
        expect(find.text('3 / 3 complete'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Scenario progress advances only on completion and stays independent', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LevelLoader(
        mascot: const SizedBox.square(dimension: 96),
        levelBuilder: (level, onCompleted) => _FakeLevelPage(
          level: level,
          onCompleted: onCompleted,
        ),
        scenarios: const [
          ScenarioDefinition(id: 'first', title: 'First scenario', levels: [
            LevelDefinition(title: 'First level', assetPath: 'first.json'),
            LevelDefinition(title: 'Second level', assetPath: 'second.json'),
          ]),
          ScenarioDefinition(id: 'other', title: 'Other scenario', levels: [
            LevelDefinition(title: 'Other level', assetPath: 'other.json'),
          ]),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('0 / 2 complete'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-first')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<_FakeLevelPage>(find.byType(_FakeLevelPage)).level.assetPath,
      'first.json',
    );
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('0 / 2 complete'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-first')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete lesson'));
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
    expect(
      tester.widget<_FakeLevelPage>(find.byType(_FakeLevelPage)).level.assetPath,
      'second.json',
    );
    await tester.tap(find.text('Complete lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete lesson'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('2 / 2 complete'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-first')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<_FakeLevelPage>(find.byType(_FakeLevelPage)).level.assetPath,
      'second.json',
    );
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scenario-other')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<_FakeLevelPage>(find.byType(_FakeLevelPage)).level.assetPath,
      'other.json',
    );
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
    await tester.pumpWidget(const MaterialApp(
      home: LevelLoader(mascot: SizedBox.square(dimension: 96)),
    ));
    final bundle = DefaultAssetBundle.of(tester.element(find.byType(LevelLoader)));
    await tester.runAsync(() => ScenarioCatalog.load(bundle));
    await tester.pumpAndSettle();
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
          'assets/levels/level_1.json',
          'assets/Quizes/whatisthis_fruit_001.json',
          'assets/match_the_pairs_json/en_hi_lvl1.json',
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
        'assets/match_the_pairs_json/en_hi_lvl1.json',
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
      path: 'assets/match_the_pairs_json/en_hi_lvl1.json',
    );
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: MaterialApp(
          theme: buildGameTheme(),
          home: const WordMatchPage(
            initialJsonData: 'assets/match_the_pairs_json/en_hi_lvl1.json',
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

  testWidgets('Quiz introductions precede answers without adding responses', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final source = (await tester.runAsync(
      () => rootBundle.loadString('assets/Quizes/whatisthis_fruit_001.json'),
    ))!;
    final payload = [
      ...(jsonDecode(source) as List<dynamic>),
      ...(jsonDecode(source) as List<dynamic>),
    ].take(2).toList();
    for (final question in payload) {
      question['introduce'] = true;
      final correct = (question['choices'] as List<dynamic>).firstWhere(
        (choice) => choice['correct'] == true,
      );
      correct['text']['en'] = {'native': 'Fruit'};
    }
    int? completedScore;
    int? completedTotal;
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: _QuizAssetBundle(jsonEncode(payload)),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: GamePage(
            onComplete: (score, total) {
              completedScore = score;
              completedTotal = total;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (
      var questionIndex = 0;
      questionIndex < payload.length;
      questionIndex++
    ) {
      expect(find.byType(ChoiceButton), findsNothing);
      expect(find.text('Fruit'), findsOneWidget);
      expect(find.byTooltip('Listen'), findsOneWidget);
      expect(completedTotal, isNull);
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    for (
      var questionIndex = 0;
      questionIndex < payload.length;
      questionIndex++
    ) {
      expect(find.byType(ChoiceButton), findsWidgets);
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is ChoiceButton && widget.choice.correct,
        ),
      );
      await tester.pumpAndSettle();
      final isLast = questionIndex == payload.length - 1;
      await tester.ensureVisible(find.text(isLast ? 'Finish' : 'Continue'));
      await tester.tap(find.text(isLast ? 'Finish' : 'Continue'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(completedScore, payload.length);
    expect(completedTotal, payload.length);
  });

  for (final (size, textScale) in [
    (const Size(1280, 800), 1.0),
    (const Size(390, 844), 1.0),
    (const Size(320, 640), 1.5),
    (const Size(1280, 480), 2.0),
  ]) {
    testWidgets('Quiz introduction fits $size with text scale $textScale', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final questions = (await tester.runAsync(
        () => GameLoader.loadQuestions(
          'assets/Quizes/hi_en_auto_rickshaw_a02.json',
        ),
      ))!;
      var listens = 0;
      var continues = 0;
      final question = questions.first;
      final choice = question.choices.firstWhere((choice) => choice.correct);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildGameTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('Learn 1/4')),
            body: SafeArea(
              child: QuestionView(
                question: question,
                progress: 0.25,
                isLastQuestion: false,
                selectedChoiceId: null,
                answered: false,
                promptLanguage: question.promptLanguage,
                targetLanguage: question.targetLanguage,
                displayVariant: 'native',
                introducing: true,
                onChoiceSelected: (_) => fail('Introductions have no choices'),
                onContinue: () => fail('Introductions do not submit answers'),
                onIntroductionComplete: () => continues++,
                onPlayPronunciation: () => listens++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final image = find.byType(SvgPicture);
      final progress = find.byType(LinearProgressIndicator);
      final continueButton = find.widgetWithText(FilledButton, 'Continue');
      expect(tester.getSize(image).width, lessThanOrEqualTo(480));
      expect(tester.getSize(image).height, lessThanOrEqualTo(280));
      expect(tester.getSize(progress).width, lessThanOrEqualTo(592));
      expect(tester.getCenter(progress).dx, closeTo(size.width / 2, 1));
      expect(
        find.text(choice.text[question.targetLanguage]!.native),
        findsOneWidget,
      );
      expect(find.byType(ChoiceButton), findsNothing);
      if (size == const Size(1280, 800)) {
        expect(continueButton.hitTestable(), findsOneWidget);
        expect(tester.getRect(continueButton).bottom, lessThan(size.height));
        final scrollable = tester.state<ScrollableState>(
          find.byType(Scrollable),
        );
        expect(scrollable.position.maxScrollExtent, 0);
      }
      await tester.ensureVisible(find.byTooltip('Listen'));
      await tester.tap(find.byTooltip('Listen'));
      expect(listens, 1);
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      expect(continues, 1);
      expect(tester.takeException(), isNull);
    });
  }

  for (final assetAvailable in [true, false]) {
    testWidgets(
      'Quiz ${assetAvailable ? 'loads' : 'reports failure'} with inherited asset bundle',
      (WidgetTester tester) async {
        final json = await tester.runAsync(
          () => rootBundle.loadString('assets/Quizes/whatisthis_fruit_001.json'),
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
          contains('assets/Quizes/whatisthis_fruit_001.json'),
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
          () => GameLoader.loadQuestions('assets/Quizes/whatisthis_fruit_001.json'),
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

class _FakeLevelPage extends StatefulWidget {
  const _FakeLevelPage({required this.level, required this.onCompleted});

  final LevelDefinition level;
  final VoidCallback onCompleted;

  @override
  State<_FakeLevelPage> createState() => _FakeLevelPageState();
}

class _FakeLevelPageState extends State<_FakeLevelPage> {
  bool _completed = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.level.title)),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_completed) const Text('Level complete!'),
          FilledButton(
            onPressed: () {
              if (_completed) {
                setState(() => _completed = false);
              } else {
                widget.onCompleted();
                setState(() => _completed = true);
              }
            },
            child: Text(_completed ? 'Play Again' : 'Complete lesson'),
          ),
          if (_completed)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue'),
            ),
        ],
      ),
    ),
  );
}

class _QuizAssetBundle extends CachingAssetBundle {
  _QuizAssetBundle(
    this.json, {
    this.path = 'assets/Quizes/whatisthis_fruit_001.json',
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
