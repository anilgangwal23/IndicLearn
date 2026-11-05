import '../../language/language_pair.dart';

// --- Configuration and Dummy Data Logic (Parse JSON) ---

class MTSModel {
  final String source; // e.g., "Apple"
  final String translation; // e.g. "Seb" (Translation/Definition)
  final List<int> index; // To track the correct pairing index from raw list
  final List<String> words;

  const MTSModel({
    required this.source,
    required this.translation,
    required this.index,
    required this.words,
  });

  bool acceptsNextWord(List<int> selected, int wordId) {
    return selected.length < index.length &&
        wordId >= 0 &&
        wordId < words.length &&
        !selected.contains(wordId) &&
        words[wordId] == words[index[selected.length]];
  }

  factory MTSModel.fromJson(
    Map<String, dynamic> json, {
    required String source,
    required String target,
  }) {
    return MTSModel(
      source: localizedJson<String>(json['source'], source),
      translation: localizedJson<String>(json['translation'], target),
      index: localizedJson<List<dynamic>>(
        json['index'],
        target,
      ).map((e) => e as int).toList(),
      words: localizedJson<List<dynamic>>(
        json['words'],
        target,
      ).map((e) => e as String).toList(),
    );
  }
}
