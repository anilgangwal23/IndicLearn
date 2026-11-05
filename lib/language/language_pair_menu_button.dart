import 'package:flutter/material.dart';

import 'language_pair.dart';

/// Lets the learner pick the source and target languages independently.
/// Labels use native names, so the picker does not depend on app UI locale.
class LanguagePairMenuButton extends StatelessWidget {
  const LanguagePairMenuButton({super.key});

  /// Returns the pair after the learner picks [language] for one side. If the
  /// other side already uses [language], the two sides swap so the pair stays valid.
  static LanguagePair choose(
    LanguagePair current, {
    required bool forSource,
    required String language,
  }) {
    if (forSource) {
      final target = language == current.target
          ? current.source
          : current.target;
      return LanguagePair(source: language, target: target);
    }
    final source = language == current.source ? current.target : current.source;
    return LanguagePair(source: source, target: language);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LanguagePair>(
      valueListenable: LanguagePairController.pair,
      builder: (context, current, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageSideButton(
              label: nativeLanguageNames[current.source]!,
              selected: current.source,
              onSelected: (code) => LanguagePairController.select(
                choose(current, forSource: true, language: code),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18),
            _LanguageSideButton(
              label: nativeLanguageNames[current.target]!,
              selected: current.target,
              onSelected: (code) => LanguagePairController.select(
                choose(current, forSource: false, language: code),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageSideButton extends StatelessWidget {
  const _LanguageSideButton({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final code in supportedLanguageCodes)
          PopupMenuItem<String>(
            value: code,
            child: Text(nativeLanguageNames[code]!),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label),
      ),
    );
  }
}
