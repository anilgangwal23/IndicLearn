import 'dart:math';

/// Mascots with a `mouth` group, so they can animate while audio plays.
const speakingMascotAssets = <String>[
  'assets/mascots/fox.svg',
  'assets/mascots/sprout.svg',
  'assets/mascots/parrot.svg',
  'assets/mascots/grim_reaper.svg',
  'assets/mascots/reaper.svg',
  'assets/mascots/monkey_king.svg',
  'assets/mascots/saint.svg',
  'assets/mascots/satan.svg',
  'assets/mascots/zeus.svg',
];

const defaultMascotAsset = 'assets/mascots/parrot.svg';

final _random = Random();

String pickSpeakingMascot() =>
    speakingMascotAssets[_random.nextInt(speakingMascotAssets.length)];
