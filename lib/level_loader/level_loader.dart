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

class LevelLoader extends StatefulWidget {
	const LevelLoader({
		super.key,
		this.levels = const [
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
		this.mascotAsset = 'assets/mascots/sprout.svg',
	});

	final List<LevelDefinition> levels;
	final String mascotAsset;

	@override
	State<LevelLoader> createState() => _LevelLoaderState();
}

class _LevelLoaderState extends State<LevelLoader>
		with SingleTickerProviderStateMixin {
	late final AnimationController _travel;
	late int _selected;
	late int _from;
	bool _opening = false;

	@override
	void initState() {
		super.initState();
		_selected = widget.levels.indexWhere((level) => level.unlocked);
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
		if (_opening || !widget.levels[index].unlocked) return;
		final level = widget.levels[index];
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
			await Navigator.of(context).push<void>(
				MaterialPageRoute(
					builder: (_) => LevelPage(
						assetPath: level.assetPath,
						mascotAsset: widget.mascotAsset,
					),
				),
			);
		} on TickerCanceled {
			return;
		} finally {
			if (mounted) setState(() => _opening = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		final colors = Theme.of(context).colorScheme;
		return Scaffold(
			appBar: AppBar(title: const Text('Your learning path')),
			body: SafeArea(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.stretch,
					children: [
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
							child: Text(
								'${widget.levels.where((level) => level.unlocked).length}'
								' / ${widget.levels.length} unlocked',
								style: Theme.of(context).textTheme.titleMedium,
							),
						),
						Expanded(
							child: widget.levels.isEmpty
									? const Center(child: Text('No levels available'))
									: SingleChildScrollView(
											child: Center(
												child: ConstrainedBox(
													constraints: const BoxConstraints(maxWidth: 480),
													child: LayoutBuilder(
														builder: (context, constraints) {
															final width = constraints.maxWidth;
															return SizedBox(
																height: widget.levels.length * 160.0 + 80,
																child: Stack(
																	children: [
																		Positioned.fill(
																			child: CustomPaint(
																				painter: _LevelPathPainter(
																					points: [
																						for (var index = 0;
																								index < widget.levels.length;
																								index++)
																							_position(index, width),
																					],
																					color: colors.outlineVariant,
																				),
																			),
																		),
																		for (var index = 0;
																				index < widget.levels.length;
																				index++)
																			Positioned(
																				left: _position(index, width).dx - 70,
																				top: _position(index, width).dy - 30,
																				width: 140,
																				child: Column(
																					children: [
																						SizedBox(
																							width: 64,
																							height: 64,
																							child: FilledButton(
																								key: ValueKey('level-$index'),
																								style: FilledButton.styleFrom(
																									padding: EdgeInsets.zero,
																									shape: const CircleBorder(),
																								),
																								onPressed: !_opening &&
																												widget.levels[index]
																														.unlocked
																										? () => _openLevel(index)
																										: null,
																								child: Semantics(
																									label: 'Level ${index + 1}, '
																											'${widget.levels[index].title}',
																									child: widget.levels[index]
																													.unlocked
																											? Text('${index + 1}')
																											: const Icon(
																													Icons.lock_outline,
																												),
																								),
																							),
																						),
																						const SizedBox(height: 8),
																						Text(
																							widget.levels[index].title,
																							textAlign: TextAlign.center,
																						),
																					],
																				),
																			),
																		if (_selected >= 0)
																			AnimatedBuilder(
																				animation: _travel,
																				child: IgnorePointer(
																					child: SvgMascot(
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
																						Curves.easeInOut.transform(progress),
																					)!;
																					return Positioned(
																						left: position.dx - 48,
																						top: position.dy - 110 -
																								48 * math.sin(math.pi * progress),
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
				previous.dx, middle, current.dx, middle, current.dx, current.dy,
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
