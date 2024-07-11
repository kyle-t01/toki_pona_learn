import 'package:flutter/material.dart';
import '../../../models/word_fact.dart';

class CompactWordCard extends StatelessWidget {
  final WordFact wordFact;
  final bool hideHeader;
  const CompactWordCard(
      {super.key, required this.wordFact, required this.hideHeader});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = wordFact.defsDict.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hideHeader ? const Text("") : buildWordHeader(),
            const SizedBox(height: 8.0),
            ...buildCompactDefinitions(sortedKeys),
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
        //const Spacer(),
        Text(wordFact.word.word,
            style: const TextStyle(
              fontSize: 24.0,
            )),
      ],
    );
  }

  List<Widget> buildCompactDefinitions(List<String> sortedKeys) {
    return sortedKeys.map((partOfSpeech) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Colors.black,
            ),
            children: [
              TextSpan(
                text: '$partOfSpeech: ',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextSpan(
                text: wordFact.defsDict[partOfSpeech]!.join(', '),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
