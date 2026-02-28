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
}
