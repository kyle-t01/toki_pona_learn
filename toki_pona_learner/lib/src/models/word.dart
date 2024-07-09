class Word {
  int? id;
  String word;

  bool dontShowSym;
  bool dontShowDef;

  Word({
    this.id,
    required this.word,
    this.dontShowDef = false,
    this.dontShowSym = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'dont_show_def': dontShowDef ? 1 : 0,
      'dont_show_sym': dontShowSym ? 1 : 0,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      dontShowSym: map['dont_show_sym'] == 1,
      dontShowDef: map['dont_show_def'] == 1,
    );
  }
}
