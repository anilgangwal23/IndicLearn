import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';

/// Native names are shown in their own script so speakers can find their language.
const _nativeLanguageNames = {
  'en': 'English',
  'hi': 'हिन्दी',
  'pa': 'ਪੰਜਾਬੀ',
  'mr': 'मराठी',
  'kn': 'ಕನ್ನಡ',
  'te': 'తెలుగు',
};

class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.locale,
      builder: (context, current, _) => PopupMenuButton<String>(
        tooltip: l10n.languageLabel,
        icon: const Icon(Icons.translate),
        initialValue: current?.languageCode ?? '',
        onSelected: (code) =>
            LocaleController.select(code.isEmpty ? null : Locale(code)),
        itemBuilder: (context) => [
          PopupMenuItem(value: '', child: Text(l10n.languageDeviceDefault)),
          for (final code in _nativeLanguageNames.keys)
            PopupMenuItem(
              value: code,
              child: Text(_nativeLanguageNames[code]!),
            ),
        ],
      ),
    );
  }
}
