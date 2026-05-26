import 'subtask_model.dart';

enum TaskPriority { low, medium, high }

class TaskModel {
  final String id;
  final String goalId;
  final String title;
  final String notes;
  final DateTime? dueDate;
  final bool isDone;
  final TaskPriority priority;
  final DateTime createdAt;
  final List<SubtaskModel> subtasks;

  const TaskModel({
    required this.id,
    required this.goalId,
    required this.title,
    required this.notes,
    required this.dueDate,
    required this.isDone,
    required this.priority,
    required this.createdAt,
    required this.subtasks,
  });

  TaskModel copyWith({
    String? id,
    String? goalId,
    String? title,
    String? notes,
    DateTime? dueDate,
    bool? isDone,
    TaskPriority? priority,
    DateTime? createdAt,
    List<SubtaskModel>? subtasks,
  }) {
    return TaskModel(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'title': title,
      'notes': notes,
      'dueDate': dueDate?.toIso8601String(),
      'isDone': isDone,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'subtasks': subtasks.map((item) => item.toMap()).toList(),
    };
  }

  static TaskModel fromMap(String id, Map<String, dynamic> map) {
    return TaskModel(
      id: id,
      goalId: map['goalId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.tryParse(map['dueDate'] as String? ?? ''),
      isDone: map['isDone'] as bool? ?? false,
      priority:
          TaskPriority.values[(map['priority'] as int? ??
                  TaskPriority.medium.index)
              .clamp(0, TaskPriority.values.length - 1)],
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      subtasks: (map['subtasks'] as List<dynamic>? ?? [])
          .map(
            (item) =>
                SubtaskModel.fromMap(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}
