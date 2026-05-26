class SubtaskModel {
  final String id;
  final String title;
  final bool isDone;

  const SubtaskModel({
    required this.id,
    required this.title,
    required this.isDone,
  });

  SubtaskModel copyWith({String? id, String? title, bool? isDone}) {
    return SubtaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  static SubtaskModel fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
    );
  }
}
