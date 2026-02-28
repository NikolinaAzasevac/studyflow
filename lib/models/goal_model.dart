class GoalModel {
  final String id;
  final String area;
  final String type;
  final String description;
  final String? coverUrl;
  final DateTime targetDate;

  const GoalModel({
    required this.id,
    required this.area,
    required this.type,
    required this.description,
    required this.coverUrl,
    required this.targetDate,
  });

  String get displayTitle => '$area • $type';

  GoalModel copyWith({
    String? id,
    String? area,
    String? type,
    String? description,
    String? coverUrl,
    DateTime? targetDate,
  }) {
    return GoalModel(
      id: id ?? this.id,
      area: area ?? this.area,
      type: type ?? this.type,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      targetDate: targetDate ?? this.targetDate,
    );
  }
}
