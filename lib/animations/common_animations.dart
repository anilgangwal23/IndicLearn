import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../ui/svg_mascot.dart';

@Preview()
Widget PreviewForLopping() {
  return CommonAnimation(
    'packages/indic_learn/assets/mascots/fox.svg',
    MascotAnimation.blink,
  );
}

class CommonAnimation extends StatefulWidget {
  const CommonAnimation(
    this.asset,
    this.animation, {
    super.key,
    this.interval = const Duration(seconds: 3),
  }) : assert(interval > Duration.zero);

  final String asset;
  final MascotAnimation animation;
  final Duration interval;

  @override
  State<CommonAnimation> createState() => _AnimationState();
}

class _AnimationState extends State<CommonAnimation> {
  final _mascotKey = GlobalKey<SvgMascotState>();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startLoop();
    });
  }

  void _play() {
    _mascotKey.currentState?.play(widget.animation);
  }

  void _startLoop() {
    _timer?.cancel();
    _play();
    _timer = Timer.periodic(widget.interval, (_) => _play());
  }

  @override
  void didUpdateWidget(covariant CommonAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation ||
        oldWidget.interval != widget.interval ||
        oldWidget.asset != widget.asset) {
      _timer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _startLoop();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgMascot(
        key: _mascotKey,
        asset: widget.asset,
        width: 130,
        height: 130,
      ),
    );
  }
}