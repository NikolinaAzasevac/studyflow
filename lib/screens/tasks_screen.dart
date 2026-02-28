import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task_model.dart';
import '../providers/app_controller.dart';
import '../providers/goal_controller.dart';
import '../providers/task_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/study_app_bar.dart';
import '../widgets/task_tile.dart';
import 'task_details_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

enum TaskFilter { all, today, upcoming, overdue, completed }
enum TaskSort { dueDate, newest, priority }

class _TasksScreenState extends State<TasksScreen> {
  DateTime? _selectedDate;
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.dueDate;
  final _searchController = TextEditingController();

  String _goalName(
    AppController appController,
    GoalController controller,
    String goalId,
  ) {
    final match = controller.goals.where((item) => item.id == goalId).toList();
    if (match.isEmpty) return appController.t('unknownGoal');
    return match.first.displayTitle;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _filterLabel(AppController appController) {
    return _filterLabelFor(appController, _filter);
  }

  String _filterLabelFor(AppController appController, TaskFilter filter) {
    switch (filter) {
      case TaskFilter.today:
        return appController.t('today');
      case TaskFilter.upcoming:
        return appController.t('upcoming');
      case TaskFilter.overdue:
        return appController.t('overdueFilter');
      case TaskFilter.completed:
        return appController.t('completedFilter');
      case TaskFilter.all:
        return appController.t('all');
    }
  }

  String _sortLabel(AppController appController) {
    return _sortLabelFor(appController, _sort);
  }

  String _sortLabelFor(AppController appController, TaskSort sort) {
    switch (sort) {
      case TaskSort.newest:
        return appController.t('byNewest');
      case TaskSort.priority:
        return appController.t('byPriority');
      case TaskSort.dueDate:
        return appController.t('byDueDate');
    }
  }

  Future<void> _showFilterSheet(BuildContext context) async {
    final appController = context.read<AppController>();
    final selected = await showModalBottomSheet<TaskFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: TaskFilter.values.map((filter) {
              return RadioListTile<TaskFilter>(
                value: filter,
                groupValue: _filter,
                title: Text(_filterLabelFor(appController, filter)),
                onChanged: (value) => Navigator.of(context).pop(value),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _filter = selected);
    }
  }

  Future<void> _showSortSheet(BuildContext context) async {
    final appController = context.read<AppController>();
    final selected = await showModalBottomSheet<TaskSort>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: TaskSort.values.map((sort) {
              return RadioListTile<TaskSort>(
                value: sort,
                groupValue: _sort,
                title: Text(_sortLabelFor(appController, sort)),
                onChanged: (value) => Navigator.of(context).pop(value),
              );
            }).toList(),
          ),
        );
      },
    );
    if (selected != null) {
      setState(() => _sort = selected);
    }
  }

  List<DateTime> _weekDays() {
    final now = DateTime.now();
    return List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day + index),
    );
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    final now = DateTime.now();
    final query = _searchController.text.trim().toLowerCase();

    var filtered = tasks.where((task) {
      final matchesQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.notes.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      switch (_filter) {
        case TaskFilter.today:
          final due = task.dueDate;
          if (due == null) return false;
          return due.year == now.year &&
              due.month == now.month &&
              due.day == now.day;
        case TaskFilter.upcoming:
          final due = task.dueDate;
          if (due == null || task.isDone) return false;
          final diff = due.difference(DateTime(now.year, now.month, now.day));
          return diff.inDays >= 0 && diff.inDays <= 7;
        case TaskFilter.overdue:
          final due = task.dueDate;
          if (due == null || task.isDone) return false;
          return due.isBefore(now);
        case TaskFilter.completed:
          return task.isDone;
        case TaskFilter.all:
          return true;
      }
    }).toList();

    final indexMap = {
      for (var i = 0; i < tasks.length; i++) tasks[i].id: i,
    };

    switch (_sort) {
      case TaskSort.newest:
        filtered.sort(
          (a, b) => (indexMap[b.id] ?? 0).compareTo(indexMap[a.id] ?? 0),
        );
        break;
      case TaskSort.priority:
        filtered.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case TaskSort.dueDate:
        filtered.sort((a, b) {
          final aDate = a.dueDate ?? DateTime(2999);
          final bDate = b.dueDate ?? DateTime(2999);
          return aDate.compareTo(bDate);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final goalController = context.watch<GoalController>();
    final taskController = context.watch<TaskController>();

    final tasks = _selectedDate == null
        ? taskController.tasks
        : taskController.tasksForDate(_selectedDate!);
    final visibleTasks = _applyFilters(tasks);

    return Scaffold(
      appBar: StudyAppBar(
        title: appController.t('tasks'),
      ),
      body: taskController.tasks.isEmpty
          ? EmptyState(
              title: appController.t('tasks'),
              message: appController.t('emptyTasks'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: appController.t('searchTasks'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(appController.t('all')),
                              selected: _selectedDate == null,
                              onSelected: (_) {
                                setState(() => _selectedDate = null);
                              },
                            ),
                            const SizedBox(width: 8),
                            ..._weekDays().map((day) {
                              final isSelected = _selectedDate != null &&
                                  _selectedDate!.year == day.year &&
                                  _selectedDate!.month == day.month &&
                                  _selectedDate!.day == day.day;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text('${day.day}.${day.month}.'),
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      setState(() => _selectedDate = day),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.calendar_month),
                      onPressed: _pickDate,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text(appController.t('filter') +
                            ': ' +
                            _filterLabel(appController)),
                        selected: true,
                        onSelected: (_) => _showFilterSheet(context),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: Text(appController.t('sort') +
                            ': ' +
                            _sortLabel(appController)),
                        selected: true,
                        onSelected: (_) => _showSortSheet(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (visibleTasks.isEmpty)
                  EmptyState(
                    title: appController.t('tasks'),
                    message: appController.t('emptyTasks'),
                  )
                else
                  ...visibleTasks.map((task) {
                    final goalName = _goalName(
                      appController,
                      goalController,
                      task.goalId,
                    );
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskTile(
                        task: task,
                        goalName: goalName,
                        onToggle: () => taskController.toggleTask(task),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailsScreen(
                                task: task,
                                goalName: goalName,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
