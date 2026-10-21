class ScenarioProgress {
  ScenarioProgress({
    required this.scenarioId,
    required Set<String> completedLevelIds,
  }) : completedLevelIds = Set.unmodifiable(completedLevelIds);

  final String scenarioId;
  final Set<String> completedLevelIds;
}

class ProgressSnapshot {
  ProgressSnapshot({
    required Map<String, ScenarioProgress> scenarios,
    required this.hasPendingWrites,
    required this.isFromCache,
  }) : scenarios = Map.unmodifiable(scenarios);

  final Map<String, ScenarioProgress> scenarios;
  final bool hasPendingWrites;
  final bool isFromCache;
}

abstract class ProgressRepository {
  Stream<ProgressSnapshot> watch(String userId);

  /// Completes when the server acknowledges the write.
  Future<void> completeLevel({
    required String userId,
    required String scenarioId,
    required String levelId,
  });
}
