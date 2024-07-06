import 'package:flutter/material.dart';
import '../../../models/defs_dict.dart';

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
            Text(
              wordFact.word.word,
              style: const TextStyle(
                fontFamily: 'sitelenselikiwen',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ...sortedKeys.map((partOfSpeech) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partOfSpeech,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...wordFact.defsDict[partOfSpeech]!.map((definition) {
                    return Text(
                      definition,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8.0),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
