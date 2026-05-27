import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_model.dart';
import '../providers/app_controller.dart';
import '../providers/goal_controller.dart';
import '../widgets/primary_button.dart';

class AddEditGoalScreen extends StatefulWidget {
  const AddEditGoalScreen({super.key, this.goal});

  final GoalModel? goal;

  @override
  State<AddEditGoalScreen> createState() => _AddEditGoalScreenState();
}

class _AddEditGoalScreenState extends State<AddEditGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();
  DateTime? _targetDate;
  String? _selectedCoverUrl;
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
    if (widget.goal != null) {
      _areaController.text = widget.goal!.area;
      _typeController.text = widget.goal!.type;
      _descriptionController.text = widget.goal!.description;
      _targetDate = widget.goal!.targetDate;
      _selectedCoverUrl = widget.goal!.coverUrl;
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date != null) {
      setState(() => _targetDate = date);
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
    if (_targetDate == null) {
      _showMessage('Pick a date first.');
      return;
    }
    final goalController = context.read<GoalController>();
    if (!goalController.canWrite) {
      _showMessage('Your session is still loading. Try again in a moment.');
      return;
    }
    setState(() => _isSubmitting = true);

    final goal = GoalModel(
      id: widget.goal?.id ?? '',
      area: _areaController.text.trim(),
      type: _typeController.text.trim(),
      description: _descriptionController.text.trim(),
      coverUrl: _selectedCoverUrl,
      targetDate: _targetDate!,
    );

    if (widget.goal == null) {
      try {
        await goalController.addGoal(goal);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showSaveError(appController, e);
        return;
      }
    } else {
      try {
        await goalController.updateGoal(goal);
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        _showSaveError(appController, e);
        return;
      }
    }

    await goalController.loadGoals();

    if (!mounted) return;
    _showMessage(widget.goal == null ? 'Goal saved.' : 'Goal updated.');
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
        appBar: AppBar(title: Text('Add Goal')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _areaController,
                    decoration: InputDecoration(
                      labelText: 'Area',
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
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText: 'Type',
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
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _targetDate == null
                          ? 'Target date'
                          : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select cover',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Cover image is optional. You can save the goal without it.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            if (_selectedCoverUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_selectedCoverUrl!, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            setState(() => _selectedCoverUrl = null);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Remove'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Unsplash',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    goalController.searchUnsplash(
                      _searchController.text.trim(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (goalController.searchError != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.errorContainer.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  goalController.searchError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              )
            else if (_searchController.text.trim().isNotEmpty &&
                goalController.searchResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('No images found for this search.'),
              )
            else if (goalController.searchResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Search Unsplash if you want a cover image, or skip this step and save the goal.',
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: goalController.searchResults.length,
                itemBuilder: (context, index) {
                  final image = goalController.searchResults[index];
                  final isSelected = image.fullUrl == _selectedCoverUrl;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCoverUrl = image.fullUrl;
                      });
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            image.thumbUrl,
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
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
    );
  }
}
