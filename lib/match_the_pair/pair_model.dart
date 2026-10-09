// --- Configuration and Dummy Data Logic (Parse JSON) ---

class MatchPairData {
  final String leftWord;   // e.g., "Apple"
  final String rightDef;    // e.g. "Seb" (Translation/Definition)
  final int originalIndex;  // To track the correct pairing index from raw list
  
  const MatchPairData({required this.leftWord, required this.rightDef, required this.originalIndex});

}