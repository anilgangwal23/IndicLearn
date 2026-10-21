import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../levels/level.dart';
import '../widgets/svg_mascot.dart';
import 'scenario_catalog.dart';

export 'scenario_catalog.dart' show LevelDefinition, ScenarioDefinition;

class LevelLoader extends StatefulWidget {
  const LevelLoader({
    super.key,
    this.onOpenProfile,
    this.accountActionLabel = 'Your profile',
    this.scenarios,
    this.catalogAsset = ScenarioCatalog.defaultAsset,
    this.mascotAsset = 'assets/mascots/sprout.svg',
    this.mascot,
    this.levelBuilder,
    this.completedLevelIds,
    this.onLevelCompleted,
    this.progressHasPendingWrites = false,
    this.progressIsFromCache = false,
  });

  final List<ScenarioDefinition>? scenarios;
  final String catalogAsset;
  final String mascotAsset;
  final Widget? mascot;
  final Widget Function(LevelDefinition level, VoidCallback onCompleted)?
  levelBuilder;
  final Map<String, Set<String>>? completedLevelIds;
  final Future<void> Function({
    required String scenarioId,
    required String levelId,
  })?
  onLevelCompleted;
  final bool progressHasPendingWrites;
  final bool progressIsFromCache;
  final VoidCallback? onOpenProfile;
  final String accountActionLabel;

  @override
  State<LevelLoader> createState() => _LevelLoaderState();
}

class _LevelLoaderState extends State<LevelLoader> {
  AssetBundle? _bundle;
  Future<List<ScenarioDefinition>>? _catalog;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bundle = DefaultAssetBundle.of(context);
    if (_bundle != bundle) {
      _bundle = bundle;
      if (widget.scenarios == null) _loadCatalog();
    }
  }

  @override
  void didUpdateWidget(covariant LevelLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scenarios == null &&
        (oldWidget.scenarios != null ||
            oldWidget.catalogAsset != widget.catalogAsset)) {
      _loadCatalog();
    }
  }

  void _loadCatalog() {
    _catalog = ScenarioCatalog.load(_bundle!, assetPath: widget.catalogAsset);
  }

  @override
  Widget build(BuildContext context) {
    final scenarios = widget.scenarios;
    if (scenarios != null) {
      return _ScenarioPicker(configuration: widget, scenarios: scenarios);
    }
    return FutureBuilder<List<ScenarioDefinition>>(
      future: _catalog,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Your scenarios')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Your scenarios could not be loaded.'),
                  ),
                  FilledButton.icon(
                    onPressed: () => setState(_loadCatalog),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        return _ScenarioPicker(
          configuration: widget,
          scenarios: snapshot.requireData,
        );
      },
    );
  }
}

class _ScenarioPicker extends StatefulWidget {
  const _ScenarioPicker({required this.configuration, required this.scenarios});

  final LevelLoader configuration;
  final List<ScenarioDefinition> scenarios;

  @override
  State<_ScenarioPicker> createState() => _ScenarioPickerState();
}

