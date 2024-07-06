import "../models/word.dart";

class WordFact {
  final Word word;
  final Map<String, List<String>> defsDict;

  WordFact({required this.word, required this.defsDict});

  @override
  String toString() {
    return word.word;
  }
}
