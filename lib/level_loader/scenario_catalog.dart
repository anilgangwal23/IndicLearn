import 'dart:convert';

import 'package:flutter/services.dart';

class LevelDefinition {
  const LevelDefinition({
    this.id,
    required this.title,
    required this.assetPath,
    this.unlocked = false,
  });

  final String? id;
  final String title;
  final String assetPath;
  final bool unlocked;

  String get progressId => id ?? assetPath;

  factory LevelDefinition.fromJson(Map<String, dynamic> json) =>
      LevelDefinition(
        id: _requiredString(json, 'id'),
        title: _requiredString(json, 'title'),
        assetPath: _requiredString(json, 'assetPath'),
        unlocked: _unlocked(json, false),
      );
}

class ScenarioDefinition {
  const ScenarioDefinition({
    required this.id,
    required this.title,
    required this.levels,
    this.unlocked = true,
    this.completedLevels = 0,
  });

  final String id;
  final String title;
  final List<LevelDefinition> levels;
  final bool unlocked;
  final int completedLevels;

  factory ScenarioDefinition.fromJson(Map<String, dynamic> json) {
    final levels = json['levels'];
    if (levels is! List) {
      throw const FormatException('Scenario levels must be a list.');
    }
    final scenario = ScenarioDefinition(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      unlocked: _unlocked(json, true),
      levels: List.unmodifiable([
        for (final level in levels)
          if (level is Map<String, dynamic>)
            LevelDefinition.fromJson(level)
          else
            throw const FormatException('Each level must be an object.'),
      ]),
    );
    try {
      scenario.validate();
    } on ArgumentError catch (error) {
      throw FormatException('Invalid scenario: ${error.message}');
    }
    return scenario;
  }

  void validate() {
    if (id.trim().isEmpty || title.trim().isEmpty) {
      throw ArgumentError('Scenarios require a nonempty ID and title.');
    }
    if (levels.isEmpty || levels.length > 12) {
      throw ArgumentError('A scenario must contain between 1 and 12 levels.');
    }
    if (completedLevels < 0 || completedLevels > levels.length) {
      throw ArgumentError('Completed levels must be within the scenario.');
    }
    final levelIds = <String>{};
    for (final level in levels) {
      if (level.progressId.trim().isEmpty ||
          level.progressId != level.progressId.trim() ||
          level.progressId.length > 128 ||
          level.progressId.contains('/') ||
          !levelIds.add(level.progressId)) {
        throw ArgumentError(
          'Scenario level progress IDs must be valid and unique.',
        );
      }
    }
  }
}

class ScenarioCatalog {
  static const defaultAsset = 'assets/scenarios/catalog.json';

  static Future<List<ScenarioDefinition>> load(
    AssetBundle bundle, {
    String assetPath = defaultAsset,
  }) async {
    final catalog = jsonDecode(await bundle.loadString(assetPath));
    if (catalog is! Map<String, dynamic> ||
        catalog['schemaVersion'] != 1 ||
        catalog['scenarios'] is! List) {
      throw const FormatException('Invalid scenario catalog.');
    }
    final assets = catalog['scenarios'] as List;
    final paths = [
      for (final asset in assets)
        if (asset is String && asset.trim().isNotEmpty)
          asset
        else
          throw const FormatException('Scenario asset paths must be strings.'),
    ];
    final scenarios = await Future.wait(
      paths.map((path) => _loadScenario(bundle, path)),
    );
    final ids = <String>{};
    for (final scenario in scenarios) {
      if (!ids.add(scenario.id)) {
        throw FormatException('Duplicate scenario ID: ${scenario.id}');
      }
    }
    return List.unmodifiable(scenarios);
  }

  static Future<ScenarioDefinition> _loadScenario(
    AssetBundle bundle,
    String path,
  ) async {
    final json = jsonDecode(await bundle.loadString(path));
    if (json is! Map<String, dynamic>) {
      throw FormatException('Scenario must be an object: $path');
    }
    return ScenarioDefinition.fromJson(json);
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty || value != value.trim()) {
    throw FormatException('$key must be a nonempty, trimmed string.');
  }
  return value;
}

bool _unlocked(Map<String, dynamic> json, bool defaultValue) {
  final value = json['unlocked'];
  if (!json.containsKey('unlocked')) return defaultValue;
  if (value is! bool) {
    throw const FormatException('unlocked must be a boolean.');
  }
  return value;
}
