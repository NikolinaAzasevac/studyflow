class SubjectModel {
  final String id;
  final String title;
  final String description;
  final String? coverUrl;
  final int totalTasks;
  final int completedTasks;

  const SubjectModel({
    required this.id,
    required this.title,
    required this.description,
    this.coverUrl,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get progress {
    if (totalTasks == 0) return 0;
    return completedTasks / totalTasks;
  }

  SubjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverUrl,
    int? totalTasks,
    int? completedTasks,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
    );
  }
}
