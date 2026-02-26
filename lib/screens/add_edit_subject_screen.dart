import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/subject_model.dart';
import '../providers/app_controller.dart';
import '../providers/subject_controller.dart';
import '../widgets/primary_button.dart';

class AddEditSubjectScreen extends StatefulWidget {
  const AddEditSubjectScreen({super.key, this.subject});

  final SubjectModel? subject;

  @override
  State<AddEditSubjectScreen> createState() => _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState extends State<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  String? _selectedCoverUrl;

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _titleController.text = widget.subject!.title;
      _descriptionController.text = widget.subject!.description;
      _selectedCoverUrl = widget.subject!.coverUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final subjectController = context.read<SubjectController>();

    final subject = SubjectModel(
      id: widget.subject?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      coverUrl: _selectedCoverUrl,
      totalTasks: widget.subject?.totalTasks ?? 0,
      completedTasks: widget.subject?.completedTasks ?? 0,
    );

    if (widget.subject == null) {
      subjectController.addSubject(subject);
    } else {
      subjectController.updateSubject(subject);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final subjectController = context.watch<SubjectController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject == null
              ? appController.t('addSubject')
              : appController.t('editSubject'),
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
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: appController.t('subjectTitle'),
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
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: appController.t('subjectDescription'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required.';
                      }
                      return null;
                    },
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
                    subjectController.searchUnsplash(
                      _searchController.text.trim(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (subjectController.searchResults.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.6),
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
                itemCount: subjectController.searchResults.length,
                itemBuilder: (context, index) {
                  final image = subjectController.searchResults[index];
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
