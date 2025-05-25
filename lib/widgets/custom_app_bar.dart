import 'package:flutter/material.dart';
import '../screens/about_screen.dart'; // pastikan path ini sesuai

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showInfoButton;

  const CustomAppBar({
    super.key,
    this.title = 'WATERLENS',
    this.showBackButton = false,
    this.showInfoButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF6EC6FF),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      actions: showInfoButton
          ? [
              IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                },
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
