import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'dart:async';
import "../../views/screens/widgets/word_card.dart";
import "../../views/screens/widgets/compact_word_card.dart";
import "../../models/word.dart";
import "../../models/word_fact.dart";

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final DatabaseHelper db = DatabaseHelper();
  List<Word> words = [];
  bool isLoading = true;
  int columns = 4;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Word>> _loadEntries() async {
    DatabaseHelper db = DatabaseHelper();
    List<Word> wordsFromDB = await db.getAllWords();
    setState(() {
      words = wordsFromDB;
      isLoading = false;
    });
    return await db.getAllWords();
  }

  void _zoomIn() {
    setState(() {
      columns = columns + 1 > 10 ? 10 : columns + 1;
    });
  }

  void _zoomOut() {
    setState(() {
      columns = columns - 1 < 1 ? 1 : columns - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / columns;
    final itemHeight = itemWidth;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('View Words'),
            //const SizedBox(width: 4.0),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: _zoomOut,
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: _zoomIn,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildWordGrid(itemWidth, itemHeight),
      ),
    );
  }

  Widget _buildWordGrid(double itemWidth, double itemHeight) {
    if (words.isEmpty) {
      return const Center(child: Text("No words found in database!"));
    }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 0.0,
      ),
      itemCount: words.length,
      itemBuilder: (context, index) {
        return _buildWordCard(words[index], itemWidth, itemHeight);
      },
    );
  }

  Widget _buildWordCard(Word word, double itemWidth, double itemHeight) {
    return GestureDetector(
      onTap: () async {
        WordFact wordFact = await db.getWordFact(word);
        _viewWordCard(wordFact);
      },
      child: Card(
        margin: const EdgeInsets.all(1.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 4),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word.word,
                style: const TextStyle(
                  fontFamily: 'sitelenselikiwen',
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 0.0),
              Text(
                word.word,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewWordCard(WordFact wordFact) {
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
            body: CompactWordCard(wordFact: wordFact, hideHeader: false),
          ),
        );
      },
    );
  }
}
