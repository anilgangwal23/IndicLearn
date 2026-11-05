import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Languages that learning content can be shown in, as either source or target.
const supportedLanguageCodes = ['en', 'hi', 'kn', 'mr', 'pa', 'te'];

/// Native names are shown in their own script so speakers can find their language.
const nativeLanguageNames = {
  'en': 'English',
  'hi': 'हिन्दी',
  'kn': 'ಕನ್ನಡ',
  'mr': 'मराठी',
  'pa': 'ਪੰਜਾਬੀ',
  'te': 'తెలుగు',
};

/// The learner's chosen direction. [source] is the language prompts are shown in,
/// and [target] is the language the learner answers in. Independent of app UI locale.
@immutable
class LanguagePair {
  const LanguagePair({required this.source, required this.target})
    : assert(source != target, 'Source and target must differ.');

  static const defaultPair = LanguagePair(source: 'en', target: 'hi');

  final String source;
  final String target;

  /// Stable key used for local storage and progress document IDs, e.g. `en-hi`.
  String get key => '$source-$target';

  bool get isValid =>
      supportedLanguageCodes.contains(source) &&
      supportedLanguageCodes.contains(target) &&
      source != target;

  static LanguagePair? parse(String? key) {
    if (key == null) return null;
    final parts = key.split('-');
    if (parts.length != 2) return null;
    if (parts[0] == parts[1]) return null;
    final pair = LanguagePair(source: parts[0], target: parts[1]);
    return pair.isValid ? pair : null;
  }

  @override
  bool operator ==(Object other) =>
      other is LanguagePair && other.source == source && other.target == target;

  @override
  int get hashCode => Object.hash(source, target);

  @override
  String toString() => key;
}

/// Holds the learner's source and target languages. Persists locally so guests keep
/// their choice. Signed-in users also sync through [LanguagePairController.select].
class LanguagePairController {
  LanguagePairController._();

  static const _prefsKey = 'learning_language_pair';

  static final ValueNotifier<LanguagePair> pair = ValueNotifier<LanguagePair>(
    LanguagePair.defaultPair,
  );

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    pair.value =
        LanguagePair.parse(prefs.getString(_prefsKey)) ??
        LanguagePair.defaultPair;
  }

  static Future<void> select(LanguagePair value) async {
    if (!value.isValid) {
      throw ArgumentError.value(value, 'value', 'Unsupported language pair.');
    }
    pair.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, value.key);
  }
}

const _progressSeparator = '~';

/// Progress document ID for [scenarioId] under [pair], e.g. `en-hi~everyday-practice`.
String scopedProgressId(LanguagePair pair, String scenarioId) =>
    '${pair.key}$_progressSeparator$scenarioId';

/// Picks the completed level IDs that belong to [pair] from stored progress keyed by
/// [scopedProgressId]. Unprefixed legacy keys were written before pairs existed and
/// count toward [LanguagePair.defaultPair].
Map<String, Set<String>> completedLevelsForPair(
  LanguagePair pair,
  Map<String, Set<String>> stored,
) {
  final result = <String, Set<String>>{};
  final prefix = '${pair.key}$_progressSeparator';
  for (final entry in stored.entries) {
    final key = entry.key;
    final String scenarioId;
    if (key.contains(_progressSeparator)) {
      if (!key.startsWith(prefix)) continue;
      scenarioId = key.substring(prefix.length);
    } else if (pair == LanguagePair.defaultPair) {
      scenarioId = key;
    } else {
      continue;
    }
    result[scenarioId] = {...?result[scenarioId], ...entry.value};
  }
  return result;
}

/// Resolves a language map for [language]. Falls back to English, then to any entry.
T? resolveLanguage<T>(Map<String, T> values, String language) {
  if (values.isEmpty) return null;
  return values[language] ?? values['en'] ?? values.values.first;
}

/// Reads a JSON game value that is either a plain value or a per-language map,
/// returning the entry for [language]. Game assets store every text leaf as a map.
T localizedJson<T>(Object? raw, String language) {
  if (raw is! Map) return raw as T;
  return resolveLanguage<T>(
    Map<String, T>.from(raw.cast<String, T>()),
    language,
  ) as T;
}
