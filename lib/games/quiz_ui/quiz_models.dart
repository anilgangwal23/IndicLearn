class GameQuestion {
  final String id;
  final String type;
  final String image;
  final Map<String, LanguageText> prompt;
  final List<GameChoice> choices;
  final String promptLanguage;
  final String targetLanguage;
  final bool introduce;

  GameQuestion({
    required this.id,
    required this.type,
    required this.image,
    required this.prompt,
    required this.choices,
    this.promptLanguage = 'en',
    this.targetLanguage = 'hi',
    this.introduce = false,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    final promptJson = json['prompt'] as Map<String, dynamic>;

    return GameQuestion(
      id: json['id'],
      type: json['type'],
      image: json['image'],
      promptLanguage: json['prompt_language'] as String? ?? 'en',
      targetLanguage: json['target_language'] as String? ?? 'hi',
      introduce: json['introduce'] as bool? ?? false,
      prompt: promptJson.map(
        (key, value) => MapEntry(key, LanguageText.fromJson(value)),
      ),
      choices: (json['choices'] as List)
          .map((choice) => GameChoice.fromJson(choice))
          .toList(),
    );
  }
}

class LanguageText {
  final String native;
  final String? romanized;

  LanguageText({required this.native, this.romanized});

  factory LanguageText.fromJson(Map<String, dynamic> json) {
    return LanguageText(native: json['native'], romanized: json['romanized']);
  }

  String display({required String variant}) {
    if (variant == 'romanized' && romanized != null) {
      return romanized!;
    }

    return native;
  }
}

class GameChoice {
  final String id;
  final String image;
  final Map<String, LanguageText> text;
  final bool correct;

  GameChoice({
    required this.image,
    required this.id,
    required this.text,
    required this.correct,
  });

  factory GameChoice.fromJson(Map<String, dynamic> json) {
    final textJson = json['text'] as Map<String, dynamic>;

    return GameChoice(
      image: json['image'],
      id: json['id'],
      correct: json['correct'],
      text: textJson.map(
        (key, value) => MapEntry(key, LanguageText.fromJson(value)),
      ),
    );
  }
}
