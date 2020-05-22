class NotusInsert {
  final String insert;
  final Map attributes;

  NotusInsert({this.insert, this.attributes});

  factory NotusInsert.fromJSON(Map map) {
    return NotusInsert(
      insert: map["insert"],
      attributes: map["attributes"],
    );
  }
}