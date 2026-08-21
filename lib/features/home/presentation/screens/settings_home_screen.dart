import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/core/presentation/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/session/session_cubit.dart';
import '../../../setting/presentation/screens/profile_screen.dart';
import '../../../setting/presentation/screens/qr_code_screen.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionCubit>().state.user;
    final theme = context.watch<ThemeCubit>().state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 40,
              leading: CircleAvatar(
                radius: 40,
                backgroundImage:
                    user?.imageUrl != null && user!.imageUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(
                            user.imageUrl!,
                          )
                        : null,
              ),
              title: Text(user!.name),
              trailing: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrCodeScreen(),
                  ),
                ),
                child: Icon(Iconsax.scan_barcode),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    )),
                title: Text('Profile'),
                leading: Icon(Iconsax.user),
                trailing: Icon(Iconsax.arrow_right_3),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: Color(theme.mainColor),
                          onColorChanged: (value) {
                            context
                                .read<ThemeCubit>()
                                .changeMainColor(value.value);
                          },
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Done"))
                      ],
                    );
                  },
                ),
                title: Text('Theme'),
                leading: Icon(Iconsax.color_swatch),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Dark Mode'),
                leading: Icon(Iconsax.moon),
                trailing: SizedBox(
                  child: Switch(
                    value: theme.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      context.read<ThemeCubit>().changeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async {
                  getIt<SessionCubit>().setOnline(false);
                  await getIt<SessionCubit>().signOut();
                },
                title: Text('Signout'),
                trailing: Icon(Iconsax.logout_1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
