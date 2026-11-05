import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:indic_learn/language/language_pair.dart';
import 'package:indic_learn/language/language_pair_menu_button.dart';

void main() {
  group('localizedJson', () {
    test('passes flat strings through and resolves language maps', () {
      expect(localizedJson<String>('plain', 'te'), 'plain');
      expect(
        localizedJson<String>({'en': 'Water', 'kn': 'ನೀರು'}, 'kn'),
        'ನೀರು',
      );
    });
  });

  group('bundled game content', () {
    test('every localised map carries all six app languages', () {
      const requiredKeys = {'en', 'hi', 'kn', 'mr', 'pa', 'te'};
      final problems = <String>[];

      void visit(Object? node, String where) {
        if (node is Map) {
          if (node.containsKey('en') &&
              !(node.length == requiredKeys.length &&
                  requiredKeys.every(node.containsKey))) {
            problems.add('$where has keys ${node.keys.toList()}');
          }
          node.forEach((k, v) => visit(v, '$where.$k'));
        } else if (node is List) {
          for (var i = 0; i < node.length; i++) {
            visit(node[i], '$where[$i]');
          }
        }
      }

      for (final dir in [
        'assets/Quizes',
        'assets/scenarios',
        'assets/make_the_sentence',
        'assets/follow_the_sound',
        'assets/speed_round',
        'assets/fill_blank',
        'assets/match_the_pairs_json',
        'assets/memory_flip',
      ]) {
        for (final file in Directory(
          dir,
        ).listSync(recursive: true).whereType<File>()) {
          if (!file.path.endsWith('.json')) continue;
          visit(jsonDecode(file.readAsStringSync()), file.path);
        }
      }

      expect(problems, isEmpty);
    });
  });

  group('LanguagePair.parse', () {
    test('accepts supported distinct codes', () {
      expect(
        LanguagePair.parse('kn-te'),
        const LanguagePair(source: 'kn', target: 'te'),
      );
    });

    test('rejects unknown, identical, or malformed keys', () {
      expect(LanguagePair.parse('en-fr'), isNull);
      expect(LanguagePair.parse('hi-hi'), isNull);
      expect(LanguagePair.parse('hi'), isNull);
      expect(LanguagePair.parse(null), isNull);
    });
  });

  group('LanguagePairMenuButton.choose', () {
    const pair = LanguagePair(source: 'en', target: 'hi');

    test('changes one side and keeps the other', () {
      expect(
        LanguagePairMenuButton.choose(pair, forSource: false, language: 'te'),
        const LanguagePair(source: 'en', target: 'te'),
      );
      expect(
        LanguagePairMenuButton.choose(pair, forSource: true, language: 'kn'),
        const LanguagePair(source: 'kn', target: 'hi'),
      );
    });

    test(
      'swaps sides when the picked language is already on the other side',
      () {
        expect(
          LanguagePairMenuButton.choose(pair, forSource: true, language: 'hi'),
          const LanguagePair(source: 'hi', target: 'en'),
        );
        expect(
          LanguagePairMenuButton.choose(pair, forSource: false, language: 'en'),
          const LanguagePair(source: 'hi', target: 'en'),
        );
      },
    );
  });

  group('completedLevelsForPair', () {
    final stored = {
      'en-hi~everyday-practice': {'everyday-01'},
      'hi-en~hi-en-auto-rickshaw': {'auto-rickshaw-01'},
      'everyday-practice': {'legacy-01'},
    };

    test('returns only the active pair and strips its prefix', () {
      final result = completedLevelsForPair(
        const LanguagePair(source: 'hi', target: 'en'),
        stored,
      );
      expect(result, {
        'hi-en-auto-rickshaw': {'auto-rickshaw-01'},
      });
    });

    test('legacy unprefixed progress belongs to the default pair only', () {
      final defaultResult = completedLevelsForPair(
        LanguagePair.defaultPair,
        stored,
      );
      expect(defaultResult['everyday-practice'], {'everyday-01', 'legacy-01'});

      final otherResult = completedLevelsForPair(
        const LanguagePair(source: 'te', target: 'kn'),
        stored,
      );
      expect(otherResult, isEmpty);
    });

    test('scopedProgressId round-trips through completedLevelsForPair', () {
      const pair = LanguagePair(source: 'mr', target: 'pa');
      final id = scopedProgressId(pair, 'everyday-practice');
      expect(id, 'mr-pa~everyday-practice');
      expect(
        completedLevelsForPair(pair, {
          id: {'everyday-01'},
        }),
        {
          'everyday-practice': {'everyday-01'},
        },
      );
    });
  });

  group('resolveLanguage', () {
    const values = {'en': 'Hello', 'hi': 'नमस्ते'};

    test('uses the requested language, then English, then any entry', () {
      expect(resolveLanguage(values, 'hi'), 'नमस्ते');
      expect(resolveLanguage(values, 'te'), 'Hello');
      expect(resolveLanguage({'hi': 'नमस्ते'}, 'te'), 'नमस्ते');
      expect(resolveLanguage<String>({}, 'te'), isNull);
    });
  });
}
