import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/app_controller.dart';
import '../providers/goal_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/primary_button.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task, this.goalId});

  final TaskModel? task;
  final String? goalId;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String? _goalId;
  DateTime? _dueDate;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _notesController.text = widget.task!.notes;
      _goalId = widget.task!.goalId;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    } else {
      _goalId = widget.goalId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final goalId = _goalId;
    if (goalId == null) {
      final appController = context.read<AppController>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appController.t('selectGoalFirst'))),
      );
      return;
    }

    final task = TaskModel(
      id: widget.task?.id ?? '',
      goalId: goalId,
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      dueDate: _dueDate,
      isDone: widget.task?.isDone ?? false,
      priority: _priority,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      subtasks: widget.task?.subtasks ?? const [],
    );

    final controller = context.read<TaskController>();
    if (widget.task == null) {
      controller.addTask(task);
    } else {
      controller.updateTask(task);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final goalController = context.watch<GoalController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null
              ? appController.t('addTask')
              : appController.t('editTask'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: appController.t('taskTitle'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: appController.t('notes'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _goalId,
                decoration: InputDecoration(
                  labelText: appController.t('goals'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: goalController.goals
                    .map(
                      (goal) => DropdownMenuItem(
                        value: goal.id,
                        child: Text(goal.displayTitle),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _goalId = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return appController.t('selectGoal');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _dueDate == null
                            ? appController.t('dueDate')
                            : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: appController.t('priority'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: TaskPriority.values
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: appController.t('save'),
                icon: Icons.save,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
