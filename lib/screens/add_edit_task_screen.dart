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
  bool _isSubmitting = false;

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(message), showCloseIcon: true));
  }

  void _showSaveError(AppController appController, Object error) {
    final reason = error.toString().replaceFirst('Bad state: ', '');
    final message = appController.formatMessage('saveFailedWithReason', {
      'reason': reason,
    });
    _showMessage(message);
  }

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

  Future<void> _save() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    final appController = context.read<AppController>();
    if (!appController.isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please log in to continue.')));
      return;
    }
    final goalId = _goalId;
    if (goalId == null) {
      _showMessage('Select a goal first.');
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
    if (!controller.canWrite) {
      _showMessage('Your session is still loading. Try again in a moment.');
      return;
    }
    setState(() => _isSubmitting = true);
    if (widget.task == null) {
      try {
        await controller.addTask(task);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showSaveError(appController, e);
        return;
      }
    } else {
      try {
        await controller.updateTask(task);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showSaveError(appController, e);
        return;
      }
    }

    await controller.loadTasks();

    if (!mounted) return;
    _showMessage(widget.task == null ? 'Task saved.' : 'Task updated.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final goalController = context.watch<GoalController>();
    if (!appController.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text('Add Task')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Please log in to continue.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    final goalsById = {for (final goal in goalController.goals) goal.id: goal};
    final dropdownValue = _goalId != null && goalsById.containsKey(_goalId)
        ? _goalId
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
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
                  labelText: 'Task title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: dropdownValue,
                decoration: InputDecoration(
                  labelText: 'Goals',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                items: goalsById.values
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
                    return 'Select a goal.';
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
                            ? 'Due date'
                            : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
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
                label: 'Save',
                icon: Icons.save,
                onPressed: _isSubmitting ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
