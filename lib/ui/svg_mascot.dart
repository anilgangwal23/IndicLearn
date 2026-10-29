import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../animations/mascot_motions.dart';
import '../l10n/app_localizations.dart';
import 'svg_mascot_parser.dart';

export '../animations/mascot_motions.dart';

class SvgMascot extends StatefulWidget {
  const SvgMascot({
    super.key,
    required this.asset,
    this.width = 240,
    this.height = 240,
    this.autoBlink = false,
    this.autoIdle = false,
    this.onAssetError,
  });

  final String asset;
  final double width;
  final double height;

  /// When true, plays a blink every few seconds.
  /// Manual blinking remains available through [SvgMascotState.play].
  final bool autoBlink;
  final bool autoIdle;

  final ValueChanged<Object>? onAssetError;

  @override
  State<SvgMascot> createState() => SvgMascotState();
}

class SvgMascotState extends State<SvgMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Future<List<SvgMascotLayer>> _layersFuture;

  MascotAnimation? _activeAnimation;
  Timer? _idleTimer;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _layersFuture = _loadLayers();
    _scheduleIdle();
  }

  @override
  void didUpdateWidget(covariant SvgMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) {
      _layersFuture = _loadLayers();
    }
    if (oldWidget.autoIdle != widget.autoIdle ||
        oldWidget.autoBlink != widget.autoBlink) {
      _scheduleIdle();
    }
  }

  void _scheduleIdle() {
    _idleTimer?.cancel();
    if (!widget.autoIdle && !widget.autoBlink) return;
    _idleTimer = Timer(Duration(seconds: 3 + _random.nextInt(5)), () {
      if (!mounted) return;
      if (!_controller.isAnimating && TickerMode.valuesOf(context).enabled &&
          !MediaQuery.disableAnimationsOf(context)) {
        const motions = [
          MascotAnimation.jump,
          MascotAnimation.yawn,
          MascotAnimation.blink,
        ];
        play(widget.autoIdle
            ? motions[_random.nextInt(motions.length)]
            : MascotAnimation.blink);
      }
      _scheduleIdle();
    });
  }

  Future<List<SvgMascotLayer>> _loadLayers() async {
    try {
      final source = await rootBundle.loadString(widget.asset);
      return SvgMascotParser.parse(source);
    } catch (error) {
      widget.onAssetError?.call(error);
      rethrow;
    }
  }

  /// Plays one animation. A new call replaces the currently playing motion.
  void play(MascotAnimation animation) {
    if (!mounted) return;
    setState(() => _activeAnimation = animation);
    _controller
      ..stop()
      ..reset()
      ..forward();
  }

  /// Stops the current animation and returns the mascot to its resting pose.
  void stop() {
    _controller.stop();
    _controller.reset();
    if (mounted) setState(() => _activeAnimation = null);
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FutureBuilder<List<SvgMascotLayer>>(
        future: _layersFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Tooltip(
              message: AppLocalizations.of(context)!.mascotImageLoadFailed,
                child: const Icon(Icons.broken_image_outlined),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final pose = mascotPoseFor(_activeAnimation, _controller.value);

              final layers = snapshot.data!;
              return ClipRect(
                child: Transform.translate(
                  offset: Offset(0, pose.jumpY),
                  child: Transform.rotate(
                    angle: pose.spinAngle,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        for (final layer in layers)
                          _buildLayer(layer, pose),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLayer(SvgMascotLayer layer, MascotPose pose) {
    Widget child = SvgPicture.string(
      layer.svg,
      fit: BoxFit.fill,
      width: widget.width,
      height: widget.height,
    );

    // Pivots use the agreed 300 x 300 SVG coordinate system.
    Alignment pivot(double x, double y) => Alignment(
          (2 * x / 300) - 1,
          (2 * y / 300) - 1,
        );

    switch (layer.id) {
      case 'mouth':
        child = Transform.scale(
          scaleX: 1 - 0.25 * pose.mouthOpen,
          scaleY: 1 + 4 * pose.mouthOpen,
          alignment: pivot(150, 145),
          child: child,
        );
        break;
      case 'left_hand':
        child = Transform.rotate(
          angle: pose.leftArmAngle,
          alignment: pivot(77, 166),
          child: child,
        );
        break;
      case 'right_hand':
        child = Transform.rotate(
          angle: pose.rightArmAngle,
          alignment: pivot(223, 166),
          child: child,
        );
        break;
      case 'left_eye':
        child = Transform.scale(
          scaleY: pose.leftEyeScale,
          alignment: pivot(120, 111),
          child: child,
        );
        break;
      case 'right_eye':
        child = Transform.scale(
          scaleY: pose.rightEyeScale,
          alignment: pivot(180, 111),
          child: child,
        );
        break;
      case 'left_eyebrow':
      case 'right_eyebrow':
        child = Transform.translate(
          offset: Offset(0, pose.eyebrowY),
          child: child,
        );
        break;
    }

    return Positioned.fill(child: child);
  }
}
