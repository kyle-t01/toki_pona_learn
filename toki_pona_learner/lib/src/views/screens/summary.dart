import 'package:flutter/material.dart';
import '../../models/word_fact.dart';
import '../screens/widgets/word_card.dart';

class SummaryScreen extends StatelessWidget {
  final Map<WordFact, bool> results;

  const SummaryScreen({required this.results});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: results.entries.map((entry) {
            return ListTile(
              title: _buildEntry(context, entry.key),
              trailing: Icon(
                entry.value ? Icons.check_circle : Icons.cancel,
                color: entry.value ? Colors.green : Colors.red,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, WordFact wordFact) {
    return ElevatedButton(
      onPressed: () {
        _viewWordCard(context, wordFact);
      },
      child: Row(
        children: [
          Text(wordFact.word.word,
              style: const TextStyle(
                fontFamily: 'sitelenselikiwen',
                fontSize: 24.0,
              )),
          Text(wordFact.word.word,
              style: const TextStyle(
                fontSize: 24.0,
              )),
        ],
      ),
    );
  }

  void _viewWordCard(BuildContext context, WordFact wordFact) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(0),
          child: Scaffold(
            appBar: AppBar(
              title: Text(wordFact.word.word),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: WordCard(wordFact: wordFact),
          ),
        );
      },
    );
  }
}
