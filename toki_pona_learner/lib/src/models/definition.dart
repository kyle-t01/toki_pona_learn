class Definition {
  int? id;
  int wordId;
  int partOfSpeechId;
  String definition;

  Definition({
    this.id,
    required this.wordId,
    required this.partOfSpeechId,
    required this.definition,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word_id': wordId,
      'part_of_speech_id': partOfSpeechId,
      'definition': definition,
    };
  }

  factory Definition.fromMap(Map<String, dynamic> map) {
    return Definition(
      id: map['id'],
      wordId: map['word_id'],
      partOfSpeechId: map['part_of_speech_id'],
      definition: map['definition'],
    );
  }
}
