class Doel {
  final int level;
  final bool gehaald;
  Doel({
    required this.level,
    required this.gehaald,
  });
  factory Doel.fromSqfliteDatabase(Map<String, dynamic> map) => Doel(
    level: map['level'] as int,
    gehaald: (map['gehaald'] as int) == 1,
  );

  Map<String, dynamic> toMap() => {
    'level': level,
    'gehaald': gehaald ? 1 : 0,
  };
}
