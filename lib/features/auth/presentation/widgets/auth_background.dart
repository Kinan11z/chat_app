import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -110,
          child: _blob(scheme.primary.withOpacity(0.20), 280),
        ),
        Positioned(
          top: 40,
          left: -150,
          child: _blob(scheme.primary.withOpacity(0.12), 240),
        ),
        Positioned(
          bottom: -100,
          right: -70,
          child: _blob(scheme.secondary.withOpacity(0.10), 220),
        ),
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _blob(Color color, double size) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withOpacity(0)],
            ),
          ),
        ),
      );
}
