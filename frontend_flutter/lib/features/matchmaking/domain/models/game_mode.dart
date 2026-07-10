class GameMode {
  final String id;
  final String label;
  final String timeControl;
  final int entryFee;
  final int prize;
  final bool isRated;
  final String tag;

  const GameMode({
    required this.id,
    required this.label,
    required this.timeControl,
    required this.entryFee,
    required this.prize,
    required this.isRated,
    required this.tag,
  });

  factory GameMode.fromJson(Map<String, dynamic> json) => GameMode(
    id: json['id'],
    label: json['label'],
    timeControl: json['timeControl'],
    entryFee: json['entryFee'] ?? 0,
    prize: json['prize'] ?? 0,
    isRated: json['isRated'] ?? false,
    tag: json['tag'] ?? 'Free',
  );

  bool get isPaid => entryFee > 0;
}
