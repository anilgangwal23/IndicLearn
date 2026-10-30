class MemoryFlipCard {
  final int pairId;
  final String text;

  const MemoryFlipCard({required this.pairId, required this.text});
}

enum MemoryFlipDifficulty {
  easy(cardCount: 6),
  medium(cardCount: 8),
  hard(cardCount: 10);

  final int cardCount;
  const MemoryFlipDifficulty({required this.cardCount});

  int get pairCount => cardCount ~/ 2;
}
