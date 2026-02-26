enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String subjectId;
  final String title;
  final String notes;
  final DateTime? dueDate;
  final bool isDone;
  final TaskPriority priority;

  const TaskModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.notes,
    required this.dueDate,
    required this.isDone,
    required this.priority,
  });

  TaskModel copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? notes,
    DateTime? dueDate,
    bool? isDone,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
    );
  }
}
