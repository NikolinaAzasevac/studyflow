import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/setting_toggle_tile.dart';
import '../widgets/study_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              CircleAvatar(
                radius: 32,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ??
                      appController.t('defaultUserName').substring(0, 1),
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? appController.t('defaultUserName'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? appController.t('notSet'),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
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
          ListTile(
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
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
                    'StudyFlow helps you plan subjects, manage tasks, and track progress.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unsplash images are used for subject covers. Credit to Unsplash photographers.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
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
