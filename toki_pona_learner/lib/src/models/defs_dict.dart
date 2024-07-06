import "../models/word.dart";

class DefsDict {
  final Word word;
  final Map<String, List<String>> defsDict;

  DefsDict({required this.word, required this.defsDict});
}
