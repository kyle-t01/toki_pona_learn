import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'dart:async';
import "../../views/screens/widgets/word_card.dart";
import "../../views/screens/widgets/compact_word_card.dart";
import '../../models/word_fact.dart';

class Dictionary extends StatefulWidget {
  const Dictionary({Key? key}) : super(key: key);

  @override
  _DictionaryState createState() => _DictionaryState();
}

class _DictionaryState extends State<Dictionary> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  final DatabaseHelper db = DatabaseHelper();
  List<WordFact> results = [];
  List<String> splitQuery = [];
  bool toggleCompactView = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _onSearchChanged() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _loadEntries();
    });
  }

  Future<void> _loadEntries() async {
    DatabaseHelper db = DatabaseHelper();
    String query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        results = [];
        splitQuery = [];
      });
      return;
    }

    // search query is space delimited
    List<String> words = query.split(' ').map((word) => word.trim()).toList();
    List<WordFact> entries = [];

    int emptyQueries = 0;
    for (String word in words) {
      // check input for " "
      if (word.isEmpty && emptyQueries > 0) {
        continue;
      } else {
        emptyQueries++;
      }
      List<WordFact> entry = await db.getWordDefsMapping(word);
      entries.addAll(entry);
    }

    setState(() {
      results = entries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Dictionary'),
            const SizedBox(width: 16.0),
            IconButton(
              icon: toggleCompactView
                  ? const Icon(Icons.article)
                  : const Icon(Icons.article_outlined),
              onPressed: _toggleCompactPressed,
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
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              focusNode: _searchFocusNode,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        WordFact wordFact = results[index];
                        Widget card = toggleCompactView
                            ? CompactWordCard(
                                wordFact: wordFact,
                                hideHeader: false,
                              )
                            : WordCard(wordFact: wordFact);
                        return card;
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCompactPressed() {
    setState(() {
      toggleCompactView = !toggleCompactView;
    });
  }
}
