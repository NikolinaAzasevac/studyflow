import 'package:flutter/material.dart';

class StudyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StudyAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showLogo = true,
  });

  final String title;
  final List<Widget>? actions;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          if (showLogo)
            Image.asset(
              'assets/studyflowLogo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          if (showLogo) const SizedBox(width: 10),
          Flexible(child: Text(title)),
        ],
      ),
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
