import 'package:flutter/material.dart';

class StudyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StudyAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title), centerTitle: false, actions: actions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
