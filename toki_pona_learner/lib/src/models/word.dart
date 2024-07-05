class Word {
  int? id;
  String word;

  int priority;
  int streak;
  bool dontShow;

  Word({
    this.id,
    required this.word,
    this.priority = 10,
    this.streak = 0,
    this.dontShow = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'priority': priority,
      'streak': streak,
      'dont_show': dontShow ? 1 : 0,
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      priority: map['priority'],
      streak: map['streak'],
      dontShow: map['dont_show'] == 1,
    );
  }
}
