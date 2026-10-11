// --- Configuration and Dummy Data Logic (Parse JSON) ---

class MTSModel {
  final String source;   // e.g., "Apple"
  final String translation;    // e.g. "Seb" (Translation/Definition)
  final List<int> index;  // To track the correct pairing index from raw list
  final List<String> words;
  
  const MTSModel({required this.source, required this.translation, required this.index, required this.words});

  factory MTSModel.fromJson(Map<String, dynamic> json) {
    return MTSModel(
      source: json['source'] as String,
      translation: json['translation'] as String,
      index: (json['index'] as List<dynamic>).map((e) => e as int).toList(),
      words: (json['words'] as List<dynamic>).map((e) => e as String).toList()
    );
  }
}