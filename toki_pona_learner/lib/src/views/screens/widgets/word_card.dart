import 'package:flutter/material.dart';
import '../../../models/word_fact.dart';

class WordCard extends StatelessWidget {
  final WordFact wordFact;
  const WordCard({super.key, required this.wordFact});

  @override
  Widget build(BuildContext context) {
    // Sort the parts of speech alphabetically
    final sortedKeys = wordFact.defsDict.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWordHeader(),
            const SizedBox(height: 8.0),
            ...buildDefinitions(sortedKeys),
          ],
        ),
      ),
    );
  }

  Widget buildWordHeader() {
    return Row(
      children: [
        Text(wordFact.word.word,
            style: const TextStyle(
              fontFamily: 'sitelenselikiwen',
              fontSize: 24.0,
            )),
        Text(wordFact.word.word,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 24.0,
            )),
      ],
    );
  }

  List<Widget> buildDefinitions(List<String> sortedKeys) {
    return sortedKeys.map((partOfSpeech) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildPartOfSpeech(partOfSpeech),
          ...buildDefinitionsList(partOfSpeech),
          const SizedBox(height: 8.0),
        ],
      );
    }).toList();
  }

  Widget buildPartOfSpeech(String partOfSpeech) {
    return Text(
      partOfSpeech,
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> buildDefinitionsList(String partOfSpeech) {
    return wordFact.defsDict[partOfSpeech]!.map((definition) {
      return Text(
        definition,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
        ),
      );
    }).toList();
  }
}
