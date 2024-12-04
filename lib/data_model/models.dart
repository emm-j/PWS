class Doel {
  final int stappen;
  final DateTime updatetijd;
  Doel({
    required this.stappen,
    required this.updatetijd,
  });
  factory Doel.fromSqfliteDatabase(Map<String, dynamic> map) => Doel(
    stappen: map['stappen']?.toInt() ?? 0,
    updatetijd: DateTime.now(),
  );
}
