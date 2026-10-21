import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indic_learn/level_loader/level_loader.dart';
import 'package:indic_learn/progress/learning_progress.dart';
import 'package:indic_learn/progress/progress_scope.dart';

void main() {
  testWidgets('restores progress and persists the next completed level', (
    tester,
  ) async {
    final repository = _ProgressRepository(
      ProgressSnapshot(
        scenarios: {
          'practice': ScenarioProgress(
            scenarioId: 'practice',
            completedLevelIds: {'level-one'},
          ),
        },
        hasPendingWrites: false,
        isFromCache: false,
      ),
    );
    addTearDown(repository.close);

    await tester.pumpWidget(
      MaterialApp(
        home: ProgressScope(
          userId: 'test-user',
          repository: repository,
          builder: (context, progress, completeLevel) => LevelLoader(
            mascot: const SizedBox.square(dimension: 96),
            scenarios: const [
              ScenarioDefinition(
                id: 'practice',
                title: 'Practice',
                levels: [
                  LevelDefinition(
                    id: 'level-one',
                    title: 'First',
                    assetPath: 'first.json',
                  ),
                  LevelDefinition(
                    id: 'level-two',
                    title: 'Second',
                    assetPath: 'second.json',
                  ),
                ],
              ),
            ],
            completedLevelIds: {
              for (final entry in progress.scenarios.entries)
                entry.key: entry.value.completedLevelIds,
            },
            onLevelCompleted: completeLevel,
            levelBuilder: (level, onCompleted) =>
                _FakeLesson(level: level, onCompleted: onCompleted),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 2 complete'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scenario-practice')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<_FakeLesson>(find.byType(_FakeLesson)).level.id,
      'level-two',
    );

    await tester.tap(find.text('Complete lesson'));
    await tester.pumpAndSettle();
    expect(repository.savedUserId, 'test-user');
    expect(repository.savedScenarioId, 'practice');
    expect(repository.savedLevelId, 'level-two');
    await tester.tap(find.byType(BackButton).first);
    await tester.pumpAndSettle();
    expect(find.text('2 / 2 complete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _ProgressRepository implements ProgressRepository {
  _ProgressRepository(this._snapshot);

  final StreamController<ProgressSnapshot> _changes =
      StreamController<ProgressSnapshot>();
  ProgressSnapshot _snapshot;
  String? savedUserId;
  String? savedScenarioId;
  String? savedLevelId;

  @override
  Stream<ProgressSnapshot> watch(String userId) async* {
    yield _snapshot;
    yield* _changes.stream;
  }

  @override
  Future<void> completeLevel({
    required String userId,
    required String scenarioId,
    required String levelId,
  }) async {
    savedUserId = userId;
    savedScenarioId = scenarioId;
    savedLevelId = levelId;
    final scenarios = Map<String, ScenarioProgress>.of(_snapshot.scenarios);
    final completed = {...?scenarios[scenarioId]?.completedLevelIds, levelId};
    scenarios[scenarioId] = ScenarioProgress(
      scenarioId: scenarioId,
      completedLevelIds: completed,
    );
    _snapshot = ProgressSnapshot(
      scenarios: scenarios,
      hasPendingWrites: false,
      isFromCache: false,
    );
    _changes.add(_snapshot);
  }

  Future<void> close() => _changes.close();
}

class _FakeLesson extends StatelessWidget {
  const _FakeLesson({required this.level, required this.onCompleted});

  final LevelDefinition level;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: Center(
      child: Column(
        children: [
          Text(level.title),
          TextButton(
            onPressed: onCompleted,
            child: const Text('Complete lesson'),
          ),
        ],
      ),
    ),
  );
}
