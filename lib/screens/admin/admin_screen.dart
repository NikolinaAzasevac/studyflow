import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/admin_controller.dart';
import '../../providers/app_controller.dart';
import 'admin_user_data_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _confirmDeleteUserData(
    BuildContext context,
    AdminController adminController,
    AppController appController,
    UserModel user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete user data'),
        content: Text('Remove all goals and tasks for this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await adminController.deleteUserData(user.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Changes saved.'), showCloseIcon: true),
      );
    }
  }

  Future<void> _confirmDisableUser(
    BuildContext context,
    AdminController adminController,
    AppController appController,
    UserModel user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appController.t('disableUser')),
        content: Text(appController.t('disableUserConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appController.t('no')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(appController.t('yes')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await adminController.disableUser(user.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appController.t('changesSaved')),
          showCloseIcon: true,
        ),
      );
    }
  }

  Future<void> _editUser(
    BuildContext context,
    AdminController adminController,
    AppController appController,
    UserModel user,
  ) async {
    final nameController = TextEditingController(text: user.name);
    String role = user.role;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appController.t('editUser')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: appController.t('name')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: role,
              decoration: InputDecoration(labelText: appController.t('role')),
              items: [
                DropdownMenuItem(
                  value: 'user',
                  child: Text(appController.t('roleUser')),
                ),
                DropdownMenuItem(
                  value: 'admin',
                  child: Text(appController.t('roleAdmin')),
                ),
              ],
              onChanged: (value) {
                if (value != null) role = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(appController.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(appController.t('save')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final updated = user.copyWith(
        name: nameController.text.trim(),
        role: role,
      );
      await adminController.updateUser(updated);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appController.t('changesSaved')),
          showCloseIcon: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final adminController = context.watch<AdminController>();
    if (!appController.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(appController.t('adminPanel'))),
        body: Center(child: Text(appController.t('notAuthorized'))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(appController.t('adminPanel'))),
      body: StreamBuilder<List<UserModel>>(
        stream: adminController.watchUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          if (users.isEmpty) {
            return Center(child: Text(appController.t('noUsers')));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelf = user.id == appController.user?.id;
              return Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.isEmpty
                            ? appController.t('notSet')
                            : user.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email.isEmpty
                            ? appController.t('notSet')
                            : user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(appController.t('role')),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: user.role,
                            onChanged: isSelf
                                ? null
                                : (value) async {
                                    if (value == null) return;
                                    await adminController.setRole(
                                      user.id,
                                      value,
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(
                                      context,
                                    ).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          appController.t('changesSaved'),
                                        ),
                                        showCloseIcon: true,
                                      ),
                                    );
                                  },
                            items: [
                              DropdownMenuItem(
                                value: 'user',
                                child: Text(appController.t('roleUser')),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text(appController.t('roleAdmin')),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: isSelf
                                ? null
                                : () => _editUser(
                                    context,
                                    adminController,
                                    appController,
                                    user,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminUserDataScreen.forUser(user: user),
                                ),
                              );
                            },
                            icon: const Icon(Icons.folder_open),
                            label: Text(appController.t('manageData')),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _confirmDeleteUserData(
                              context,
                              adminController,
                              appController,
                              user,
                            ),
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: Text(appController.t('deleteUserData')),
                          ),
                          OutlinedButton.icon(
                            onPressed: isSelf
                                ? null
                                : () => _confirmDisableUser(
                                    context,
                                    adminController,
                                    appController,
                                    user,
                                  ),
                            icon: const Icon(Icons.person_off_outlined),
                            label: Text(appController.t('disableUser')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
