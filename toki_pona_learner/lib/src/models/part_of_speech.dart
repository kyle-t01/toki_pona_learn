class PartOfSpeech {
  int? id;
  String part;

  PartOfSpeech({
    this.id,
    required this.part,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'part': part,
    };
  }

  factory PartOfSpeech.fromMap(Map<String, dynamic> map) {
    return PartOfSpeech(
      id: map['id'],
      part: map['part'],
    );
  }
}
