import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indic_learn/level_loader/level_loader.dart';
import 'package:indic_learn/level_loader/scenario_catalog.dart';

Map<String, dynamic> _scenario({String id = 'from-json'}) => {
  'id': id,
  'title': 'Scenario from JSON',
  'unlocked': true,
  'levels': [
    {
      'id': 'first',
      'title': 'First lesson from JSON',
      'assetPath': 'assets/levels/first.json',
      'unlocked': true,
    },
    {
      'id': 'second',
      'title': 'Second lesson from JSON',
      'assetPath': 'assets/levels/second.json',
      'unlocked': false,
    },
  ],
};

void main() {
  test(
    'Scenario JSON generates ordered levels with stable IDs and metadata',
    () {
      final scenario = ScenarioDefinition.fromJson(_scenario());
      expect(scenario.id, 'from-json');
      expect(scenario.title, 'Scenario from JSON');
      expect(scenario.unlocked, isTrue);
      expect(scenario.completedLevels, 0);
      expect(scenario.levels.map((level) => level.progressId), [
        'first',
        'second',
      ]);
      expect(scenario.levels.last.assetPath, 'assets/levels/second.json');
      expect(scenario.levels.last.unlocked, isFalse);
      expect(() => scenario.levels.clear(), throwsUnsupportedError);
    },
  );

  test(
    'Malformed scenario metadata is rejected rather than partially loaded',
    () {
      final firstLevel = (_scenario()['levels'] as List).first;
      final invalid = <Map<String, dynamic>>[
        {..._scenario(), 'id': ''},
        {..._scenario(), 'title': 42},
        {..._scenario(), 'unlocked': 'true'},
        {..._scenario(), 'levels': null},
        {..._scenario(), 'levels': []},
        {
          ..._scenario(),
          'levels': [42],
        },
        {..._scenario(), 'levels': List.filled(13, firstLevel)},
        {
          ..._scenario(),
          'levels': [firstLevel, firstLevel],
        },
        {
          ..._scenario(),
          'levels': [
            {'title': 'Missing ID', 'assetPath': 'lesson.json'},
          ],
        },
        {
          ..._scenario(),
          'levels': [
            {'id': 'bad/id', 'title': 'Bad ID', 'assetPath': 'lesson.json'},
          ],
        },
        {
          ..._scenario(),
          'levels': [
            {'id': 'valid', 'title': 'Missing path', 'assetPath': null},
          ],
        },
      ];
      for (final json in invalid) {
        expect(() => ScenarioDefinition.fromJson(json), throwsFormatException);
      }
    },
  );

  test(
    'Catalog loads scenario files in catalog order and rejects duplicate IDs',
    () async {
      final bundle = _CatalogBundle({
        ScenarioCatalog.defaultAsset: jsonEncode({
          'schemaVersion': 1,
          'scenarios': ['second.json', 'first.json'],
        }),
        'first.json': jsonEncode(_scenario(id: 'first')),
        'second.json': jsonEncode(_scenario(id: 'second')),
      });
      final scenarios = await ScenarioCatalog.load(bundle);
      expect(scenarios.map((scenario) => scenario.id), ['second', 'first']);
      expect(() => scenarios.clear(), throwsUnsupportedError);
      bundle.assets['first.json'] = jsonEncode(_scenario(id: 'second'));
      await expectLater(ScenarioCatalog.load(bundle), throwsFormatException);
    },
  );

  test('Catalog rejects invalid schemas, paths, and scenario files', () async {
    for (final json in [
      'invalid json',
      '[]',
      '{"schemaVersion":2,"scenarios":[]}',
      '{"schemaVersion":1,"scenarios":{}}',
      '{"schemaVersion":1,"scenarios":["missing.json",42]}',
    ]) {
      final bundle = _CatalogBundle({ScenarioCatalog.defaultAsset: json});
      await expectLater(ScenarioCatalog.load(bundle), throwsFormatException);
    }
    final bundle = _CatalogBundle({
      ScenarioCatalog.defaultAsset:
          '{"schemaVersion":1,"scenarios":["scenario.json"]}',
      'scenario.json': '[]',
    });
    await expectLater(ScenarioCatalog.load(bundle), throwsFormatException);
    bundle.assets.remove('scenario.json');
    await expectLater(
      ScenarioCatalog.load(bundle),
      throwsA(isA<FlutterError>()),
    );
    bundle.assets[ScenarioCatalog.defaultAsset] =
        '{"schemaVersion":1,"scenarios":[]}';
    expect(await ScenarioCatalog.load(bundle), isEmpty);
  });

  testWidgets(
    'JSON catalog restores progress and reports stable completion IDs',
    (tester) async {
      final bundle = _CatalogBundle({
        ScenarioCatalog.defaultAsset:
            '{"schemaVersion":1,"scenarios":["scenario.json"]}',
        'scenario.json': jsonEncode(_scenario()),
      });
      final completions = <String>[];
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: bundle,
          child: MaterialApp(
            home: LevelLoader(
              mascot: const SizedBox.square(dimension: 96),
              completedLevelIds: const {
                'from-json': {'first'},
              },
              onLevelCompleted:
                  ({required scenarioId, required levelId}) async {
                    completions.add('$scenarioId/$levelId');
                  },
              levelBuilder: (level, onCompleted) => Scaffold(
                appBar: AppBar(title: Text(level.title)),
                body: TextButton(
                  onPressed: onCompleted,
                  child: const Text('Finish'),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Scenario from JSON'), findsOneWidget);
      expect(find.text('1 / 2 complete'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('scenario-from-json')));
      await tester.pumpAndSettle();
      expect(find.text('Second lesson from JSON'), findsOneWidget);
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();
      expect(completions, ['from-json/second']);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('2 / 2 complete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Missing catalog shows Retry and can recover', (tester) async {
    final bundle = _CatalogBundle({});
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: bundle,
        child: const MaterialApp(
          home: LevelLoader(mascot: SizedBox.square(dimension: 96)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your scenarios could not be loaded.'), findsOneWidget);
    expect(find.text('No scenarios available'), findsNothing);
    bundle.assets[ScenarioCatalog.defaultAsset] =
        '{"schemaVersion":1,"scenarios":["scenario.json"]}';
    bundle.assets['scenario.json'] = jsonEncode(_scenario());
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Scenario from JSON'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Changing catalog assets reloads without stale scenario data', (
    tester,
  ) async {
    final bundle = _CatalogBundle({
      'first-catalog.json':
          '{"schemaVersion":1,"scenarios":["first-scenario.json"]}',
      'second-catalog.json':
          '{"schemaVersion":1,"scenarios":["second-scenario.json"]}',
      'first-scenario.json': jsonEncode({
        ..._scenario(id: 'first-scenario'),
        'title': 'First catalog',
      }),
      'second-scenario.json': jsonEncode({
        ..._scenario(id: 'second-scenario'),
        'title': 'Second catalog',
      }),
    });
    Widget app(String path) => DefaultAssetBundle(
      bundle: bundle,
      child: MaterialApp(
        home: LevelLoader(
          catalogAsset: path,
          mascot: const SizedBox.square(dimension: 96),
        ),
      ),
    );
    await tester.pumpWidget(app('first-catalog.json'));
    await tester.pumpAndSettle();
    expect(find.text('First catalog'), findsOneWidget);
    await tester.pumpWidget(app('second-catalog.json'));
    await tester.pumpAndSettle();
    expect(find.text('First catalog'), findsNothing);
    expect(find.text('Second catalog'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _CatalogBundle extends CachingAssetBundle {
  _CatalogBundle(this.assets);

  final Map<String, String> assets;

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = assets[key];
    if (value == null) throw FlutterError('Missing test asset: $key');
    return value;
  }

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(utf8.encode(await loadString(key)));
}
