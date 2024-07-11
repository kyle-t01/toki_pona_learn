// import 'package:sqflite/sqflite.dart';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:path/path.dart';

import './database_sql.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

//import models
import '../models/word.dart';
import '../models/part_of_speech.dart';
import '../models/definition.dart';
import '../models/practice_type.dart';
import '../models/word_fact.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._createInstance();
  static Database? _database;

  DatabaseHelper._createInstance() {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
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
    await _createAllTables(db);
    await loadDefaultCSVtoDB(db);
  }

  Future<void> _createAllTables(Database db) async {
    await db.execute(createWordsTable);
    await db.execute(createPartsOfSpeechTable);
    await db.execute(createDefinitionsTable);
  }

  Future<void> _deleteAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS Words');
    await db.execute('DROP TABLE IF EXISTS PartsOfSpeech');
    await db.execute('DROP TABLE IF EXISTS Definitions');
  }

  Future<void> loadDefaultCSVtoDB(Database db) async {
    String csvString = await _getDefaultCSVContent();

    await _insertCSVData(db, csvString);
  }

  Future<String> _getDefaultCSVContent() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String defaultCSVPath = join(directory.path, 'default_toki_pona_dict.csv');
    bool defaultCSVExists = await File(defaultCSVPath).exists();

    // if a default csv exists, use it else use original
    if (defaultCSVExists) {
      return File(defaultCSVPath).readAsString();
    } else {
      String originalCsvData =
          await rootBundle.loadString('assets/original_toki_pona_dict.csv');
      await File(defaultCSVPath).writeAsString(originalCsvData);
      return originalCsvData;
    }
  }

  Future<void> _insertCSVData(Database db, String csvString) async {
    List<List<dynamic>> data = const CsvToListConverter().convert(csvString);

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
      print("$wordStr $posStr $defsStr");
    }
  }

  Future<void> uploadCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      String csvString = await File(file.path!).readAsString();
      Directory directory = await getApplicationDocumentsDirectory();
      String defaultCSVPath =
          join(directory.path, 'default_toki_pona_dict.csv');

      // save custom csv file as new default csv file
      await File(defaultCSVPath).writeAsString(csvString);

      Database db = await database;
      await _deleteAllTables(db);
      await _createAllTables(db);
      await _insertCSVData(db, csvString);
    } else {
      print('File picker canceled');
    }
  }

  Future<void> revertToDefaultCSV() async {
    String originalCsvData =
        await rootBundle.loadString('assets/original_toki_pona_dict.csv');
    Directory directory = await getApplicationDocumentsDirectory();
    String defaultCSVPath = join(directory.path, 'default_toki_pona_dict.csv');

    // replace default with original
    await File(defaultCSVPath).writeAsString(originalCsvData);
    Database db = await database;
    await _deleteAllTables(db);
    await _createAllTables(db);
    await loadDefaultCSVtoDB(db);
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

  Future<List<WordFact>> getWordDefsMapping(String word) async {
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

    // mapping
    Map<int, Word> wordMap = {};
    Map<int, Map<String, List<String>>> definitionsMap = {};

    // for each entry in the database
    for (var entry in entries) {
      int wordId = entry['word_id'];
      String wordText = entry['word'];
      String partOfSpeech = entry['part'];
      String definition = entry['definition'];

      // are we processing a new word?
      if (!wordMap.containsKey(wordId)) {
        // yes a new word
        wordMap[wordId] = Word(id: wordId, word: wordText);
        definitionsMap[wordId] = {};
      }
      // is this part of speech already in the mapping?
      if (definitionsMap[wordId]!.containsKey(partOfSpeech)) {
        // yes, add to map
        definitionsMap[wordId]![partOfSpeech]!.add(definition);
      } else {
        // no, make it the first entry
        definitionsMap[wordId]![partOfSpeech] = [definition];
      }
    }
    List<WordFact> defsDictList = [];
    defsDictList = wordMap.entries.map((entry) {
      int wordId = entry.key;
      Word word = entry.value;
      Map<String, List<String>> definitions = definitionsMap[wordId]!;
      return WordFact(word: word, defsDict: definitions);
    }).toList();
    return defsDictList;
  }

  // get a randomWordFact in the DB
  Future<WordFact> getRandomWordFact(QuestionFormat questionFormat) async {
    Database db = await database;

    List<Map<String, dynamic>> numWordQuery =
        await db.rawQuery("SELECT max(id) FROM Words");
    int numWords = numWordQuery.first['max(id)'];

    int randomID = Random().nextInt(numWords) + 1;
    print(randomID);
    String dontShow = (questionFormat == QuestionFormat.symbols)
        ? "dont_show_sym"
        : "dont_show_def";

    List<Map<String, dynamic>> entries = await db.rawQuery('''
    SELECT Words.id AS word_id, Words.word, PartsOfSpeech.part, Definitions.definition
      FROM Words
      LEFT JOIN Definitions ON Definitions.word_id = Words.id
      LEFT JOIN PartsOfSpeech ON Definitions.part_of_speech_id = PartsOfSpeech.id
      WHERE word_id = $randomID AND Words.$dontShow = 0
    ''');

    // mapping
    Map<String, List<String>> definitionsMap = {};
    WordFact wordFact;

    int? id = entries.first['word_id'];
    String word = entries.first['word'];
    Word finalWord = Word(id: id, word: word);

    // for each entry in the database
    for (var entry in entries) {
      String partOfSpeech = entry['part'];
      String definition = entry['definition'];

      // is this part of speech already in the mapping?
      if (definitionsMap.containsKey(partOfSpeech)) {
        // yes, add to map
        definitionsMap[partOfSpeech]!.add(definition);
      } else {
        // no, make it the first entry
        definitionsMap[partOfSpeech] = [definition];
      }
    }

    wordFact = WordFact(word: finalWord, defsDict: definitionsMap);

    return wordFact;
  }

  // get a WordFact from one word
  Future<WordFact> getWordFact(Word word) async {
    Database db = await database;
    List<Map<String, dynamic>> entries = await db.rawQuery('''
    SELECT Words.id AS word_id, Words.word, PartsOfSpeech.part, Definitions.definition
      FROM Words
      LEFT JOIN Definitions ON Definitions.word_id = Words.id
      LEFT JOIN PartsOfSpeech ON Definitions.part_of_speech_id = PartsOfSpeech.id
      WHERE Words.word = ?
    ''', [word.word]);

    // mapping

    Map<String, List<String>> definitionsMap = {};
    WordFact wordFact;

    Word finalWord = word;

    // for each entry in the database
    for (var entry in entries) {
      String partOfSpeech = entry['part'];
      String definition = entry['definition'];

      // is this part of speech already in the mapping?
      if (definitionsMap.containsKey(partOfSpeech)) {
        // yes, add to map
        definitionsMap[partOfSpeech]!.add(definition);
      } else {
        // no, make it the first entry
        definitionsMap[partOfSpeech] = [definition];
      }
    }

    wordFact = WordFact(word: finalWord, defsDict: definitionsMap);

    return wordFact;
  }

  Future<List<Word>> getAllWords() async {
    Database db = await database;
    List<Word> words = [];
    List<Map<String, dynamic>> maps = [];
    maps = await db.rawQuery('''
      SELECT *
      FROM Words
    ''');

    for (var map in maps) {
      words.add(Word.fromMap(map));
    }
    return words;
  }

  // get a list of wordFacts for pratice quiz
  Future<List<WordFact>> getWordFacts(
      QuestionFormat questionFormat, int limit) async {
    List<WordFact> wordFacts = [];
    wordFacts = await getWordFactEntries(questionFormat, limit);
    return wordFacts;
  }

  Future<List<WordFact>> getWordFactEntries(
      QuestionFormat questionFormat, int limit) async {
    final Database db = await database;

    String dontShow = (questionFormat == QuestionFormat.symbols)
        ? "dont_show_sym"
        : "dont_show_def";

    List<Map<String, dynamic>> entries = await db.rawQuery('''
      SELECT Words.id AS word_id, Words.word, PartsOfSpeech.part, Definitions.definition
      FROM Words
      LEFT JOIN Definitions ON Definitions.word_id = Words.id
      LEFT JOIN PartsOfSpeech ON Definitions.part_of_speech_id = PartsOfSpeech.id
      WHERE Words.$dontShow = 0
      ORDER BY RANDOM()
      LIMIT $limit
      
    ''');

    // mapping
    Map<int, Word> wordMap = {};
    Map<int, Map<String, List<String>>> definitionsMap = {};

    // for each entry in the database
    for (var entry in entries) {
      int wordId = entry['word_id'];
      String wordText = entry['word'];
      String partOfSpeech = entry['part'];
      String definition = entry['definition'];

      // are we processing a new word?
      if (!wordMap.containsKey(wordId)) {
        // yes a new word
        wordMap[wordId] = Word(id: wordId, word: wordText);
        definitionsMap[wordId] = {};
      }
      // is this part of speech already in the mapping?
      if (definitionsMap[wordId]!.containsKey(partOfSpeech)) {
        // yes, add to map
        definitionsMap[wordId]![partOfSpeech]!.add(definition);
      } else {
        // no, make it the first entry
        definitionsMap[wordId]![partOfSpeech] = [definition];
      }
    }
    List<WordFact> wordFacts = [];
    wordFacts = wordMap.entries.map((entry) {
      int wordId = entry.key;
      Word word = entry.value;
      Map<String, List<String>> definitions = definitionsMap[wordId]!;
      return WordFact(word: word, defsDict: definitions);
    }).toList();
    return wordFacts;
  }

  Future<List<int>> getRandomWordIDList(QuestionFormat questionFormat) async {
    Database db = await database;
    String dontShow = (questionFormat == QuestionFormat.symbols)
        ? "dont_show_sym"
        : "dont_show_def";

    List<Map<String, dynamic>> numWordQuery = await db.rawQuery('''
      SELECT max(id) FROM Words
      WHERE Words.$dontShow = 0
    ''');
    int numWords = numWordQuery.first['max(id)'];
    List<int> questionList = List<int>.generate(numWords, (i) => i + 1);
    questionList.shuffle(Random());

    return questionList;
  }

  // get a wordFact in the DB by wordID
  Future<WordFact> getWordFactByID(int wordID) async {
    Database db = await database;

    List<Map<String, dynamic>> entries = await db.rawQuery('''
    SELECT Words.id AS word_id, Words.word, PartsOfSpeech.part, Definitions.definition
      FROM Words
      LEFT JOIN Definitions ON Definitions.word_id = Words.id
      LEFT JOIN PartsOfSpeech ON Definitions.part_of_speech_id = PartsOfSpeech.id
      WHERE word_id = $wordID
      
    ''');

    // mapping
    Map<String, List<String>> definitionsMap = {};
    WordFact wordFact;

    int? id = entries.first['word_id'];
    String word = entries.first['word'];
    Word finalWord = Word(id: id, word: word);

    // for each entry in the database
    for (var entry in entries) {
      String partOfSpeech = entry['part'];
      String definition = entry['definition'];

      // is this part of speech already in the mapping?
      if (definitionsMap.containsKey(partOfSpeech)) {
        // yes, add to map
        definitionsMap[partOfSpeech]!.add(definition);
      } else {
        // no, make it the first entry
        definitionsMap[partOfSpeech] = [definition];
      }
    }

    wordFact = WordFact(word: finalWord, defsDict: definitionsMap);

    return wordFact;
  }

  Future<List<WordFact>> getQuizOptions(WordFact original) async {
    List<WordFact> options = [];

    Database db = await database;

    List<Map<String, dynamic>> randomWords = await db.rawQuery('''
      SELECT Words.id as word_id
      FROM Words
      WHERE word_id != ${original.word.id}
      ORDER BY RANDOM()
      LIMIT 3
    ''');

    List<WordFact> quizWordFacts = [];
    for (var randomWord in randomWords) {
      int wordID = randomWord['word_id'];
      WordFact option = await getWordFactByID(wordID);
      quizWordFacts.add(option);
    }

    options = quizWordFacts;
    options.add(original);
    options.shuffle(Random());

    return options;
  }
}
