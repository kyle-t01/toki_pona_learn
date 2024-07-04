// database_sql.dart

/*
// fonts table
const String createFontsTable = '''
CREATE TABLE Fonts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  file BLOB NOT NULL
);
''';
*/

// words table
const String createWordsTable = '''
CREATE TABLE Words (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word TEXT NOT NULL,
  glyph_code INTEGER NOT NULL,
  priority INTEGER DEFAULT 10,
  streak INTEGER DEFAULT 0,
  dont_show BOOLEAN NOT NULL DEFAULT FALSE
);
''';

// parts of speech
const String createPartsOfSpeechTable = '''
CREATE TABLE PartsOfSpeech (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  part TEXT NOT NULL UNIQUE
);
''';

// definitions
const String createDefinitionsTable = '''
CREATE TABLE Definitions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL,
  part_of_speech_id INTEGER NOT NULL,
  definition TEXT NOT NULL,
  FOREIGN KEY (word_id) REFERENCES words(id),
  FOREIGN KEY (parts_of_speech_id) REFERENCES parts_of_speech(id)
);
''';
