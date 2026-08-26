import 'package:flutter/material.dart';

class AppOutlineButton extends StatelessWidget {
  const AppOutlineButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
    this.icon,
  });

  final void Function()? onPressed;
  final String text;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = !isLoading && onPressed != null;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor:
            enabled ? scheme.onSurface : scheme.onSurface.withOpacity(0.38),
        side: BorderSide(
          color: enabled
              ? scheme.onSurface.withOpacity(0.28)
              : scheme.onSurface.withOpacity(0.12),
          width: 1.4,
        ),
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: enabled ? onPressed : null,
      child: SizedBox(
        width: double.maxFinite,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  strokeCap: StrokeCap.round,
                  color: scheme.primary,
                ),
              )
            else ...[
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
