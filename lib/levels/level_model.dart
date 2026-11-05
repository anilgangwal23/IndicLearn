class LevelStep {
  final String type;
  final String assetPath;
  final String handler;
  final Map<String, dynamic> config;

  const LevelStep(this.type, this.assetPath, this.handler, [this.config = const {}]);

  factory LevelStep.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final data = json['data'];
    // if (type != 'quiz' && type != 'match_the_pair') {
    //   throw FormatException('Unsupported step type: $type');
    // }
    if (data is! String || data.isEmpty) {
      throw const FormatException('Step data must be an asset path.');
    }
    final handler = json['handler'];
    if (handler is! String || handler.isEmpty) {
      throw const FormatException('Step handler must be specified.');
    }
    final config = json['config'];
    if (config != null && config is! Map<String, dynamic>) {
      throw const FormatException('Step config must be an object.');
    }
    return LevelStep(
      type as String,
      data,
      handler,
      (config as Map<String, dynamic>?) ?? const {},
    );
  }
}