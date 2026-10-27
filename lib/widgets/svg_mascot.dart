import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_localizations.dart';
import 'svg_mascot_parser.dart';

enum MascotAnimation {
  spin,
  jump,
  raiseHands,
  blink,
  yawn,
  raiseEyebrows,
}

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
              final t = Curves.easeInOut.transform(_controller.value);
              final rawT = _controller.value;
              final animation = _activeAnimation;

              var jumpY = 0.0;
              var spinAngle = 0.0;
              var leftArmAngle = 0.0;
              var rightArmAngle = 0.0;
              var leftEyeScale = 1.0;
              var rightEyeScale = 1.0;
              var eyebrowY = 0.0;
              var mouthOpen = 0.0;

              switch (animation) {
                case MascotAnimation.spin:
                  spinAngle = 2 * math.pi * t;
                  break;
                case MascotAnimation.jump:
                  jumpY = -55 * math.sin(math.pi * t);
                  break;
                case MascotAnimation.raiseHands:
                  leftArmAngle = 1.55 * t;
                  rightArmAngle = -1.55 * t;
                  break;
                case MascotAnimation.blink:
                  // Close quickly, then reopen during one short animation.
                  final close = (rawT < 0.45)
                      ? Curves.easeIn.transform(rawT / 0.45)
                      : Curves.easeOut.transform((1 - rawT) / 0.55);
                  final scale = 1 - 0.94 * close;
                  leftEyeScale = scale;
                  rightEyeScale = scale;
                  break;
                case MascotAnimation.raiseEyebrows:
                  eyebrowY = -14 * t;
                  break;
                case MascotAnimation.yawn:
                  mouthOpen = math.sin(math.pi * t);
                  leftEyeScale = 1 - 0.7 * mouthOpen;
                  rightEyeScale = leftEyeScale;
                  leftArmAngle = 0.4 * mouthOpen;
                  rightArmAngle = -0.4 * mouthOpen;
                  break;
                case null:
                  break;
              }

              final layers = snapshot.data!;
              return ClipRect(
                child: Transform.translate(
                  offset: Offset(0, jumpY),
                  child: Transform.rotate(
                    angle: spinAngle,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        for (final layer in layers)
                          _buildLayer(
                            layer,
                            leftArmAngle: leftArmAngle,
                            rightArmAngle: rightArmAngle,
                            leftEyeScale: leftEyeScale,
                            rightEyeScale: rightEyeScale,
                            eyebrowY: eyebrowY,
                            mouthOpen: mouthOpen,
                          ),
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

  Widget _buildLayer(
    SvgMascotLayer layer, {
    required double leftArmAngle,
    required double rightArmAngle,
    required double leftEyeScale,
    required double rightEyeScale,
    required double eyebrowY,
    required double mouthOpen,
  }) {
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
          scaleX: 1 - 0.25 * mouthOpen,
          scaleY: 1 + 4 * mouthOpen,
          alignment: pivot(150, 145),
          child: child,
        );
        break;
      case 'left_hand':
        child = Transform.rotate(
          angle: leftArmAngle,
          alignment: pivot(77, 166),
          child: child,
        );
        break;
      case 'right_hand':
        child = Transform.rotate(
          angle: rightArmAngle,
          alignment: pivot(223, 166),
          child: child,
        );
        break;
      case 'left_eye':
        child = Transform.scale(
          scaleY: leftEyeScale,
          alignment: pivot(120, 111),
          child: child,
        );
        break;
      case 'right_eye':
        child = Transform.scale(
          scaleY: rightEyeScale,
          alignment: pivot(180, 111),
          child: child,
        );
        break;
      case 'left_eyebrow':
      case 'right_eyebrow':
        child = Transform.translate(
          offset: Offset(0, eyebrowY),
          child: child,
        );
        break;
    }

    return Positioned.fill(child: child);
  }
}
