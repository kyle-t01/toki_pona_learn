// import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

import './database_sql.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:csv/csv.dart';

//import models
import '../models/word.dart';
import '../models/part_of_speech.dart';
import '../models/definition.dart';
import '../models/defs_dict.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._createInstance();
  static Database? _database;

  DatabaseHelper._createInstance() {
    // init sqflite for desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    // get the directory path to store the database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/toki_pona_learner.db';
    print("db_helper.dart| db path:$path");

    // open/create the database at the given path
    Database db = await openDatabase(path, version: 1, onCreate: _createDb);

    return db;
  }

  Future<void> _createDb(Database db, int version) async {
    // await db.execute(createFontsTable);
    await db.execute(createWordsTable);
    await db.execute(createPartsOfSpeechTable);
    await db.execute(createDefinitionsTable);
    await loadCSVtoDB(db);
  }

  Future<void> loadCSVtoDB(Database db) async {
    await insertDefinitions(db);
    return;
  }

  Future<void> insertDefinitions(Database db) async {
    final String defsData =
        await rootBundle.loadString('assets/toki_pona_dict.csv');
    List<List<dynamic>> data = const CsvToListConverter().convert(defsData);

    for (var row in data) {
      String wordStr = row[0];
      String posStr = row[1];
      var defsStr = row[2];

      int wordID = await getOrInsertWordId(db, wordStr);
      int posID = await getOrInsertPartOfSpeechId(db, posStr);

      await db.insert('Definitions', {
        'word_id': wordID,
        'part_of_speech_id': posID,
        'definition': defsStr
      });
    }
  }

  Future<int> getOrInsertWordId(Database db, String word) async {
    List<Map<String, dynamic>> maps = await db.query(
      'Words',
      where: 'word = ?',
      whereArgs: [word],
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    } else {
      // insert
      int newId = await db.insert('Words', {'word': word});
      return newId;
    }
  }

  Future<int> getOrInsertPartOfSpeechId(
      Database db, String partOfSpeech) async {
    List<Map<String, dynamic>> maps = await db.query(
      'PartsOfSpeech',
      where: 'part = ?',
      whereArgs: [partOfSpeech],
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    } else {
      int newId = await db.insert('PartsOfSpeech', {'part': partOfSpeech});
      return newId;
    }
  }

  Future<List<DefsDict>> getWordDefsMapping(String word) async {
    Database db = await database;
    List<Map<String, dynamic>> entries = await db.rawQuery('''
    SELECT Words.id AS word_id, Words.word, PartsOfSpeech.part, Definitions.definition
      FROM Words
      LEFT JOIN Definitions ON Definitions.word_id = Words.id
      LEFT JOIN PartsOfSpeech ON Definitions.part_of_speech_id = PartsOfSpeech.id
      WHERE Words.word LIKE ?
    ''', ['$word%']);

    if (entries.isEmpty) {
      return [];
    }

    // mapping of
    Map<int, Word> wordMap = {};
    Map<int, Map<String, List<String>>> definitionsMap = {};

    for (var entry in entries) {
      int wordId = entry['word_id'];
      String wordText = entry['word'];
      String partOfSpeech = entry['part'];
      String definition = entry['definition'];

      if (!wordMap.containsKey(wordId)) {
        wordMap[wordId] = Word(id: wordId, word: wordText);
        definitionsMap[wordId] = {};
      }

      if (definitionsMap[wordId]!.containsKey(partOfSpeech)) {
        definitionsMap[wordId]![partOfSpeech]!.add(definition);
      } else {
        definitionsMap[wordId]![partOfSpeech] = [definition];
      }
    }
    List<DefsDict> defsDictList = [];
    defsDictList = wordMap.entries.map((entry) {
      int wordId = entry.key;
      Word word = entry.value;
      Map<String, List<String>> definitions = definitionsMap[wordId]!;
      return DefsDict(word: word, defsDict: definitions);
    }).toList();
    return defsDictList;
  }
}
