# indic_learn

A new Flutter project.

## Accounts

Firebase Auth provides email/password, phone/SMS, Google, and Apple sign-in;
Firestore stores user-owned profiles. See [account setup](docs/accounts.md)
for provider configuration, platform support, data format, and security rules.
Live authentication requires configuring your Firebase project first.

## Level Selection

The app opens `LevelLoader`, which accepts a list of `LevelDefinition` values
with a title, JSON asset path, and `unlocked` flag. Only unlocked levels can be
selected. The character jumps to the selected level before its screen opens.
The default catalog includes ten unlocked levels that reuse the bundled quiz,
word-matching, sentence-building, and listening data. Level 1 keeps the original
mixed lesson; levels 2-10 offer shorter themed combinations. Unlock state is
supplied by the caller, not persisted by the picker.

Set `mascotAsset` on `LevelLoader` to use another character throughout the path
and level screen. See `lib/widgets/README.md` for the SVG layer contract and
shared jump, yawn, and blink animations.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