class _ScenarioPickerState extends State<_ScenarioPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travel;
  late int _selected;
  late int _from;
  bool _opening = false;
  final Map<String, int> _completed = {};

  int _completedLevels(ScenarioDefinition scenario) {
    final storedIds = widget.configuration.completedLevelIds?[scenario.id];
    var completed = scenario.completedLevels;
    if (widget.configuration.completedLevelIds != null) {
      completed = 0;
      for (final level in scenario.levels) {
        if (storedIds?.contains(level.progressId) != true) break;
        completed++;
      }
    }
    return math
        .max(completed, _completed[scenario.id] ?? 0)
        .clamp(0, scenario.levels.length);
  }

  void _validateScenarios() {
    final ids = <String>{};
    for (final scenario in widget.scenarios) {
      scenario.validate();
      if (!ids.add(scenario.id)) {
        throw ArgumentError('Scenario IDs must be unique: ${scenario.id}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _validateScenarios();
    _selected = widget.scenarios.indexWhere((scenario) => scenario.unlocked);
    _from = _selected;
    _travel = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
      value: 1,
    );
  }

  @override
  void dispose() {
    _travel.dispose();
    super.dispose();
  }

  Offset _position(int index, double width) =>
      Offset(width * (index.isEven ? 0.3 : 0.7), 126 + index * 160.0);

  Future<void> _openLevel(int index) async {
    if (_opening || !widget.scenarios[index].unlocked) return;
    final scenario = widget.scenarios[index];
    final levelIndex = _completedLevels(scenario)
        .clamp(0, scenario.levels.length - 1);
    final level = scenario.levels[levelIndex];
    setState(() {
      _opening = true;
      _from = _selected;
      _selected = index;
    });
    try {
      if (!MediaQuery.disableAnimationsOf(context)) {
        await _travel.forward(from: 0).orCancel;
      } else {
        _travel.value = 1;
      }
      if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
      void onCompleted() {
        if (!mounted || _completedLevels(scenario) != levelIndex) return;
        setState(() => _completed[scenario.id] = levelIndex + 1);
        final persist = widget.configuration.onLevelCompleted;
        if (persist != null) {
          unawaited(_persistCompletion(persist, scenario.id, level.progressId));
        }
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) =>
              widget.configuration.levelBuilder?.call(level, onCompleted) ??
              LevelPage(
                assetPath: level.assetPath,
                mascotAsset: widget.configuration.mascotAsset,
                onCompleted: onCompleted,
              ),
        ),
      );
    } on TickerCanceled {
      return;
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _persistCompletion(
    Future<void> Function({required String scenarioId, required String levelId})
    persist,
    String scenarioId,
    String levelId,
  ) async {
    try {
      await persist(scenarioId: scenarioId, levelId: levelId);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Progress was not saved. Check your connection.'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              unawaited(_persistCompletion(persist, scenarioId, levelId));
            },
          ),
        ),
      );
    }
  }

  Widget _buildScenarioHop(int index, ColorScheme colors) {
    final scenario = widget.scenarios[index];
    final completed = _completedLevels(scenario);
    final finished = completed == scenario.levels.length;
    final label = !scenario.unlocked
        ? '${scenario.title}, locked'
        : finished
        ? '${scenario.title}, complete. Replay final level'
        : '${scenario.title}, $completed of ${scenario.levels.length} complete. '
              'Continue level ${completed + 1}';
    return Semantics(
      label: label,
      button: true,
      enabled: scenario.unlocked && !_opening,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: SizedBox.square(
          dimension: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CircularProgressIndicator(
                  key: ValueKey('scenario-progress-${scenario.id}'),
                  value: completed / scenario.levels.length,
                  strokeWidth: 4,
                  backgroundColor: colors.outlineVariant,
                  color: colors.primary,
                ),
              ),
              SizedBox.square(
                dimension: 64,
                child: FilledButton(
                  key: ValueKey('scenario-${scenario.id}'),
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: const CircleBorder(),
                  ),
                  onPressed: scenario.unlocked && !_opening
                      ? () => _openLevel(index)
                      : null,
                  child: Icon(
                    !scenario.unlocked
                        ? Icons.lock_outline
                        : finished
                        ? Icons.check
                        : Icons.route_outlined,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your scenarios'),
        actions: [
          if (widget.configuration.onOpenProfile != null)
            IconButton(
              tooltip: widget.configuration.accountActionLabel,
              onPressed: widget.configuration.onOpenProfile,
              icon: const Icon(Icons.account_circle_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                '${widget.scenarios.where((scenario) => scenario.unlocked).length}'
                ' / ${widget.scenarios.length} scenarios unlocked',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (widget.configuration.progressHasPendingWrites ||
                widget.configuration.progressIsFromCache)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  widget.configuration.progressHasPendingWrites
                      ? 'Saving progress…'
                      : 'Showing locally cached progress',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Expanded(
              child: widget.scenarios.isEmpty
                  ? const Center(child: Text('No scenarios available'))
                  : SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              return SizedBox(
                                height: widget.scenarios.length * 160.0 + 80,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: _LevelPathPainter(
                                          points: [
                                            for (
                                              var index = 0;
                                              index < widget.scenarios.length;
                                              index++
                                            )
                                              _position(index, width),
                                          ],
                                          color: colors.outlineVariant,
                                        ),
                                      ),
                                    ),
                                    for (
                                      var index = 0;
                                      index < widget.scenarios.length;
                                      index++
                                    )
                                      Positioned(
                                        left: _position(index, width).dx - 70,
                                        top: _position(index, width).dy - 30,
                                        width: 140,
                                        child: Column(
                                          children: [
                                            _buildScenarioHop(index, colors),
                                            const SizedBox(height: 8),
                                            Text(
                                              widget.scenarios[index].title,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_completedLevels(widget.scenarios[index])}'
                                              ' / ${widget.scenarios[index].levels.length}'
                                              ' complete',
                                              textAlign: TextAlign.center,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_selected >= 0)
                                      AnimatedBuilder(
                                        animation: _travel,
                                        child: IgnorePointer(
                                          child:
                                              widget.configuration.mascot ??
                                              SvgMascot(
                                                asset: widget
                                                    .configuration
                                                    .mascotAsset,
                                                width: 96,
                                                height: 96,
                                                autoIdle: !_opening,
                                              ),
                                        ),
                                        builder: (context, child) {
                                          final progress = _travel.value;
                                          final position = Offset.lerp(
                                            _position(_from, width),
                                            _position(_selected, width),
                                            Curves.easeInOut.transform(
                                              progress,
                                            ),
                                          )!;
                                          return Positioned(
                                            left: position.dx - 48,
                                            top:
                                                position.dy -
                                                110 -
                                                48 *
                                                    math.sin(
                                                      math.pi * progress,
                                                    ),
                                            child: child!,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelPathPainter extends CustomPainter {
  const _LevelPathPainter({required this.points, required this.color});

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var index = 1; index < points.length; index++) {
      final previous = points[index - 1];
      final current = points[index];
      final middle = (previous.dy + current.dy) / 2;
      path.cubicTo(
        previous.dx,
        middle,
        current.dx,
        middle,
        current.dx,
        current.dy,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LevelPathPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.points != points;
}
