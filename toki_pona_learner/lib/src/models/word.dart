class Word {
  int? id;
  String word;
  int glyphCode;
  int priority;
  int streak;
  bool dontShow;

  Word({
    this.id,
    required this.word,
    required this.glyphCode,
    this.priority = 10,
    this.streak = 0,
    this.dontShow = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'glyph_code': glyphCode,
      'priority': priority,
      'streak': streak,
      'dont_show': dontShow ? 1 : 0,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      glyphCode: map['glyph_code'],
      priority: map['priority'],
      streak: map['streak'],
      dontShow: map['dont_show'] == 1,
    );
  }
}
