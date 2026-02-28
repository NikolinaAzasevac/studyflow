class SubtaskModel {
  final String id;
  final String title;
  final bool isDone;

  const SubtaskModel({
    required this.id,
    required this.title,
    required this.isDone,
  });

  SubtaskModel copyWith({
    String? id,
    String? title,
    bool? isDone,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
