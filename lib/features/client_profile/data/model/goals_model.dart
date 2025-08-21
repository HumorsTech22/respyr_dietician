class Goal {
  final String name;
  final int currentStat;
  final int targetStat;

  Goal({required this.name, required this.currentStat, required this.targetStat});

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    name: json['name']?.toString() ?? '',
    currentStat: int.tryParse(json['current_stat'].toString()) ?? 0,
    targetStat: int.tryParse(json['target_stat'].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'current_stat': currentStat,
    'target_stat': targetStat,
  };
}
