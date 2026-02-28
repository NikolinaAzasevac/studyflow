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

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_targetDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppController>().t('pickDate'))),
      );
      return;
    }
    final goalController = context.read<GoalController>();

    final goal = GoalModel(
      id: widget.goal?.id ?? '',
      area: _areaController.text.trim(),
      type: _typeController.text.trim(),
      description: _descriptionController.text.trim(),
      coverUrl: _selectedCoverUrl,
      targetDate: _targetDate!,
    );

    if (widget.goal == null) {
      goalController.addGoal(goal);
    } else {
      goalController.updateGoal(goal);
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
          widget.goal == null
              ? appController.t('addGoal')
              : appController.t('editGoal'),
        ),
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
                      labelText: appController.t('goalArea'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return appController.t('fieldRequired');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(
                      labelText: appController.t('goalType'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return appController.t('fieldRequired');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: appController.t('goalDescription'),
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
                          ? appController.t('goalDate')
                          : '${_targetDate!.day}/${_targetDate!.month}/${_targetDate!.year}',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              appController.t('selectCover'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: appController.t('searchUnsplash'),
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
            if (goalController.searchResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceVariant
                      .withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(appController.t('searchPrompt')),
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
                                color: Colors.black.withOpacity(0.4),
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
              label: appController.t('save'),
              icon: Icons.save,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
