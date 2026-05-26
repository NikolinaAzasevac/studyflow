import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/app_controller.dart';
import '../widgets/demo_notice_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/setting_toggle_tile.dart';
import '../widgets/study_app_bar.dart';
import 'admin/admin_screen.dart';
import 'auth/login_screen.dart';

enum _AvatarSource { photoLibrary, camera, files }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploadingAvatar = false;

  bool get _supportsCamera {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

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
      await appController.updateUserName(name);
    }
  }

  Future<_AvatarSource?> _pickAvatarSource(BuildContext context) async {
    final appController = context.read<AppController>();
    return showModalBottomSheet<_AvatarSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(appController.t('photoLibrary')),
                onTap: () =>
                    Navigator.of(context).pop(_AvatarSource.photoLibrary),
              ),
              if (_supportsCamera)
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(appController.t('camera')),
                  onTap: () => Navigator.of(context).pop(_AvatarSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: Text(appController.t('files')),
                onTap: () => Navigator.of(context).pop(_AvatarSource.files),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<(Uint8List, String)?> _loadAvatarBytes(_AvatarSource source) async {
    switch (source) {
      case _AvatarSource.photoLibrary:
        final image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 88,
          maxWidth: 1600,
        );
        if (image == null) return null;
        return (await image.readAsBytes(), image.name);
      case _AvatarSource.camera:
        final image = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 88,
          maxWidth: 1600,
        );
        if (image == null) return null;
        return (await image.readAsBytes(), image.name);
      case _AvatarSource.files:
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result == null || result.files.isEmpty) return null;
        final file = result.files.single;
        final bytes = file.bytes;
        if (bytes == null) return null;
        return (bytes, file.name);
    }
  }

  void _showSaveError(
    ScaffoldMessengerState messenger,
    AppController appController,
    Object error,
  ) {
    final reason = error.toString().replaceFirst('Exception: ', '');
    final template = appController.t('saveFailedWithReason');
    final message = template.contains('{reason}')
        ? template.replaceAll('{reason}', reason)
        : '${appController.t('saveFailed')} ($reason)';
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(content: Text(message), showCloseIcon: true),
    );
  }

  Future<void> _changeAvatar(BuildContext context) async {
    final appController = context.read<AppController>();
    final messenger = ScaffoldMessenger.of(context);
    if (!appController.isAuthenticated || _isUploadingAvatar) return;

    final source = await _pickAvatarSource(context);
    if (source == null || !mounted) return;

    final selected = await _loadAvatarBytes(source);
    if (selected == null || !mounted) return;

    setState(() => _isUploadingAvatar = true);
    try {
      await appController.uploadUserAvatar(
        bytes: selected.$1,
        fileName: selected.$2,
      );
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(appController.t('avatarUpdated')),
          showCloseIcon: true,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showSaveError(messenger, appController, error);
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
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
          if (appController.isGuest) ...[
            DemoNoticeCard(
              title: appController.t('demoModeTitle'),
              message: appController.t('demoModeMessage'),
              actionLabel: appController.t('demoModeAction'),
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: appController.avatarColor,
                    backgroundImage: user?.avatarUrl != null
                        ? NetworkImage(user!.avatarUrl!)
                        : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            user?.name.substring(0, 1).toUpperCase() ??
                                appController.t('defaultUserName').substring(
                                  0,
                                  1,
                                ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: appController.isAuthenticated
                        ? InkWell(
                            onTap: _isUploadingAvatar
                                ? null
                                : () => _changeAvatar(context),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _isUploadingAvatar
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          onPressed: appController.isAuthenticated
                              ? () => _editName(context)
                              : null,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
          if (appController.isAdmin) ...[
            PrimaryButton(
              label: appController.t('adminPanel'),
              icon: Icons.admin_panel_settings,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AdminScreen()));
              },
            ),
            const SizedBox(height: 12),
          ],
          if (!appController.isAuthenticated) ...[
            PrimaryButton(
              label: appController.t('login'),
              icon: Icons.login,
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
            const SizedBox(height: 12),
          ],
          if (appController.isAuthenticated)
            PrimaryButton(
              label: appController.t('logout'),
              icon: Icons.logout,
              onPressed: () async {
                ScaffoldMessenger.of(context).clearSnackBars();
                await appController.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
        ],
      ),
    );
  }
}
