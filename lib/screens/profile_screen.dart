import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/setting_toggle_tile.dart';
import '../widgets/study_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final appController = context.read<AppController>();
    final controller = TextEditingController(text: appController.user?.name);

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appController.t('name')),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(appController.t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(appController.t('save')),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      appController.updateUserName(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appController = context.watch<AppController>();
    final user = appController.user;

    return Scaffold(
      appBar: StudyAppBar(title: appController.t('profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: appController.avatarColor,
                    child: Text(
                      user?.name.substring(0, 1).toUpperCase() ??
                          appController.t('defaultUserName').substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: appController.cycleAvatarColor,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user?.name ?? appController.t('defaultUserName'),
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editName(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email.isNotEmpty == true
                          ? user!.email
                          : appController.t('notSet'),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SettingToggleTile(
            title: appController.t('darkMode'),
            value: appController.themeMode == ThemeMode.dark,
            onChanged: (value) => appController.toggleThemeMode(value),
          ),
          const SizedBox(height: 12),
          SettingToggleTile(
            title: appController.t('notifications'),
            value: appController.notificationsEnabled,
            onChanged: appController.setNotificationsEnabled,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ListTile(
              title: Text(appController.t('language')),
              subtitle: Text(appController.localeCode.toUpperCase()),
              trailing: DropdownButton<String>(
                value: appController.localeCode,
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('EN')),
                  DropdownMenuItem(value: 'sr', child: Text('SR')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    appController.setLocale(value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appController.t('about'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'StudyFlow helps you plan goals, manage tasks, and track progress.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unsplash images are used for goal covers. Credit to Unsplash photographers.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (appController.isAuthenticated)
            PrimaryButton(
              label: appController.t('logout'),
              icon: Icons.logout,
              onPressed: appController.logout,
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
