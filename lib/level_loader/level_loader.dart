import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../levels/level.dart';
import '../widgets/svg_mascot.dart';

class LevelDefinition {
  const LevelDefinition({
    required this.title,
    required this.assetPath,
    this.unlocked = false,
  });

  final String title;
  final String assetPath;
  final bool unlocked;
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
  }
}

class LevelLoader extends StatefulWidget {
  const LevelLoader({
    super.key,
    this.onOpenProfile,
    this.accountActionLabel = 'Your profile',
    this.scenarios = const [
      ScenarioDefinition(
        id: 'everyday-practice',
        title: 'Everyday practice',
        levels: [
      LevelDefinition(
        title: 'First words',
        assetPath: 'assets/levels/level_1.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Fruit basket',
        assetPath: 'assets/levels/level_2.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'At home',
        assetPath: 'assets/levels/level_3.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Everyday words',
        assetPath: 'assets/levels/level_4.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Build a sentence',
        assetPath: 'assets/levels/level_5.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Listen closely',
        assetPath: 'assets/levels/level_6.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Mango market',
        assetPath: 'assets/levels/level_7.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Water break',
        assetPath: 'assets/levels/level_8.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Pineapple practice',
        assetPath: 'assets/levels/level_9.json',
        unlocked: true,
      ),
      LevelDefinition(
        title: 'Mixed challenge',
        assetPath: 'assets/levels/level_10.json',
        unlocked: true,
      ),
        ],
      ),
    ],
    this.mascotAsset = 'assets/mascots/sprout.svg',
    this.mascot,
    this.levelBuilder,
  });

  final List<ScenarioDefinition> scenarios;
  final String mascotAsset;
  final Widget? mascot;
  final Widget Function(LevelDefinition level, VoidCallback onCompleted)?
      levelBuilder;
  final VoidCallback? onOpenProfile;
  final String accountActionLabel;

  @override
  State<LevelLoader> createState() => _LevelLoaderState();
}

class _LevelLoaderState extends State<LevelLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travel;
  late int _selected;
  late int _from;
  bool _opening = false;
  final Map<String, int> _completed = {};

  int _completedLevels(ScenarioDefinition scenario) =>
      (_completed[scenario.id] ?? scenario.completedLevels)
          .clamp(0, scenario.levels.length);

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
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => widget.levelBuilder?.call(level, onCompleted) ??
              LevelPage(
                assetPath: level.assetPath,
                mascotAsset: widget.mascotAsset,
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
          if (widget.onOpenProfile != null)
            IconButton(
              tooltip: widget.accountActionLabel,
              onPressed: widget.onOpenProfile,
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
                                              style: Theme.of(context).textTheme.bodySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (_selected >= 0)
                                      AnimatedBuilder(
                                        animation: _travel,
                                        child: IgnorePointer(
                                          child: widget.mascot ??
                                              SvgMascot(
                                                asset: widget.mascotAsset,
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
