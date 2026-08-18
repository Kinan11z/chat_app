import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/provider/provider.dart';
import '../../../auth/presentation/manager/auth/auth_bloc.dart';
import '../../../setting/presentation/screens/profile_screen.dart';
import '../../../setting/presentation/screens/qr_code_screen.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProviderApp>(context);
    AuthBloc authBloc = getIt<AuthBloc>();

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
                backgroundImage: provider.user?.imageUrl != null &&
                        provider.user!.imageUrl!.isNotEmpty
                    ? CachedNetworkImageProvider(
                        provider.user!.imageUrl!,
                      )
                    : null,
              ),
              title: Text(provider.user!.name ?? ''),
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
                          pickerColor: Color(provider.mainColor),
                          onColorChanged: (value) {
                            provider.changeMainColor(value.value);
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
                    value: provider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      provider.changeMode(value);
                    },
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                onTap: () async {
                  authBloc.add(UpdateActivateEvent(online: false));
                  await FirebaseAuth.instance.signOut();
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
