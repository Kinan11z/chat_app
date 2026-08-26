import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../../core/presentation/theme/theme_cubit.dart';
import '../../../../core/presentation/theme/theme_state.dart';
import '../../../setting/presentation/screens/profile_screen.dart';
import '../../../setting/presentation/screens/qr_code_screen.dart';
import '../widgets/fallback_avatar.dart';
import '../widgets/home_header.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withOpacity(0.55);
    final user = context.watch<SessionCubit>().state.user;
    final theme = context.watch<ThemeCubit>().state;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(title: 'Settings'),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: scheme.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      FallbackAvatar(
                        name: user?.name ?? '',
                        imageUrl: user?.imageUrl,
                        radius: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Tap QR to share your profile',
                              style: TextStyle(fontSize: 12.5, color: muted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QrCodeScreen(),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: Icon(
                              Iconsax.scan_barcode,
                              size: 22,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SettingsTile(
                icon: Iconsax.user,
                title: 'Profile',
                iconColor: scheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Iconsax.color_swatch,
                title: 'Theme Color',
                iconColor: Colors.deepPurple,
                trailing: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(theme.mainColor),
                    border: Border.all(color: scheme.outline.withOpacity(0.3)),
                  ),
                ),
                onTap: () => _showColorPickerDialog(context, theme),
              ),
              _SettingsTile(
                icon: Iconsax.moon,
                title: 'Dark Mode',
                iconColor: Colors.indigo,
                trailing: Switch(
                  value: theme.themeMode == ThemeMode.dark,
                  activeColor: scheme.primary,
                  thumbColor: WidgetStatePropertyAll(
                    theme.themeMode == ThemeMode.dark
                        ? scheme.onPrimary
                        : scheme.primary,
                  ),
                  onChanged: (value) {
                    context.read<ThemeCubit>().changeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _SettingsTile(
                icon: Iconsax.logout_1,
                title: 'Sign Out',
                iconColor: scheme.error,
                titleColor: scheme.error,
                onTap: () async {
                  getIt<SessionCubit>().setOnline(false);
                  await getIt<SessionCubit>().signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context, ThemeState theme) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Theme Color',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                BlockPicker(
                  pickerColor: Color(theme.mainColor),
                  onColorChanged: (value) {
                    context.read<ThemeCubit>().changeMainColor(value.value);
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.maxFinite,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    this.trailing,
    this.titleColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final Widget? trailing;
  final Color? titleColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: scheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: iconColor.withOpacity(0.12),
                  ),
                  child: Icon(icon, size: 21, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? scheme.onSurface,
                    ),
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Icon(
                    Iconsax.arrow_right_3,
                    size: 18,
                    color: scheme.onSurface.withOpacity(0.35),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
