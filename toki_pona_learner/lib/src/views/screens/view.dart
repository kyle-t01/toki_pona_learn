import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import 'dart:async';
import "../../views/screens/widgets/word_card.dart";

import "../../models/defs_dict.dart";

class View extends StatefulWidget {
  const View({Key? key}) : super(key: key);

  @override
  _ViewState createState() => _ViewState();
}

class _ViewState extends State<View> {
  final DatabaseHelper db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadEntries() async {
    DatabaseHelper db = DatabaseHelper();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 16.0),
            Expanded(
              child: Center(child: Text('No results found')),
            ),
          ],
        ),
      ),
    );
  }
}
