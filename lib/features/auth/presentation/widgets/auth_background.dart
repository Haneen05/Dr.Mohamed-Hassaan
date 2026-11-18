import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/auth_background.jpg',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        if (isDark) ColoredBox(color: Colors.black.withValues(alpha: 0.55)),
        child,
      ],
    );
  }
}
