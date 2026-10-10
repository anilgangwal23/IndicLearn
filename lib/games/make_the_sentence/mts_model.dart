// --- Configuration and Dummy Data Logic (Parse JSON) ---

class MTSModel {
  final String source;   // e.g., "Apple"
  final String translation;    // e.g. "Seb" (Translation/Definition)
  final int index;  // To track the correct pairing index from raw list
  
  const MTSModel({required this.source, required this.translation, required this.index});

}