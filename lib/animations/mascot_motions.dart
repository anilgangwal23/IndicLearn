import 'dart:math' as math;

import 'package:flutter/animation.dart';

enum MascotAnimation {
  spin,
  jump,
  raiseHands,
  blink,
  yawn,
  raiseEyebrows,
}

/// Offsets and scales applied to the mascot's SVG layers for one frame.
class MascotPose {
  const MascotPose({
    this.jumpY = 0,
    this.spinAngle = 0,
    this.leftArmAngle = 0,
    this.rightArmAngle = 0,
    this.leftEyeScale = 1,
    this.rightEyeScale = 1,
    this.eyebrowY = 0,
    this.mouthOpen = 0,
  });

  final double jumpY;
  final double spinAngle;
  final double leftArmAngle;
  final double rightArmAngle;
  final double leftEyeScale;
  final double rightEyeScale;
  final double eyebrowY;
  final double mouthOpen;
}

/// Looping speaking pose for phase [t] in 0..1 (one cycle per repeat).
/// Opens and closes the mouth while bobbing the head slightly.
MascotPose speakingPose(double t) {
  final mouthOpen = 0.5 - 0.5 * math.cos(2 * math.pi * t);
  return MascotPose(mouthOpen: mouthOpen, jumpY: -6 * mouthOpen);
}

/// Returns the pose for [animation] at controller progress [rawT] in 0..1.
/// A null [animation] yields the resting pose.
MascotPose mascotPoseFor(MascotAnimation? animation, double rawT) {
  final t = Curves.easeInOut.transform(rawT);

  switch (animation) {
    case MascotAnimation.spin:
      return MascotPose(spinAngle: 2 * math.pi * t);
    case MascotAnimation.jump:
      return MascotPose(jumpY: -55 * math.sin(math.pi * t));
    case MascotAnimation.raiseHands:
      return MascotPose(leftArmAngle: 1.55 * t, rightArmAngle: -1.55 * t);
    case MascotAnimation.blink:
      // Close quickly, then reopen during one short animation.
      final close = (rawT < 0.45)
          ? Curves.easeIn.transform(rawT / 0.45)
          : Curves.easeOut.transform((1 - rawT) / 0.55);
      final scale = 1 - 0.94 * close;
      return MascotPose(leftEyeScale: scale, rightEyeScale: scale);
    case MascotAnimation.raiseEyebrows:
      return MascotPose(eyebrowY: -14 * t);
    case MascotAnimation.yawn:
      final mouthOpen = math.sin(math.pi * t);
      final eyeScale = 1 - 0.7 * mouthOpen;
      return MascotPose(
        leftEyeScale: eyeScale,
        rightEyeScale: eyeScale,
        leftArmAngle: 0.4 * mouthOpen,
        rightArmAngle: -0.4 * mouthOpen,
        mouthOpen: mouthOpen,
      );
    case null:
      return const MascotPose();
  }
}
