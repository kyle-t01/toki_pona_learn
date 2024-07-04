// import 'package:sqflite/sqflite.dart';
import './database_sql.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
    var db = await openDatabase(path, version: 1, onCreate: _createDb);

    return db;
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute(createFontsTable);
    await db.execute(createWordsTable);
    await db.execute(createPartsOfSpeechTable);
    await db.execute(createDefinitionsTable);
  }
}
