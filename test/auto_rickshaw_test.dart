import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:indic_learn/audio/pronunciation_service.dart';
import 'package:indic_learn/games/follow_the_sound/fts.dart';
import 'package:indic_learn/games/make_the_sentence/mts_loader.dart'
    as sentence_loader;
import 'package:indic_learn/games/match_the_pair/pairing.dart';
import 'package:indic_learn/games/match_the_pair/pairing_loader.dart'
    as pair_loader;
import 'package:indic_learn/games/quiz_ui/quiz_loader.dart' as quiz_loader;
import 'package:indic_learn/games/quiz_ui/widgets/choice_button.dart';
import 'package:indic_learn/games/quiz_ui/widgets/question_view.dart';
import 'package:indic_learn/level_loader/level_loader.dart';
import 'package:indic_learn/levels/level.dart';
import 'package:indic_learn/levels/level_model.dart';

const _levelPath = 'assets/levels/hi_en_auto_rickshaw_l01.json';
const _pairPath = 'assets/match_the_pairs_json/hi_en_auto_rickshaw_a01.json';
const _quizPath = 'assets/Quizes/hi_en_auto_rickshaw_a02.json';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final ttsCalls = <MethodCall>[];
  setUp(() {
    ttsCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
          call,
        ) async {
          ttsCalls.add(call);
          return 1;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
  });

  test(
    'Level 1 loads supported, bundled data after vocabulary introduction',
    () async {
      final definition = jsonDecode(
        await rootBundle.loadString(_levelPath),
      ) as Map<String, dynamic>;
      final steps = (definition['steps'] as List<dynamic>)
          .map((entry) => LevelStep.fromJson(entry as Map<String, dynamic>))
          .toList();
      expect(steps, hasLength(6));
      expect(steps.first.type, 'match_the_pair');
      const handlers = {
        'quiz': 'GamePage',
        'match_the_pair': 'WordMatchPage',
        'follow_the_sound': 'FollowTheSound',
      };
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final bundled = manifest.listAssets().toSet();
      expect(bundled, contains(_levelPath));
      for (final step in steps) {
        expect(step.handler, handlers[step.type]);
        expect(bundled, contains(step.assetPath));
      }

      final pairs = await pair_loader.GameLoader.loadPairings(_pairPath);
      expect(pairs, hasLength(4));
      final taught = pairs.map((pair) => pair.rightDef).toSet();
      expect(taught, hasLength(4));
      expect(pairs.map((pair) => pair.leftWord).toSet(), hasLength(4));
      final audio = jsonDecode(
        await rootBundle.loadString('assets/audio/mapping.json'),
      ) as Map<String, dynamic>;
      final questions = await quiz_loader.GameLoader.loadQuestions(_quizPath);
      expect(questions, hasLength(4));
      expect(questions.map((question) => question.id).toSet(), hasLength(4));
      final correctConcepts = <String>{};
      const images = {
        'railway station': 'assets/svg_assets/station.svg',
        'market': 'assets/svg_assets/market-supermarket.svg',
        'cash': 'assets/svg_assets/money.svg',
        'auto rickshaw': 'assets/svg_assets/auto-rickshaw.svg',
      };
      for (final question in questions) {
        expect(question.type, 'image_choice');
        expect(question.promptLanguage, 'hi');
        expect(question.targetLanguage, 'en');
        expect(question.prompt['hi']!.native, isNotEmpty);
        final correct = question.choices
            .where((choice) => choice.correct)
            .single;
        final concept = correct.text['en']!.native;
        correctConcepts.add(concept);
        expect(question.image, images[concept]);
        expect(
          question.choices.map((choice) => choice.id).toSet(),
          hasLength(3),
        );
        expect(
          question.choices.map((choice) => choice.text['en']!.native).toSet(),
          hasLength(3),
        );
        for (final choice in question.choices) {
          final word = choice.text['en']!.native;
          expect(taught, contains(word));
          expect(choice.image, images[word]);
          expect(bundled, contains(choice.image));
          final entry = audio[choice.id] as Map<String, dynamic>;
          expect(entry['native'], word);
          expect(entry['language'], 'en-IN');
          expect(entry['file'], isEmpty);
        }
      }
      expect(correctConcepts, taught);
      final heard = <String>{};
      for (final step in steps.where(
        (step) => step.type == 'follow_the_sound',
      )) {
        final model = await sentence_loader.GameLoader.loadMTSModel(
          step.assetPath,
        );
        expect(model.source, isNotEmpty);
        expect(taught, contains(model.translation));
        expect(model.words, isNotEmpty);
        expect(model.index, isNotEmpty);
        expect(model.index.toSet().length, model.index.length);
        for (final index in model.index) {
          expect(index, inInclusiveRange(0, model.words.length - 1));
        }
        expect(
          model.index.map((index) => model.words[index]).join(' '),
          model.translation,
        );
        final taughtTokens = taught.expand((word) => word.split(' ')).toSet();
        for (final tile in model.words) {
          expect(tile.split(' ').every(taughtTokens.contains), isTrue);
        }
        expect(audio[model.translation]['native'], model.translation);
        expect(audio[model.translation]['language'], 'en-IN');
        heard.add(model.translation);
      }
      expect(heard, taught);

      final plan = File('content/scenario_groups/auto_rickshaw/plan.md')
          .readAsStringSync();
      final approvedRows = RegExp(
        r'^\| s\d{2} \|',
        multiLine: true,
      ).allMatches(plan.split('## English vocabulary inventory').first);
      expect(approvedRows, hasLength(10));
    },
  );

  test(
    'Existing quiz assets retain English-to-Hindi language defaults',
    () async {
      final questions = await quiz_loader.GameLoader.loadQuestions(
        'assets/Quizes/whatisthis_fruit_001.json',
      );
      expect(questions, isNotEmpty);
      for (final question in questions) {
        expect(question.promptLanguage, 'en');
        expect(question.targetLanguage, 'hi');
      }
    },
  );

  test(
    'Playback awaits mappings, speaks English, and restores Hindi defaults',
    () async {
      final service = PronunciationService();
      addTearDown(service.audioPlayer.dispose);
      for (final key in [
        'hi_en_auto_rickshaw_station',
        'railway station',
        'market',
        'cash',
        'auto rickshaw',
        'apple',
        'unmapped Hindi fallback',
      ]) {
        await service.playPronunciation(key);
      }
      expect(
        ttsCalls
            .where((call) => call.method == 'setLanguage')
            .map((call) => call.arguments),
        ['en-IN', 'en-IN', 'en-IN', 'en-IN', 'en-IN', 'hi-IN', 'hi-IN'],
      );
      expect(
        ttsCalls
            .where((call) => call.method == 'speak')
            .map((call) => (call.arguments as Map)['text']),
        [
          'railway station',
          'railway station',
          'market',
          'cash',
          'auto rickshaw',
          'सेब',
          'unmapped Hindi fallback',
        ],
      );
    },
  );

  testWidgets('New SVGs decode using the actual Flutter SVG renderer', (
    tester,
  ) async {
    for (final asset in [
      'auto-rickshaw.svg',
      'station.svg',
      'market-supermarket.svg',
      'money.svg',
    ]) {
      final loader = SvgAssetLoader('assets/svg_assets/$asset');
      final bytes = await tester.runAsync(() => loader.loadBytes(null));
      expect(bytes!.lengthInBytes, greaterThan(0));
    }
  });

  testWidgets('Level 1 opens from picker and completes all six activities', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LevelLoader(
          mascot: const SizedBox.shrink(),
          levelBuilder: (level, onCompleted) =>
              LevelPage(assetPath: level.assetPath, onCompleted: onCompleted),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scenario = find.byKey(const ValueKey('scenario-hi-en-auto-rickshaw'));
    await tester.ensureVisible(scenario);
    await tester.tap(scenario);
    await tester.pumpAndSettle();
    expect(find.text('Step 1/6'), findsOneWidget);
    expect(find.byType(WordMatchPage), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.byKey(ValueKey('left-$i')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('right-$i')));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      final view = tester.widget<QuestionView>(find.byType(QuestionView));
      expect(view.promptLanguage, 'hi');
      expect(view.targetLanguage, 'en');
      final answer = find.byWidgetPredicate(
        (widget) => widget is ChoiceButton && widget.choice.correct,
      );
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pumpAndSettle();
      await tester.tap(find.text(i == 3 ? 'Finish' : 'Continue'));
      await tester.pumpAndSettle();
    }
    for (var i = 3; i <= 6; i++) {
      expect(find.text('Step $i/6'), findsOneWidget);
      expect(find.byType(fts), findsOneWidget);
      final model = await tester.runAsync(
        () => sentence_loader.GameLoader.loadMTSModel(
          'assets/make_the_sentence/hi_en_auto_rickshaw_a0$i.json',
        ),
      );
      await tester.tap(find.byTooltip('Play sound'));
      await tester.pumpAndSettle();
      for (final index in model!.index) {
        await tester.tap(
          find.widgetWithText(OutlinedButton, model.words[index]).last,
        );
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Level complete!'), findsOneWidget);
    expect(find.text('You scored 12 out of 12'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('1 / 1 complete'), findsOneWidget);
    expect(find.text('0 / 10 complete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
